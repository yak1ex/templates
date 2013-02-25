#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Std;
use Pod::Usage;

use Module::List;
use Text::Template;
use Data::Section -setup;
use YAML::Any;

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
);

my $CONF = $ENV{HOME}.'/.template.yaml';
my $conf = -r $CONF ? YAML::Any::LoadFile($CONF) : {};

my %opts;
getopts('a:A:hlk:', \%opts);
show_list() if exists $opts{l};
pod2usage(-verbosity => 2) if exists $opts{h};
pod2usage(-msg => 'Name not found', -verbose => 0, -exitval => 1) unless eval "require Software::License::$opts{k}";
my $author = $opts{A} || $conf->{author};
my $abstract = $opts{a};
my $license = ('Software::License::'.$opts{k})->new({ holder => $author });

while(my $file = shift)
{
	my ($ext) = ($file =~ /\.([^.]*)$/);
	my $guard = uc($file);
	$guard =~ s/\W/_/;
	open my $fh, '>', $file or die;
	my $tmpl = __PACKAGE__->section_data($extmap{$ext});
	my $template = Text::Template->new(TYPE => 'STRING', SOURCE => $$tmpl );
	print $fh $template->fill_in(HASH => {
		file => $file,
		author => $author,
		abstract => $abstract,
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
 ***********************************************************************/
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

use strict;
use warnings;

use Getopt::Std;
use Pod::Usage;

my %opts;
getopts('h', \%opts);
pod2usage(-verbosity => 2) if exists $opts{h};
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

use strict;
use warnings;

1;
\__END__

\=head1 NAME

{$file} - {$abstract}

\=head1 SYNOPSIS

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

Specify license key

=item C<-A>

Specify author

=back

=cut
