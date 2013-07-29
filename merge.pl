#!/usr/bin/perl
#
#   merge.pl: Merge configuration
#
#   Written by Yak! <yak_ex@mx.scn.tv>
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

my %opts = (
	s => '.dzil,.gitconfig',
	t => $ENV{HOME},
);
getopts(Getopt::Config::FromPod->string, \%opts);
pod2usage(-verbose => 2) if exists $opts{h};
#pod2usage(-msg => '', -verbose => 0, -exitval => 1) if ...;

sub process_file
{
	print "$_[0] $opts{t}/$_[0]\n";
	system "diff -q $_[0] $opts{t}/$_[0]";
	system "vimdiff $_[0] $opts{t}/$_[0]" if $? == 256;
}

sub process_dir
{
	File::Find::find({
		wanted => sub {
			process_file($File::Find::name) if -f $File::Find::name;
		}, no_chdir => 1,
	}, $_[0]);
}

my @source = split /,/, $opts{s};
foreach my $source (@source) {
	if(-f $source) {
		process_file($source);
	} elsif(-d $source) {
		process_dir($source);
	} else {
		warn 'Unknown file type: $source';
	}
}

__END__

=head1 NAME

merge.pl - Merge configuration

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 OPTIONS

=over 4

=item C<-h>

Show this help.

=for getopt 'h'

=item C<-s E<lt>sourcesE<gt>>

Specify soruce folders and files. Defaults to '.dzil,.gitconfig'.

=for getopt 's:'

=item C<-t E<lt>targetE<gt>>. Defaults to $ENV{HOME}.

Specify target folder.

=for getopt 't:'

=back

=cut
