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

my %opts;
getopts(Getopt::Config::FromPod->string, \%opts);
pod2usage(-verbose => 2) if exists $opts{h};
pod2usage(-msg => 'Arguments should not be files but be folders', -verbose => 0, -exitval => 1) if grep { ! -d $_ } @ARGV;

$ENV{https_proxy} =~ s,^http://,connect://, if exists $ENV{https_proxy};

my $mach = Net::Netrc->lookup('github.com');
my $user = $mach->login;
my $gh = Net::GitHub::V3->new(login => $user, pass => $mach->password);

my @issues = map {
	{ repo => $_->{repository}{name}, number => $_->{number}, labels => [map { $_->{name} } @{$_->{labels}}], title => $_->{title} }
} $gh->issue->issues(filter => 'assigned', state => 'open');
while(exists $opts{a} && $gh->issue->has_next_page) {
	push @issues, $gh->issue->next_page;
}
print map { sprintf('%-30s', "$user/$_->{repo}#$_->{number}").": $_->{title}".(' ['.join('][', @{$_->{labels}}).']')."\n" } @issues;

__END__

=head1 NAME

ghissue.pl - Show issues on GitHub

=head1 SYNOPSIS

ghissues.pl [-a|-h]

  # Show assigned open issues on first page.
  ghissue.pl

  # Show all assigned open issues.
  ghissue.pl -a

=head1 DESCRIPTION

Show issues on GitHub.

=head1 OPTIONS

=over 4

=item C<-a>

Show all assigned open issues.

=for getopt 'a'

=item C<-h>

Show POD help

=for getopt 'h'

=back

=cut
