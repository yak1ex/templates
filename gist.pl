#!/usr/bin/perl
#
#   gist.pl: Gist CUI helper script
#
#   Written by Yak! <yak1ex@users.noreply.github.com>
#
#   Distributed under the terms of The zlib License
#   See http://www.zlib.net/zlib_license.html
#

use utf8;
use strict;
use warnings;

use Getopt::Std;
use Getopt::Config::FromPod;
use Pod::Usage;

use Encode;
use JSON;
use Net::Netrc;
use Net::GitHub::V3;
use Term::ANSIColor;
use File::Basename;

sub slurp
{
	my $filename = shift;
	my $ret;
	local $/;
	open my $fh, '<', $filename or die;
	$ret = <$fh>;
	close $fh;
	return Encode::decode('utf-8', $ret) if -T $filename;
	return $ret;
}

my %opts;
my $regex_id;
getopts(Getopt::Config::FromPod->string, \%opts);
if(exists $opts{L}) {
	$opts{F} = $opts{L};
	$opts{n} = 1;
}
if(exists $opts{u} && $opts{u} =~ m,^/(.*)/$,) {
	$opts{F} = $1;
	$regex_id = 1;
}
$opts{l}=1 if exists $opts{n} || exists $opts{F};
pod2usage(-verbose => 2) if exists $opts{h};
# pod2usage(-msg => '', -verbose => 0, -exitval => 1) if ...;

my $mach = Net::Netrc->lookup('github.com');
my $user = $mach->login;
my $gh = Net::GitHub::V3->new(login => $user, pass => $mach->password);
if(exists $ENV{https_proxy}) {
  $gh->ua->proxy('https', $ENV{https_proxy});
}
my $gist = $gh->gist();

my $i = 0;
if($opts{l}) {
	while(my $_ = $gist->next_gist) {
		if($opts{F}) {
			my $match;
			foreach my $target ($_->{description}, keys(%{$_->{files}})) {
					if($target =~ /$opts{F}/i) {
						$match = 1; last;
					}
			}
			next unless $match;
		}
		++$i;
		if($regex_id) {
			$opts{u} = $_->{id};
		} elsif($opts{L}) {
			print Encode::encode('utf-8', $_->{id}),"\n";
		} else {
			print Encode::encode('utf-8', sprintf("%s: [%s] %s %s\n%s", $_->{id}, $_->{updated_at}, ($_->{public} ? colored('(public)', 'yellow') : colored('(private)', 'red')), join(',', keys(%{$_->{files}})), $_->{description} =~ s/^/\t/mgr)),"\n";
		}
		last if(exists $opts{n} && $i > $opts{n});
	}
	exit unless $regex_id;
	die "$i mached result(s) found" unless $i == 1;
}
if($opts{u}) {
	my $spec = {};
	if($opts{D}) { $spec->{description} = $opts{D}; }
	if($opts{d}) {
		foreach my $dfile (split(/,/, $opts{d})) {
			$spec->{files}{$dfile} = undef;
		}
	}
	if($opts{r}) {
		my @spec = split(/,/, $opts{r});
		while(my ($old, $new) = splice(@spec, 0, 2)) {
			$spec->{files}{$old}{filename} = $new;
		}
	}
	while(my $filename = shift) {
		$spec->{files}{scalar(fileparse($filename))}{content} = slurp($filename);
	}
	$gist->update($opts{u}, $spec);
} else {
	my $spec = {};
	if($opts{P}) { $spec->{public} = JSON::true }
	if($opts{D}) { $spec->{description} = $opts{D}; }
	while(my $filename = shift) {
		$spec->{files}{scalar(fileparse($filename))}{content} = slurp($filename);
	}
	print $gist->create($spec)->{id},"\n";
}

__END__

=head1 NAME

gist.pl - Gist CUI helper script

=head1 SYNOPSIS

perl gist.pl -h

perl gist.pl -l [-n <num>] [-F <regex>]

perl gist.pl -L <regex>

perl gist.pl -u <id_or_regex> [-D <desc>] [-d <deleting_files>,...] [-r <rename_specs>] [<files>...]

perl gist.pl [-P] [-D <desc>] <files>...

=head1 DESCRIPTION

=head1 OPTIONS

=over 4

=item C<-h>

Show this help.

=for getopt 'h'

=item C<-l>

Show all gists.

=for getopt 'l'

=item C<-n> <num>

Limit <num> entries. This implies C<-l>.

=for getopt 'n:'

=item C<-F> <regex>

Filter by regex on description and filenames. This implies C<-l>.

=for getopt 'F:'

=item C<-L> <regex>

=for getopt 'L:'

=item C<-u> <id_or_regex>

Spcify target gist ID. If the beginning and the ending of the argument is '/', that is '/something/', it is treated as regex and use matched ID only if there is the only one matched result.

=for getopt 'u:'

=item C<-D> <desc>

Description to be updated.

=for getopt 'D:'

=item C<-d> <deleting_files>,...

Comma separated filenames to be deleted.

=for getopt 'd:'

=item C<-r> <rename_specs>

like old_name1,new_name1,old_name2,new_name2...

=for getopt 'r:'

=item C<-P>

Make a new gist public

=for getopt 'P'

=item <files>...

Files to be added or updated.

=back

=cut
