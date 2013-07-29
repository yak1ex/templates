#!/usr/bin/perl
#
#   ghlabel.pl: Label configurator for GitHub Issues.
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
use Pod::Usage;

use Net::Netrc;
use Net::GitHub::V3;

my %opts;
getopts('hv', \%opts);
pod2usage(-verbosity => 2) if exists $opts{h};
#pod2usage(-msg => 'At least 1 repo shuold be specified', -verbose => 0, -exitval => 1) if @ARGV == 0 && !exists $opts{a};

# See http://qiita.com/debug-ito@github/items/4b3fec645f15af9b4929
$ENV{https_proxy} =~ s,^http://,connect://, if exists $ENV{https_proxy};
$ENV{PERL_LWP_SSL_VERIFY_HOSTNAME} = 0; # Just workaround

my $mach = Net::Netrc->lookup('github.com');
my $user = $mach->login;
my $gh = Net::GitHub::V3->new(login => $user, pass => $mach->password);

my $repo;
open my $fh, '<', '.git/config' or die;
while(<$fh>) {
	if(m@https://github.com/$user/(\S+?)(?:.git)?$@) {
		$repo = $1;
		last;
	}
}
close $fh;
die if ! defined $repo;

#$gh->set_default_user_repo($user, $repo);
print $gh->repos->get($user, $repo);
exit;
my $upstream_url;
print <<EOF
[remote "upstream"]
        url = $upstream_url
        fetch = +refs/heads/*:refs/remotes/upstream/*
EOF

__END__

=head1 NAME

ghlabel.pl - Label configurator for GitHub Issues.

=head1 SYNOPSIS

ghlabel.pl [-v] [-a] [-r C<refrepo>] C<repos>...

  # Configurate all repositories with verbose messages
  ghlabel.pl -av

  # Explicit specification of referenced repository and target repositories
  ghlabel.pl -r refrepo repo1 repo2

=head1 DESCRIPTION

Create missing issue labels according to referenced repository on GitHub.

=head OPTIONS

=over 4

=item -v

Enable verbose messages

=item -r C<refrepo>

Set referenced repository. Defaults to 'templates'.

=item C<repos>...

Specify target repositories.

=back

=cut
