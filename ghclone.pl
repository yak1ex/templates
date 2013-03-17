#!/usr/bin/perl
#
#   ghclone.pl: Clone with user configuration
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

use Config::INI::Reader;
use Config::INI::Writer;
use YAML::Any;
use IO::Prompt;

sub to_str
{
	return $_[0]{name}.' <'.$_[0]{email}.'>';
}

my %opts;
getopts('h', \%opts);
pod2usage(-verbosity => 2) if exists $opts{h};
pod2usage(-msg => 'At least one repo MUST be specified', -verbose => 0, -exitval => 1) if ! @ARGV;

my $CONF = $ENV{HOME}.'/.template.yaml';
my $conf = -r $CONF ? YAML::Any::LoadFile($CONF) : {};
my $authors = [map { $_->{name}.' <'.$_->{email}.'>' } @{$conf->{author}}];
my $conf_user = Config::INI::Reader->read_file("$ENV{HOME}/.gitconfig");
my $def_user  = $conf_user->{user}{name};
my $def_email = $conf_user->{user}{email};

while(my $repo = shift) {
	warn "$repo already exists" and next if -e $repo;
	system "git clone https://github.com/yak1ex/${repo}.git";
	my $conf_repo = Config::INI::Reader->read_file("${repo}/.git/config");
	my $default = to_str($conf->{author}[0]);
	if(-f "${repo}/dist.ini" || -f "${repo}/Makefile.PL" || -f "${repo}/Build.PL") { # Perl module
		$default = to_str((grep { $_->{email} =~ /\@cpan\.org$/ } @{$conf->{author}})[0]);
	}
	my $result = prompt('Author: ', -menu => $authors, -default => $default, 'tty');
	$result =~ /^(.*\S)\s*<([^>]*)>$/;
	$conf_repo->{user}{name}  = $1;
	$conf_repo->{user}{email} = $2;
	if($conf_repo->{user}{name} ne $def_user ||
	   $conf_repo->{user}{email} ne $def_email) {
		Config::INI::Writer->write_file($conf_repo, "${repo}/.git/config");
	}
}

__END__

=head1 NAME

ghclone.pl - Clone with user configuration

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut
