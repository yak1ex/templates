#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Std;
use Pod::Usage;

use Module::List;
use Text::Template;
use Data::Section -setup;
use YAML::Any;
use IO::Prompt;

sub show_list
{
	print join("\n", sort map { s/Software::License:://; $_ }
		keys %{Module::List::list_modules('Software::License::', { list_modules => 1 })}), "\n";
	exit;
} 

my %extmap = (
	h => 'h_hpp',
	hpp => 'h_hpp',
	c => 'c_cpp',
	cpp => 'c_cpp',
	pl => 'pl',
	pm => 'pm',
	psgi => 'psgi',
	rc => 'rc',
);

my $CONF = $ENV{HOME}.'/.template.yaml';
my $conf = -r $CONF ? YAML::Any::LoadFile($CONF) : {};

my %opts;
getopts('a:A:hlk:', \%opts);
show_list() if exists $opts{l};
pod2usage(-verbosity => 2) if exists $opts{h};
my $licensename = $opts{k} || prompt('License: ', '-tty');
pod2usage(-msg => 'License name not found', -verbose => 0, -exitval => 1) unless eval "require Software::License::$licensename";
my $authors = [map { $_->{name}.' <'.$_->{email}.'>' } @{$conf->{author}}];
my $author = $opts{A} || prompt('Author: ', -menu => $authors, -default => $authors->[0], '-tty');
my $license = ('Software::License::'.$licensename)->new({ holder => $author });

while(my $file = shift)
{
	my $abstract = $opts{a} || prompt('Abstract: ', '-tty');
	my ($ext) = ($file =~ /\.([^.]*)$/);
	my $guard = uc($file);
	$guard =~ s/\W/_/;
	open my $fh, '>', $file or die;
	my $tmpl = __PACKAGE__->section_data($extmap{$ext});
	my $template = Text::Template->new(TYPE => 'STRING', SOURCE => $$tmpl );
	print $fh $template->fill_in(HASH => {
		file => $file,
		author => \$author,
		abstract => \$abstract,
		guard => $guard,
		license => $license->name,
		url => $license->url,
	});
	close $fh;
}

__DATA__
__[ h_hpp ]__
/************************************************************************

    {$file}: {$abstract}

    Written by {$author}

    Distributed under the terms of {$license}
    See {$url}

    $Id$

 ***********************************************************************/

#ifndef {$guard}
#define {$guard}

#endif  /* defined {$guard} */
__[ c_cpp ]__
/************************************************************************

    {$file}: {$abstract}

    Written by {$author}

    Distributed under the terms of {$license}
    See {$url}

    $Id$

 ***********************************************************************/
__[ rc ]__
/************************************************************************

    {$file}: {$abstract}

    Written by {$author}

    Distributed under the terms of {$license}
    See {$url}

    $Id$

 ***********************************************************************/

#include <windows.h>
#include <commctrl.h>
#include <richedit.h>
#include "resource.h"

//
// Version Information resources
//
IDV_VERSIONINFO VERSIONINFO
    FILEVERSION     0,0,2000,0
    PRODUCTVERSION  0,0,2000,0
    FILEOS          VOS_NT_WINDOWS32
    FILETYPE        VFT_DLL | VFT_APP
    FILESUBTYPE     VFT2_UNKNOWN
    FILEFLAGSMASK   VS_FFI_FILEFLAGSMASK
#ifdef DEBUG
    FILEFLAGS       VS_FF_DEBUG | VS_FF_PRIVATEBUILD | VS_FF_PRERELEASE
#else
    FILEFLAGS       0x00000000
#endif
BEGIN
    BLOCK "StringFileInfo"
    BEGIN
        BLOCK "041103A4"
        BEGIN
            VALUE "CompanyName", "Yak!"
            VALUE "FileDescription", " - {$abstract}"
            VALUE "FileVersion", "Ver 0.00 (20000/00/00)"
            VALUE "InternalName", "{$file}"
            VALUE "LegalCopyright", "Written by Yak!"
            VALUE "OriginalFilename", "{$file}"
            VALUE "ProductName", "{$file}"
            VALUE "ProductVersion", "Ver 0.00 (2000/00/00)"
#ifdef DEBUG
            VALUE "PrivateBuild", "Debug build"
#endif
        END
    END
    BLOCK "VarFileInfo"
    BEGIN
        VALUE "Translation", 0x0411, 0x03A4
    END
END

__[ pl ]__
#!/usr/bin/perl
#
#   {$file}: {$abstract}
#
#   Written by {$author}
#
#   Distributed under the terms of {$license}
#   See {$url}
#
#   $Id$
#

use strict;
use warnings;

use Getopt::Std;
use Pod::Usage;

my %opts;
getopts('h', \%opts);
pod2usage(-verbosity => 2) if exists $opts\{h\};
pod2usage(-msg => '', -verbose => 0, -exitval => 1) if ...;

\__END__

\=head1 NAME

{$file} - {$abstract}

\=head1 SYNOPSIS

\=head1 DESCRIPTION

\=cut
__[ pm ]__
#
#   {$file}: {$abstract}
#
#   Written by {$author}
#
#   Distributed under the terms of {$license}
#   See {$url}
#
#   $Id$
#

use strict;
use warnings;

1;
\__END__

\=head1 NAME

{$file} - {$abstract}

\=head1 SYNOPSIS

\=head1 DESCRIPTION

\=cut
__[ psgi ]__
#!/usr/bin/env plackup
#
#   {$file}: {$abstract}
#
#   Written by {$author}
#
#   Distributed under the terms of {$license}
#   See {$url}
#
#   $Id$
#

use strict;
use warnings;

use Plack::Builder;

builder \{
	mount '/' => sub \{ return [404, ['Content-Type' => 'text/plain'], ['Not found']] \},
\\}

\__END__

\=head1 NAME

{$file} - {$abstract}

\=head1 SYNOPSIS

  plackup {$file}

\=head1 DESCRIPTION

\=cut
__END__

=head1 NAME

template.pl - Make skelton from template

=head1 SYNOPSIS

perl template.pl -h

perl template.pl -l

perl template.pl -k C<key> -A C<author> -a C<abstract>

=head1 DESCRIPTION

=head1 OPTIONS

=over 4

=item C<-h>

Show POD help

=item C<-l>

List license keys

=item C<-k>

Specify license key. If not specified, asked at the first time.

=item C<-A>

Specify author. If not specified, asked at the first time with default value specified in ~/.template.yaml.

=item C<-a>

Specify abstract. If not specified, asked for each file.

=back

=cut
