package MacOSX::File;

use 5.6.0;
use strict;

our $RCSID = q$Id: File.pm,v 0.61 2002/01/28 07:43:35 dankogai Exp dankogai $;
our $VERSION = do { my @r = (q$Revision: 0.61 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

our $OSErr;
our $CopyErr;

sub strerr{
    require MacOSX::File::Constants;
    return &MacOSX::File::Constants::ResultCode->{$OSErr};
}

1;

__END__

=head1 NAME

MacOSX::File - A collection of modules to manipulate files on MacOS X

=head1 DESCRIPTION

MacOSX::File is a collection of modules that allows you to do what
binaries in  /Developer/Tools allows you to do directly via perl.
You can implement your own CpMac, MvMac, GetFileInfo and SetFile
without calling these binaries.

=head1 SUBMODULES

  MacOSX::File::Catalog    - Gets/Sets FSCatalogInfo Attributes
  MacOSX::File::Copy       - copy/move with HFS(+) attributes
  MacOSX::File::Info       - Gets/Sets File Attributes (Subset of ::Catalog)
  MacOSX::File::Spec       - Gets FSSpec Structure

=head1 SCRIPTS

  pcpmac     - CpMac reimplemented
  pmvmac     - MvMac reimplemented
  pgetfinfo  - GetFileInfo reimplemented
  psetfinfo  - SetFile reimplemented
  psync      - update copy utility, very reason I wrote this module

=head1 INSTALLATION

To install this module type the following:

   perl Makefile.PL
   make
   make test
   make install

=head1 DEPENDENCIES

This module requires MacOS X.  Develper kit is needed to "make
install".  To get binary distribution, check MacOSX-File-bindist
via CPAN.

=head1 COPYRIGHT AND LICENCE

Copyright 2002 Dan Kogai <dankogai@dan.co.jp>

This library is free software; you can redistribute it
and/or modify it under the same terms as Perl itself.

=cut
