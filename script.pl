#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Std;
use Pod::Usage;

my %opts;
getopts('h', \%opts);
pod2usage(-verbosity => 2) if exists $opts{h};
pod2usage(-msg => '', -verbose => 0, -exitval => 1) if ...;

__END__

=head1 NAME

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut
