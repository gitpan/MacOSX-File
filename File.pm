package MacOSX::File;

require 5.6.0;
use strict;

our $RCSID = q$Id: File.pm,v 0.10 2002/01/06 13:57:12 dankogai Exp dankogai $;
our $VERSION = do { my @r = (q$Revision: 0.10 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

our %ResultCode = 
    qw(
       0  noErr
       -28  notOpenErr
       -33  dirFulErr
       -34  dskFulErr
       -35  nsvErr
       -36  ioErr
       -37  bdNamErr
       -38  fnOpnErr
       -39  eofErr
       -40  posErr
       -42  tmfoErr
       -43  fnfErr
       -44  wPrErr
       -45  fLckdErr
       -46  vLckdErr
       -47  fBsyErr
       -48  dupFNErr
       -49  opWrErr
       -50  paramErr
       -51  rfNumErr
       -52  gfpErr
       -53  volOffLinErr
       -54  permErr
       -55  volOnLinErr
       -56  nsDrvErr
       -57  noMacDskErr
       -58  extFSErr
       -59  fsRnErr
       -60  badMDBErr
       -61  wrPermErr
       -108  memFullErr
       -120  dirNFErr
       -121  tmwdoErr
       -122  badMovErr
       -123  wrgVolTypErr
       -124  volGoneErr
       -1300  fidNotFound
       -1301  fidExists
       -1302  notAFileErr
       -1303  diffVolErr
       -1304  catChangedErr
       -1306  sameFileErr
       -1401  errFSBadFSRef
       -1402  errFSBadForkName
       -1403  errFSBadBuffer
       -1404  errFSBadForkRef
       -1405  errFSBadInfoBitmap
       -1406  errFSMissingCatInfo
       -1407  errFSNotAFolder
       -1409  errFSForkNotFound
       -1410  errFSNameTooLong
       -1411  errFSMissingName
       -1412  errFSBadPosMode
       -1413  errFSBadAllocFlags
       -1417  errFSNoMoreItems
       -1418  errFSBadItemCount
       -1419  errFSBadSearchParams
       -1420  errFSRefsDifferent
       -1421  errFSForkExists
       -1422  errFSBadIteratorFlags
       -1423  errFSIteratorNotFound
       -1424  errFSIteratorNotSupported
       -5000  afpAccessDenied
       -5002  afpBadUAM
       -5003  afpBadVersNum
       -5006  afpDenyConflict
       -5015  afpNoMoreLocks
       -5016  afpNoServer
       -5020  afpRangeNotLocked
       -5021  afpRangeOverlap
       -5023  afpUserNotAuth
       -5025  afpObjectTypeErr
       -5033  afpContainsSharedErr
       -5034  afpIDNotFound
       -5035  afpIDExists
       -5037  afpCatalogChanged
       -5038  afpSameObjectErr
       -5039  afpBadIDErr
       -5042  afpPwdExpiredErr
       -5043  afpInsideSharedErr
       -5060  afpBadDirIDType
       -5061  afpCantMountMoreSrvre
       -5062  afpAlreadyMounted
       -5063  afpSameNodeErr
       );

our $OSErr;
sub strerr{
    return $ResultCode{$OSErr};
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

       MacOSX::File::Copy
       MacOSX::File::Info
       MacOSX::File::Spec

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

MacOSX::File::Copy uses MoreFiles of Apple Sample Code.
Copyright 1992-2001 Apple Computer, Inc.  Portions
copyright 1995 Jim Luther All rights reserved.
See the URI below on details

http://developer.apple.com/samplecode/Sample_Code/Files/MoreFiles.htm

=cut
