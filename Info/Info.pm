package MacOSX::File::Info;

=head1 NAME

MacOSX::File - Get (HFS) File Attributes

=head1 SYNOPSIS

  use MacOSX::File::Info;
  $finfo = MacOSX::File::Info->get($path);
  $finfo->type('TEXT');
  $finfo->creator('ttxt');
  $finfo->flags(-invisible => 1);
  $finfo->set;

=head1 DESCRIPTION

This module implements what /Developer/Tools/{GetFileInfo,SetFile}
does within perl.

=cut

require 5.005_62;
use strict;
use warnings;
use Carp;

our $RCSID = q$Id: Info.pm,v 0.10 2002/01/06 13:57:12 dankogai Exp dankogai $;
our $VERSION = do { my @r = (q$Revision: 0.10 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

require Exporter;
require DynaLoader;
use AutoLoader;

our @ISA = qw(Exporter DynaLoader);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use MacOSX::File::Info ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.

=head2 EXPORT

Subs: getfinfo(), setfinfo()

fdFlags Constants: 
kIsAlias, kIsInvisible, kHasBundle, kNameLocked, kIsStationery,
kHasCustomIcon, kHasBeenInited, kHasNoINITs, kIsShared, 
kIsHiddenExtention, kIsOnDesk,

nodeFlags Constants:
kFSNodeLockedMask, kFSNodeResOpenMask, kFSNodeDataOpenMask,
kFSNodeIsDirectoryMask, kFSNodeCopyProtectMask, kFSNodeForkOpenMask

DateTimeUtils.h

=cut

our %EXPORT_TAGS = ( 'all' => [ qw(

) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
		 getfinfo
		 setfinfo

		 kIsAlias
		 kIsInvisible
		 kHasBundle
		 kNameLocked
		 kIsStationery
		 kHasCustomIcon
		 kHasBeenInited
		 kHasNoINITs
		 kIsShared
		 kIsHiddenExtention 
		 kIsOnDesk          
		 kFSNodeLockedMask
		 kFSNodeResOpenMask
		 kFSNodeDataOpenMask
		 kFSNodeIsDirectoryMask
		 kFSNodeCopyProtectMask
		 kFSNodeForkOpenMask

		 );

bootstrap MacOSX::File::Info $VERSION;

# Preloaded methods go here.

# constants for FdFlags from <Finder.h>
use constant kIsAlias           => 0x8000;
use constant kIsInvisible       => 0x4000;
use constant kHasBundle         => 0x2000;
use constant kNameLocked        => 0x1000;
use constant kIsStationery      => 0x0800;
use constant kHasCustomIcon     => 0x0400;
use constant kHasBeenInited     => 0x0100;
use constant kHasNoINITs        => 0x0080;
use constant kIsShared          => 0x0040;
use constant kIsHiddenExtention => 0x0010;
use constant kIsOnDesk          => 0x0001;

# kIsHiddenExtention corresponds to 'E' attribute of
# /Developer/Tools/SetFile command
# but there is no corresponding constant in <Finder.h> !

# constants for nodeFlags from <Files.h>
# only kFSNodeLockedMask is relevant, however.
use constant kFSNodeLockedMask      => 0x0001;
use constant kFSNodeResOpenMask     => 0x0004;
use constant kFSNodeDataOpenMask    => 0x0008;
use constant kFSNodeIsDirectoryMask => 0x0010;
use constant kFSNodeCopyProtectMask => 0x0040;
use constant kFSNodeForkOpenMask    => 0x0080;

=head1 METHODS

=item $finfo = MacOSX::File::Info->get($path);

=item $finfo = getfileinfo($path);

Constructs MacOSX::File::Info from which you can manipulate file
attributes.  On failure, it returns undef and $MacOSX::File::OSErr
is set. 

=cut

sub getfinfo{
    my ($path) = @_;
    my $self = xs_getfinfo($path);
    @$self or return;
    bless $self;
}

sub get{
    my ($class, $path) = @_;
    my $self = xs_getfinfo($path);
    @$self or return;
    bless $self => $class;
}

=item $finfo->set([$path]);

=item setfinfo($finfo, [$path]);

Sets file attributes of file $path.  If $path is omitted the file you
used to construct $finfo is used.  On success, it returns 1.  On
failure, it returns 0 and $MacOSX::File::OSErr is set.

Remember any changes to $finfo will not be commited until you call
these functions.

  ex)
    setfinfo(getfinfo("foo"), "bar"); 
    #Copies file attributes from foo to bar

=cut

sub setfinfo{
    my ($info, $path) = @_;
    return !xs_setfinfo(@$info, $path);
}

sub set{
    my ($self, $path) = @_;
    return !xs_setfinfo(@$self, $path);
}

=item $finfo->ref(), $finfo->nodeFlags(),

returns FSRef and nodeFlags of the file.  these attributes are read
only.  Use of these methods are unlikely except for debugging purpose.

=cut

# Construct accessor methods all at once

our %roField = (
		ref        => 0,
		nodeFlags  => 1,
		);

while(my($field, $index) = each %roField){
    no strict 'refs';
    *$field = sub { $_[0]->[$index] };
}

=item $finfo->type([$type]), $finfo->creator([$creator])

Gets and sets file type and creator, respectively.  Though they accept
strings longer than 4 bytes, only the first 4 bytes are used.

=item $finfo->ctime($ctime), $finfo->mtime($mtime)

Gets and sets file creation time and content modification time,
respectively.

  ex)
    $finfo->mtime(time());

Time is specified by seconds passed since Unix Epoch, January 1, 1970
00:00:00 UTC.  Beware this is different from Native Macintosh Epoch,
January 1, 1904, 00:00:00 UTC.  I made it that way because perl on
MacOSX uses Unix notion of Epoch.  (FYI MacPerl uses Mac notion of
Epoch). 

These methods accept fractional numbers since Carbon supports it.  It
also accepts numbers larger than UINT_MAX for the same reason.

=item $finfo->fdflags($fdflags)

Gets and sets fdflags values.  However, the use of this method is
discouraged unless you are happy with bitwise operation.  Use
$finfo->flags method instead.

  ex)
    $finfo->fdflags($finfo->fdflags | kIsInvisible)
    # makes the file invisible

