package MacOSX::File::Copy;

require 5.005_62;
use strict;
use warnings;
use Carp;

our $RCSID = q$Id: Copy.pm,v 0.30 2002/01/12 20:30:25 dankogai Exp dankogai $;
our $VERSION = do { my @r = (q$Revision: 0.30 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
our $DEBUG;

require Exporter;
require DynaLoader;
use AutoLoader;

our @ISA = qw(Exporter DynaLoader);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use MacOSX::File::Copy ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
		 copy
		 move
		 );

bootstrap MacOSX::File::Copy $VERSION;

our $MINBUFFERSIZE     = 512;
our $DEFAULTBUFFERSIZE = 1024*1024;
our $MAXBUFFERSIZE     = $DEFAULTBUFFERSIZE*64;
# Preloaded methods go here.

use Errno;
sub copy{
    my ($src, $dst) = @_;
    my $bufsize = defined($_[2]) ? 
	$_[2] < $MINBUFFERSIZE ? $MINBUFFERSIZE :
	    $_[2] > $MAXBUFFERSIZE ? $MINBUFFERSIZE : $_[2]
		: $DEFAULTBUFFERSIZE;
    unless(-f $src){
	$MacOSX::File::OSErr = -43; # fnfErr;
	$! = &Errno::ENOENT;
	return;
    }
    if (-e $dst){
	unlink $dst or return;
    }
    if (my $err = xs_copy($src, $dst, $bufsize)){
	return;
    }else{
	return 1;
    }
}

sub move{
    use File::Basename;
    my ($src, $dst) = @_;    
    # 1st we make sure that $src is file
    -f $src or ($! = &Errno::ENOENT and return);
    my $srcdev = (stat(_))[0];
    # then we make sure $dst is clear
    -e $dst and (unlink $dst or return);
    # then we make sure destination directory does exist
    -d dirname($dst) or ($! = &Errno::ENOENT and return);
    my $dstdev = (stat(_))[0];

    if ($srcdev == $dstdev){ # same volume
	if (my $err = xs_move($src, $dst)){
	    $DEBUG and warn $err;
	    return;
	}else{
	    $DEBUG and warn $err;
	    return 1;
	}
    }else{ # cross-device; copy then delete
	copy($src, $dst) and unlink $src;
    }
}

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

MacOSX::File::Copy - copy() on MacOS X

=head1 SYNOPSIS

  use MacOSX::File::Copy;
  copy($srcpath, $dstpath [,$buffersize]);
  move($srcpath, $dstpath);

=head1 DESCRIPTION

MacOSX::File::Copy provides copy() and move() as in File::Copy.  Unlike
File::Copy (that also comes with MacOS X), MacOSX::File::Copy preserves
resouce fork and Finder attirbutes.  Consider this as a perl version
of CpMac and MvMac which comes with MacOS X developer kit.

=head2 EXPORT

copy() and move()

=head1 AUTHOR

Dan Kogai <dankogai@dan.co.jp>

=head1 BUGS

Files w/ Unicode names fail to copy.  This is due to the fact that
MoreFiles only supports FSSpec-based operations while Unicode names
really requires purely FSRef-based operations (in other words,
FSSpec-free).

I am planning to rerite Copy.xs so that it is FSSpec-free.  Give
me a little bit more time....

=head1 SEE ALSO

L<File::Copy>
L<CpMac(1)>
L<MvMac(1)>

=head1 COPYRIGHT

Copyright 2002 Dan Kogai <dankogai@dan.co.jp>

This library is free software; you can redistribute it
and/or modify it under the same terms as Perl itself.

This modules uses MoreFiles of Apple Sample Code unchanged.
L<http://developer.apple.com/samplecode/Sample_Code/Files/MoreFiles.htm>

Copyright 1992-2001 Apple Computer, Inc.
Portions copyright 1995 Jim Luther
All rights reserved.

=cut
