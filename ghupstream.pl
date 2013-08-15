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

use File::Find;
use Net::Netrc;
use Net::GitHub::V3;

my %opts;
getopts('hrv', \%opts);
pod2usage(-verbose => 2) if exists $opts{h};
pod2usage(-msg => 'Arguments should not be files but be folders', -verbose => 0, -exitval => 1) if grep { ! -d $_ } @ARGV;

# See http://qiita.com/debug-ito@github/items/4b3fec645f15af9b4929
$ENV{https_proxy} =~ s,^http://,connect://, if exists $ENV{https_proxy};
$ENV{PERL_LWP_SSL_VERIFY_HOSTNAME} = 0; # Just workaround

my $mach = Net::Netrc->lookup('github.com');
my $user = $mach->login;
my $gh = Net::GitHub::V3->new(login => $user, pass => $mach->password);

sub process_dir
{
	my $dir = shift;
	my ($repo, $already);
	open my $fh, '<', "$dir/.git/config" or die;
	while(<$fh>) {
		if(m@https://github.com/$user/(\S+?)(?:.git)?$@) {
			$repo = $1;
		}
		if(m@\[remote "upstream"]@) {
			$already = 1;
		}
	}
	close $fh;
	if(defined $already) {
		$opts{v} and warn "$repo is skipped because upstream has already existed";
		return;
	}
	return $repo;
}

find({
	no_chdir => 1,
	wanted => sub {
		return unless -d $File::Find::name;
		return unless -f "$File::Find::name/.git/config";
		my $repo = process_dir($File::Find::name);
		return if ! defined $repo;

		my $dat = $gh->repos->get($user, $repo);
		$opts{v} and warn "$repo is not a fork" and 0 or return if ! exists $dat->{parent};
		$opts{v} and warn "source and parent are different for $repo" and 0 or return if $dat->{source}{url} ne $dat->{parent}{url};

		my $upstream_url = $dat->{parent}{clone_url};
		print STDERR "Setup upstream for $repo\n";
		open my $fh, '>>', "$File::Find::name/.git/config";
		print $fh <<EOF;
[remote "upstream"]
        fetch = +refs/heads/*:refs/remotes/upstream/*
        url = $upstream_url
EOF
		close $fh;
	},
	preprocess => sub {
		my @list = @_;
		return unless exists $opts{r};
		return if grep { /^\.git$/ } @list;
		return grep { -d "$File::Find::dir/$_" } @list;
	}
}, @ARGV);

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
