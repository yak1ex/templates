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
getopts('hr:av', \%opts);
pod2usage(-verbosity => 2) if exists $opts{h};
pod2usage(-msg => 'At least 1 repo shuold be specified', -verbose => 0, -exitval => 1) if @ARGV == 0 && !exists $opts{a};
my $ref = $opts{r} || 'templates';

my $mach = Net::Netrc->lookup('github.com');
my $user = $mach->login;
my $gh = Net::GitHub::V3->new(login => $user, pass => $mach->password);

my (%ref) = (map { $_->{name} => $_->{color} } $gh->issue->labels($user, $ref));
use Data::Dumper;
my (@args);
if(exists $opts{a}) {
	push @args, $gh->repos->list_user($user, 'owner');
	while($gh->repos->has_next_page) {
		push @args, $gh->repos->next_page;
	}
	(@args) = map { $_->{name}  } grep { ! exists $_->{has_issues} || $_->{has_issues} } @args;
} else {
	(@args) = (@ARGV);
}
while(my $repo = shift @args) {
	$opts{v} and print STDERR "Processing $repo...\n";
	my (%cur) = (map { $_->{name} => 1 } $gh->issue->labels($user, $repo));
	foreach my $name (keys %ref) {
		$gh->issue->create_label($user, $repo, { name => $name, color => $ref{$name} }) if ! exists $cur{$name};
	}
}

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

=item -a

Set all repositories as targets.

=item -r C<refrepo>

Set referenced repository. Defaults to 'templates'.

=item C<repos>...

Specify target repositories.

=back

=cut
