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

use Config::Tiny;
use YAML::Any;
use IO::Prompt;

sub to_str
{
	return $_[0]{name}.' <'.$_[0]{email}.'>';
}

my %opts;
getopts('h', \%opts);
pod2usage(-verbose => 2) if exists $opts{h};
pod2usage(-msg => 'At least one repo MUST be specified', -verbose => 0, -exitval => 1) if ! @ARGV;

my $CONF = $ENV{HOME}.'/.template.yaml';
my $conf = -r $CONF ? YAML::Any::LoadFile($CONF) : {};
my $authors = [map { $_->{name}.' <'.$_->{email}.'>' } @{$conf->{author}}];
my ($gitname) = map { s/\@users.noreply.github.com//; $_ } grep { /\@users.noreply.github.com/ } map { $_->{email} } @{$conf->{author}};
my $conf_user = Config::Tiny->read("$ENV{HOME}/.gitconfig");
my $def_user  = $conf_user->{user}{name};
my $def_email = $conf_user->{user}{email};

while(my $line = shift) {
	my ($url, $repo) = split(/=/, $line);
	if(! defined($repo)) {
		($repo = $url) =~ s,.*\/,,;
	}
	if($url !~ m,^http(|s)://,) { # not absolute URL
		if($url =~ /[0-9a-f]{32}/) { # gist hash
			$url = "https://gist.github.com/${gitname}/${url}.git";
		} else {
			$url = "https://github.com/${gitname}/${url}.git";
		}
	}
	warn "$repo already exists" and next if -e $repo;
	my $default = to_str($conf->{author}[0]);
	if(-f "${repo}/dist.ini" || -f "${repo}/Makefile.PL" || -f "${repo}/Build.PL") { # Perl module
		$default = to_str((grep { $_->{email} =~ /\@cpan\.org$/ } @{$conf->{author}})[0]);
	}
	my $result = prompt('Author: ', -menu => $authors, -default => $default, '-tty');
	$result =~ /^(.*\S)\s*<([^>]*)>$/;
	my ($name, $email) = ($1, $2);
	my ($conf_arg);
	$conf_arg .= "-c \"user.name=$name\" " if $name ne $def_user;
	$conf_arg .= "-c \"user.email=$email\" " if $email ne $def_email;
	system "git clone $conf_arg $url $repo";
}

__END__

=head1 NAME

ghclone.pl - Clone with user configuration

=head1 SYNOPSIS

ghclone.pl C<repos>...

ghclone.pl -h

=head1 DESCRIPTION

Clone from github or gist with author setting from ${HOME}/.template.yaml

=head1 OPTIONS

=over 4

=item C<repos>...

Gist hashes and/or github repository names.
You can specify the working folder name as C<repos>=C<working_folder>

=back

=head1 CONFIGURATION

Choices for author are made from ${HOME}/.template.yaml

The yaml file should have entries as the followings:

  author:
    - name: Name1
      email: Email1
    - name: Name2
      email: Email2

The name of the first entry matching with C<gitname>@users.noreply.github.com is used as repo user.

=cut
