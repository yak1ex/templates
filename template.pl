#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Std;
use Pod::Usage;

use Module::List;

sub show_list
{
	print join("\n", sort map { s/Software::License:://; $_ }
		keys %{Module::List::list_modules('Software::License::', { list_modules => 1 })}), "\n";
	exit;
} 

my %opts;
getopts('hlk:', \%opts);
show_list() if exists $opts{l};
pod2usage(-verbosity => 2) if exists $opts{h};
pod2usage(-msg => 'Name not found', -verbose => 0, -exitval => 1) unless eval "require Software::License::$opts{k}";

__END__

=head1 NAME

template.pl - Make skelton from template

=head1 SYNOPSIS

perl template.pl -h

perl template.pl -l

perl template.pl -k C<key>

=head1 DESCRIPTION

=head1 OPTIONS

=over 4

=item C<-h>

Show POD help

=item C<-l>

List license keys

=item C<-k>

Specify license key

=back

=cut
