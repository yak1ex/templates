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
pod2usage(-verbose => 2) if exists $opts{h};
pod2usage(-msg => '-r and filter arguments are exclusive', -verbose => 0, -exitval => 1) if exists $opts{r} && @ARGV;
pod2usage(-msg => '-s and filter arguments are exclusive', -verbose => 0, -exitval => 1) if exists $opts{s} && @ARGV;
pod2usage(-msg => '-s and -r are exclusive', -verbose => 0, -exitval => 1) if exists $opts{s} && exists $opts{r};
$opts{a} ||= $opts{s};

$ENV{https_proxy} =~ s,^http://,connect://, if exists $ENV{https_proxy};

unless(exists $opts{C}) {
	require Term::ANSIColor;
	Term::ANSIColor->import;
}

sub mycolor
{
	return '['.$_[0].']' if exists $opts{C} || ! exists $color{$_[0]};
	return colored('['.$_[0].']', $color{$_[0]});
}

my $mach = Net::Netrc->lookup('github.com');
my $user = $mach->login;
my $gh = Net::GitHub::V3->new(login => $user, pass => $mach->password);
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

my $repo = exists $opts{r} ? repo() : undef;

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

my @issues = map { mapper($_) } (exists $opts{r} ? $gh->issue->repos_issues($user, $repo, $opt) : $gh->issue->issues(%$opt));
my ($lastpage) = $gh->issue->has_last_page ? $gh->issue->last_url =~ /page=(\d+)/ : 1;
while(exists $opts{a} && $gh->issue->has_next_page) {
	push @issues, map { mapper($_) } $gh->issue->next_page;
}
if(exists $opts{s}) {
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
	print '### Show ', scalar(@issues), ' item(s) in ', (exists $opts{a} ? $lastpage : 1), ' page(s) of total ', $lastpage, "\n";
	sub header { return "$user/$_[0]->{repo}#$_[0]->{number} " }
	my $len = max map { length header($_) } @issues;
	print map { sprintf("%-${len}s", header($_)).": $_->{title} ".join('', map { mycolor($_) } @{$_->{labels}})."\n" } @issues;
}

__END__

=head1 NAME

ghissue.pl - Show issues on GitHub

=head1 SYNOPSIS

ghissues.pl [-a|-h|-r|-C] [E<lt>filterE<gt>...]

  # Show assigned open issues on first page.
  ghissue.pl

  # Show all assigned open issues.
  ghissue.pl -a

  # Show all assigned open issues corresponding to the current working copy, without color.
  ghissue.pl -arC

  # Show all assigned open issues, excluding ones for repository matching /ccf/ but including just ccf
  ghissue.pl -a !/ccf/ ccf

=head1 DESCRIPTION

Show issues on GitHub.

=head1 OPTIONS

=over 4

=item C<-a>

Show all assigned open issues.

=for getopt 'a'

=item C<-s>

Show summary info, which is the number of issues grouped by repository.
This flag implies -a flag.

=for getopt 's'

=item C<-r>

Limit to the repository corresponding to the current working copy

=for getopt 'r'

=item C<-C>

Do not colorize labels.

=for getopt 'C'

=item C<-h>

Show POD help

=for getopt 'h'

=item C<E<lt>filterE<gt>>

Specify repository filter specs. Beginning with '!' means exclusion, otherwise inclusion.
Treated as regexp if enclosed by '/'. The last match is applicable if multiple filters are specified.
If no matches are made, negation of the type of the first specified filter is applied for all.

=back

=cut
