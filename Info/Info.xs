/*
 * $Id: Info.xs,v 0.10 2002/01/06 13:57:12 dankogai Exp dankogai $
 */

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

static int
not_here(char *s)
{
    croak("%s not implemented on this architecture", s);
    return -1;
}

#include "common/util.c"
#include "common/macdate.c"
#include <Finder.h>

/* #define CATALOGINFONEEDED kFSCatInfoGettableInfo */
#define CATALOGINFONEEDED (kFSCatInfoNodeFlags|kFSCatInfoCreateDate|kFSCatInfoContentMod|kFSCatInfoFinderInfo)

static AV *
xs_getfinfo(char *path){
    FSRef  Ref;
    FSSpec Spec;
    FSCatalogInfo Catalog;
    FInfo  *finfo = (FInfo *)(&Catalog.finderInfo);

    AV*   av = newAV();
    OSErr err;

    if (err = FSPathMakeRef(path, &Ref, NULL)){
	return av;
    }
    
    /* 
     * to make it work with both directory and file, we
     * use FSGetCatalogInfo() instead of FSGetFInfo()
     */

    if (err = FSGetCatalogInfo(&Ref,
			       CATALOGINFONEEDED,
			       &Catalog,
			       NULL,
			       NULL,
			       NULL))
    {
	return av;
    }

    av_push(av, newSVpv((char *)&Ref, sizeof(Ref)));
    av_push(av, newSViv(Catalog.nodeFlags));

    if (kFSNodeIsDirectoryMask & Catalog.nodeFlags){
	av_push(av, newSVpv("", 0));
	av_push(av, newSVpv("", 0));
    }else{
	av_push(av, newSVpv(Catalog.finderInfo, 4));
	av_push(av, newSVpv(Catalog.finderInfo+4, 4));
    }

    av_push(av, newSViv(finfo->fdFlags));

    /*
    av_push(av, newSViv(UTCDateTime2time_t(&Catalog.createDate)));
    av_push(av, newSViv(UTCDateTime2time_t(&Catalog.contentModDate)));
    */
    av_push(av, newSVnv(UDT2D(&Catalog.createDate)));
    av_push(av, newSVnv(UDT2D(&Catalog.contentModDate)));

    return av;
 }

static int
xs_setfinfo(
    SV   *svref,
    unsigned int  nodeFlags,
    unsigned char *type,
    unsigned char *creator,
    unsigned int  fdFlags,
    double        ctime,
    double        mtime,
    char          *path
    )
{
    FSRef  Ref, *rp;
    FSSpec Spec;
    FSCatalogInfo Catalog;
    FInfo  *finfo = (FInfo *)(&Catalog.finderInfo);

    OSErr err;
    if (path != NULL && strlen(path) != 0){
	if (err = FSPathMakeRef(path, &Ref, NULL)){
	    return seterr(err);
	}else{
	    rp = &Ref;
	}
    }else{
	rp = (FSRef *)SvPV_nolen(svref);
    }
    
    Catalog.nodeFlags = nodeFlags;
    finfo->fdType    = char2OSType(type);
    finfo->fdCreator = char2OSType(creator);
    finfo->fdFlags =  fdFlags;
    D2UDT(ctime, &Catalog.createDate);
    D2UDT(mtime, &Catalog.contentModDate);

    if (err = FSSetCatalogInfo(rp, CATALOGINFONEEDED, &Catalog)){
	return seterr(err);
    }

    FSRef2FSSpec(rp, &Spec);

    err = (nodeFlags & kFSNodeLockedMask) ?
	FSpSetFLock (&Spec) : FSpRstFLock (&Spec);
    return seterr(err);
}

MODULE = MacOSX::File::Info		PACKAGE = MacOSX::File::Info	

AV *
xs_getfinfo(path)
    char *path;
    CODE:
        RETVAL = xs_getfinfo(path);
    OUTPUT:
	RETVAL

int
xs_setfinfo(svref, nodeFlags, type, creator, fdFlags, ctime, mtime, path)
    SV   *svref;
    unsigned int  nodeFlags;
    unsigned char *type;
    unsigned char *creator;
    unsigned int  fdFlags;
    double        ctime;
    double        mtime;
    char          *path;
    CODE:
        RETVAL = xs_setfinfo(svref, nodeFlags, type, creator, 
			     fdFlags, ctime, mtime, path);
    OUTPUT:
        RETVAL