=cut

our %rwField = (
		type              => 2,
		creator           => 3,
		fdFlags           => 4,
		ctime             => 5,
		mtime             => 6,
		);


while(my($field, $index) = each %rwField){
    no strict 'refs';
    *$field = sub  {
	my $self = shift;
	@_ and $self->[$index] = shift;
	$self->[$index];
    };
}


=item $flags = $finfo->flags($attributes), %flags = $finfo->flags(%attributes)

Gets and sets fdflags like /Developer/Tools/SetFile.  You can use
SetFile-compatible letter notation or more intuitive args-by-hash
notation.


When you use Attribute letters and corresponding swithes as
follows. Uppercase to flag and lowercase to flag.

    Letter Hash key         Description
    -----------------------------------
    [Aa]   -alias           Alias file
    [Vv]   -invisible       Invisible*
    [Bb]   -bundle          Bundle
    [Ss]   -system          System (name locked)
    [Tt]   -stationery      Stationary
    [Cc]   -customicon      Custom icon*
    [Ll]   -locked          Locked
    [Ii]   -inited          Inited*
    [Nn]   -noinit          No INIT resources
    [Mm]   -shared          Shared (can run multiple times)
    [Ee]   -hiddenx         Hidden extension*
    [Dd]   -desktop         Desktop*

Attributes with asterisk can be applied to folders and files.  Any
other can be applied to files only.

  ex)
    $attr = $finfo->flags("avbstclinmed"); 
    # unflag eveythinng
    $attr = $finfo->flags("L");
    # locks file with the rest of attributes untouched
    $attr = $finfo->flags(-locked => 1);
    # same thing but more intuitive

On scalar context, it returns attrib. letters.  On list context, it
returns hash notation shown above;

=cut

our %Key2Letter =
    qw(
       -alias      a
       -invisible  v
       -bundle     b
       -system     s
       -stationery t
       -customicon c
       -locked     l
       -inited     i
       -noinit     n
       -shared     m
       -hiddenx    e
       -desktop    d
       );
our %Letter2Key = reverse %Key2Letter;
our @Letters    = qw(a v b s t c l i n m e d);
our %key2Flags = 
    (
     -alias      =>  kIsAlias,
     -invisible  =>  kIsInvisible,
     -bundle     =>  kHasBundle,
     -system     =>  kNameLocked,
     -stationery =>  kIsStationery,
     -customicon =>  kHasCustomIcon,
     -locked     =>  kFSNodeLockedMask,
     -inited     =>  kHasBeenInited,
     -noinit     =>  kHasNoINITs,
     -shared     =>  kIsShared,
     -hiddenx    =>  kIsHiddenExtention,
     -desktop    =>  kIsOnDesk,
     );

sub locked{
    my $self = shift;
    return $self->nodeFlags & kFSNodeLockedMask;
}

sub lock{
    my $self = shift;
    $self->[1] = $self->nodeFlags | kFSNodeLockedMask;
    return $self;
}

sub unlock{
    my $self = shift;
    $self->[1] = $self->nodeFlags & ~kFSNodeLockedMask;
    return $self;
}

sub flags{
    my $self = shift;
    my ($fdFlags, $nodeFlags) = ($self->fdFlags, $self->nodeFlags);
    my %attrib = (
		  -alias      => $fdFlags & kIsAlias,
		  -invisible  => $fdFlags & kIsInvisible,
		  -bundle     => $fdFlags & kHasBundle,
		  -system     => $fdFlags & kNameLocked,
		  -stationery => $fdFlags & kIsStationery,
		  -customicon => $fdFlags & kHasCustomIcon,
		  -locked     => $nodeFlags & kFSNodeLockedMask,
		  -inited     => $fdFlags & kHasBeenInited,
		  -noinit     => $fdFlags & kHasNoINITs,
		  -shared     => $fdFlags & kIsShared,
		  -hiddenx    => $fdFlags & kIsHiddenExtention,
		  -desktop    => $fdFlags & kIsOnDesk,
		  );
    my $attrib = "";
    unless (@_){
	wantarray and return %attrib;
	for my $a (keys %attrib){
	    $attrib .= $attrib{$a} ? uc(Key2Letter{$a}) : Key2Letter{$a};
	}
	return $attrib;
    }
    if (scalar(@_) == 1){ # Letter notation
	for my $l (map { chr } unpack("C*", $_[0])){
	    $attrib{$Letter2Key{$l}} = ($l =~ tr/[A-Z]/[A-Z]/) ? 1 : 0;
	}
    }else{
	my %args = @_;
	for my $k (keys %args){
	    exists $attrib{$k} and $attrib{$k} = $args{$k};
	}
    }

    for my $k (keys %attrib){
	$k eq '-locked' ? $nodeFlags |= $attrib{$k} : $fdFlags |= $attrib{$k};
    }
    $self->fdFlags($fdFlags);
    $self->[1] = $nodeFlags;

    wantarray and return %attrib;
    defined wantarray or return;
    for my $l (@Letters){
	$attrib .=  $attrib{$Letter2Key{$l}} ? uc($l) : $l;
    }
    return $attrib;
}
# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__


=head1 AUTHOR

Dan Kogai <dankogai@dan.co.jp>

=head1 SEE ALSO

L<MacPerl>

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
