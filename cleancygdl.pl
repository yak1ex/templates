#!/usr/bin/perl

use strict;
use warnings;

use File::Find;
use File::Basename;

my %files;

my $ini = shift;
open my $FH, '<', $ini;
while(<$FH>) {
	if(/^(install|source): /) {
		my $file = (split(/\s+/))[1];
#		print $file, "\n";
		$files{$file} = 1;
	}
}
close $FH;

my $base = dirname($ini);
$base =~ s,/[^/]*$,/,; #/
File::Find::find({ wanted => sub {
	return unless -f $File::Find::name;
	return unless $File::Find::name =~ /\.(xz|bz2)$/;
	my $name = $File::Find::name;
	$name =~ s/$base//;
	if(! exists $files{$name}) {
		print "Deleting $name\n";
		unlink "$base$name";
	}
}, no_chdir => 1}, dirname($ini));
