#!/usr/bin/perl
#
#   ghissues.pl: Show issues on GitHub
#
#   Written by Yasutaka ATARASHI <yak_ex@mx.scn.tv>
#
#   Distributed under the terms of The zlib License
#   See http://www.zlib.net/zlib_license.html
#
#   $Id$
#

use strict;
use warnings;

use Getopt::Std;
use Getopt::Config::FromPod;
use Pod::Usage;

use File::Find;
use Net::Netrc;
use Net::GitHub::V3;
use Cwd;
use List::Util qw(max);

my %color = (
	'middle'      => 'black on_yellow', # '#d7e102'
	'task'        => 'on_blue',         # '#0b02e1'
	'wontfix'     => 'black on_white',  # '#ffffff'
	'bug'         => 'on_bright_red',   # '#fc2929'
	'question'    => 'on_magenta',      # '#cc317c'
	'high'        => 'on_red',          # '#e10c02'
	'duplicate'   => 'on_bright_black', # '#cccccc'
	'low'         => 'black on_green',  # '#02e10c'
	'enhancement' => 'black on_cyan',   # '#84b6eb'
	'invalid'     => 'on_bright_black', # '#e6e6e6'
);

my %opts;
getopts(Getopt::Config::FromPod->string, \%opts);
pod2usage(-verbose => 2) if $opts{h};
pod2usage(-msg => '-r and filter arguments are exclusive', -verbose => 0, -exitval => 1) if $opts{r} && @ARGV;
pod2usage(-msg => '-s and filter arguments are exclusive', -verbose => 0, -exitval => 1) if $opts{s} && @ARGV;
pod2usage(-msg => '-s and -r are exclusive', -verbose => 0, -exitval => 1) if $opts{s} && $opts{r};
pod2usage(-msg => '-N requires 3 arguments', -verbose => 0, -exitval => 1) if $opts{N} && @ARGV != 3;
pod2usage(-msg => '-N and -a are exclusive', -verbose => 0, -exitval => 1) if $opts{N} && $opts{a};
pod2usage(-msg => '-N and -s are exclusive', -verbose => 0, -exitval => 1) if $opts{N} && $opts{a};
pod2usage(-msg => '-r and -a are exclusive', -verbose => 0, -exitval => 1) if $opts{r} && $opts{a};
my @labels = $opts{N} ? (split /,/, $ARGV[2]) : ();
my @unknown_labels = grep { ! exists $color{$_} } @labels;
pod2usage(-msg => "unknown label(s) @{[join ', ', map { '\"'.$_.'\"' } @unknown_labels]} exist(s)", -verbose => 0, -exitval => 1) if $opts{N} && @unknown_labels;
$opts{a} ||= $opts{s};
$opts{r} ||= $opts{N};

unless($opts{C}) {
	require Term::ANSIColor;
	Term::ANSIColor->import;
}

sub mycolor
{
	return '['.$_[0].']' if $opts{C} || ! exists $color{$_[0]};
	return colored('['.$_[0].']', $color{$_[0]});
}

my $mach = Net::Netrc->lookup('github.com');
my $user = $mach->login;
my $gh = Net::GitHub::V3->new(login => $user, pass => $mach->password);
if(exists $ENV{https_proxy}) {
  $gh->ua->proxy('https', $ENV{https_proxy});
}
my $opt = { filter => 'assigned', state => 'open' };
my $root_inode = (stat('/'))[1];

