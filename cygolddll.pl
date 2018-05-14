#!/usr/bin/perl 

use strict;

use Getopt::Std;
use Getopt::Config::FromPod;
use Pod::Usage;
use File::Basename;
use Term::ANSIColor;
use PerlIO::via::gzip;
use File::stat;
use MLDBM qw(DB_File Storable);

sub versplit
{
	my $basename = shift @_;
	if(my ($name, $ver) = $basename =~ /(.*)-(\d+(?:[._]\d+)?)\.dll/) {
		$ver =~ s/_/./;
		return ($name, $ver);
	} elsif(my ($name, $ver) = $basename =~ /^(cygicu\D*)(\d+)\.dll/) {
		return ($name, $ver);
	}
	return undef;
}

sub collect
{
	my ($folders, $exts) = @_;
	my $filter = '(?:'.join('|', map { "\\.$_" } @$exts).')$';
	my @result;
	foreach my $folder (@$folders) {
		opendir(DIR, $folder);
		push @result, map { "$folder/$_" } grep { /$filter/ } readdir(DIR);
		closedir(DIR);
	}
	return @result;
}

my %opts;
getopts(Getopt::Config::FromPod->string, \%opts);
pod2usage(-verbose => 2) if exists $opts{h};

STDOUT->autoflush(1);

my (%package, $i, $total, %target, %cache);
my $dbm = tie %cache, 'MLDBM', '/var/cache/cygolddll.db';
if($opts{c}) {
	my @key = keys %cache;
	my ($total, $i) = (scalar(@key), 0);
	for my $key (@key) {
		++$i;
		print "$i / $total\r";
		my ($file, $size, $mtime) = $key =~ /(.*)_(\d+)_(\d+)$/;
		my $st = stat($file);
		if(!$st || $st->size != $size || $st->mtime != $mtime) {
			print "Delete cache entry for $file\n";
			delete $cache{$key};
		}
	}
	exit(0);
}

open my $fh, '<', '/var/cache/rebase/rebase_all';
while(<$fh>) {
	chop;
	$target{$_} = 1;
}
close $fh;

my @spec = collect(['/etc/setup'], ['gz']);
$i = 0; $total = @spec;
print "Loading package list:\n";
while(my $spec = shift @spec)
{
	++$i;
	print "$i / $total\r";
	my $st = stat($spec) or print "skip $spec" and next;
	my $key = sprintf '%s_%d_%d', $spec, $st->size, $st->mtime;
	my $value = [];
	my $package = fileparse($spec);
	$package =~ s/\.lst\.gz$//;

	my $process = sub {
		local $_ = shift;
		if(/\.(dll|so)$/) {
			my $dll = fileparse($_);
			$package{lc($dll)} = $package;
		}
		if(/\.(dll|exe|so)$/) {
			my $exe = "/$_" unless m,^/,,; #/
			$target{$exe} = 1;
			push @$value, $_;
		}
	};
	if(exists $cache{$key}) {
		$process->($_) for @{$cache{$key}};
	} else {
		open my $fh, '<:via(gzip)', $spec;
		while(<$fh>) {
			chop;
			$process->($_);
		}
		close $fh;
		$cache{$key} = $value;
	}
}

$target{$_} = 1 for collect(['/usr/bin', '/usr/local/bin'], ['dll','exe','so']);
my @target = keys %target;

my (%exist, %ref, %refp, %ver);
my ($i, $total);
print "Loading DLL info:\n";
$i = 0; $total = @target;
while(my $target = shift @target)
{
	++$i;
	print "$i / $total\r";
	my $basename = fileparse($target);
	if($target =~ m,/bin/.*\.dll,i && -f $target) { # .so is loadable object for almost all cases
		$exist{$basename} = 1;
		if(my @ver = versplit($basename)) {
			$ver{$ver[0]} ||= 0;
			$ver{$ver[0]} = $ver[1] if $ver{$ver[0]} < $ver[1];
		}
	}
	my $st = stat($target) or print "skip $target" and next;
	my $key = sprintf '%s_%d_%d', $target, $st->size, $st->mtime;

	my $register = sub {
		my $ref = shift;
		$ref{lc($ref)} = $basename;
		$refp{$package{lc($ref)}} = $basename if exists $package{lc($ref)};
	};
	if(exists $cache{$key}) {
		foreach my $value (@{$cache{$key}}) {
			$register->($value);
		}
	} else {
		my $value = [];
		open my $fh, '-|', "objdump -p $target";
		while(<$fh>) {
			if(/DLL Name: (\S+)/) {
				$register->($1);
				push @$value, $1;
			}
		}
		close $fh;
		$cache{$key} = $value;
	}
}
foreach my $i (sort keys %exist) {
	my $installed = exists $package{lc($i)};
	my @ver = versplit($i);
	my $obsoleted = $ver{$ver[0]} > $ver[1];
	next unless ($opts{o} && $obsoleted) || ($opts{n} && !$installed) || (!$opts{o} && !$opts{n});
	if(! exists $ref{lc($i)} && ! exists $refp{$package{lc($i)}}) {
		print "$i";
		print " ($package{lc($i)})" if $installed;
		print colored(['red'], ' [not installed]') unless $installed;
		print colored(['yellow'], ' [obsoleted]') if $obsoleted;
		print "\n";
	}
}

__END__

=head1 NAME

cygolddll.pl - Check old unreferenced DLLs

=head1 SYNOPSIS

perl cygolddll.pl -h

perl cygolddll.pl [-o|-n]

perl cygolddll.pl -c

=head1 DESCRIPTION

Output DLL files unreferenced from other exe/dll/so.

The following sources are considered for dependency check:

=over 4

=item *

Contents of /var/cache/rebase/rebase_all

=item *

Contents of /etc/setup/*.lst.gz

=item *

Files in /usr/bin and /usr/local/bin

=back

Output target is limited to files in /usr/bin and /usr/local/bin.

A cache file exists in /var/cache/cygolddll.db.

=head1 OPTIONS

=over 4

=item C<-h>

Show POD help

=for getopt 'h'

=item C<-o>

Suppress to output unreferenced only files and show obsoleted files

=for getopt 'o'

=item C<-n>

Suppress to output unreferenced only files and show not-installed files

=for getopt 'n'

=item C<-c>

Clear nonexistent cache entries.

=for getopt 'c'

=back

=cut