sub repo
{
	my $dir = cwd();
	do {
		my $conf = "$dir/.git/config";
		if(-f $conf) {
			open my $fh, '<', $conf;
			while(<$fh>) {
				return $1 if m,\s*url\s*=\s*(?:https://github.com/|git\@github.com:)$user/(.*?)(?:\.git)?\s*$,;
			}
			close $fh;
		}
		$dir .= '/..';
	} while(-d $dir && (stat(_))[1] != $root_inode);
	die 'Git config is not found';
}
my $repo = $opts{r} ? repo() : undef;

if($opts{N}) {
	my ($title, $body, $labels) = @ARGV;
	undef @ARGV;
	$gh->issue->create_issue($user, $repo, { title => $title, body => $body, assignees => [ $user ], labels => \@labels });
}

my $filter = sub { 1 };
if(@ARGV) {
	my @filter = @ARGV;
	my $result_ = $filter[0] =~ /^!/;
	$filter = sub {
		my $result = $result_;
		for my $filter_ (@filter) {
			my $filter = $filter_;
			my $ret = 1;
			$ret = 0 if $filter =~ s/^!//;
			if($filter =~ m|^/(.*)/$|) {
				$result = $ret if $_[0]->{repo} =~ /$1/;
			} else {
				$result = $ret if $_[0]->{repo} eq $filter;
			}
		}
		return $result;
	};
}

sub mapper
{
	return {
		repo => $_[0]->{repository}{name} || $repo,
		number => $_[0]->{number},
		labels => [map { $_->{name} } @{$_[0]->{labels}}],
		title => $_[0]->{title},
	};
}

my @issues = map { mapper($_) } ($opts{r} ? $gh->issue->repos_issues($user, $repo, $opt) : $gh->issue->issues(%$opt));
my ($lastpage) = $gh->issue->has_last_page ? $gh->issue->last_url =~ /page=(\d+)/ : 1;
while($opts{a} && $gh->issue->has_next_page) {
	push @issues, map { mapper($_) } $gh->issue->next_page;
}
if($opts{s}) {
	my %count; my $len = 0;
	for my $issue (@issues) {
		$len = max $len, length($issue->{repo});
		$count{$issue->{repo}} ||= 0;
		++$count{$issue->{repo}};
	}
	foreach my $name (sort { $count{$b} <=> $count{$a} || $a cmp $b } keys %count) {
		printf "%-${len}s : %4d\n", $name, $count{$name};
	}
} else {
	@issues = grep { $filter->($_) } @issues;
	print '### Show ', scalar(@issues), ' item(s) in ', ($opts{a} ? $lastpage : 1), ' page(s) of total ', $lastpage, "\n";
	sub header { return "$user/$_[0]->{repo}#$_[0]->{number} " }
	my $len = max map { length header($_) } @issues;
	print map { sprintf("%-${len}s", header($_)).": $_->{title} ".join('', map { mycolor($_) } @{$_->{labels}})."\n" } @issues;
}

__END__

=head1 NAME

ghissue.pl - Show issues on GitHub

=head1 SYNOPSIS

ghissues.pl [-a|-r|-C] [E<lt>filterE<gt>...]

ghissues.pl [-N] E<lt>titleE<gt> E<lt>bodyE<gt> E<lt>labelsE<gt>

ghissues.pl -h

  # Show assigned open issues on first page.
  ghissues.pl

  # Show all assigned open issues.
  ghissues.pl -a

  # Show all assigned open issues corresponding to the current working copy, without color.
  ghissues.pl -arC

  # Show all assigned open issues, excluding ones for repository matching /ccf/ but including just ccf.
  ghissues.pl -a !/ccf/ ccf

  # Create an issue on the repository corresponding to the current working copy.
  ghissues.pl -N 'title' 'description_line_1
  description_line_2' enhancement,middle

=head1 DESCRIPTION

Show issues or create an issue on GitHub.

=head1 OPTIONS

=over 4

=item C<-a>

Show all assigned open issues.

=for getopt 'a'

=item C<-s>

Show summary info, which is the number of issues grouped by repository.
This flag implies C<-a> flag.

=for getopt 's'

=item C<-r>

Limit to the repository corresponding to the current working copy

=for getopt 'r'

=item C<-C>

Do not colorize labels.

=for getopt 'C'

=item C<-N>

Create a new issue and show issues as if C<-r> is specified.
Following commandline arguments are E<lt>titleE<gt>, E<lt>bodyE<gt>, and E<lt>labelsE<gt>.

E<lt>labelsE<gt> consists of comma-separated labels.

Assignee is automatically set.

=for getopt 'N'

=item C<-h>

Show POD help

=for getopt 'h'

=item C<E<lt>filterE<gt>>

Specify repository filter specs. Beginning with '!' means exclusion, otherwise inclusion.
Treated as regexp if enclosed by '/'. The last match is applicable if multiple filters are specified.
If no matches are made, negation of the type of the first specified filter is applied for all.

=back

=cut
