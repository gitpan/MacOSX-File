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

#define NEED2KNOW  kFSCatInfoVolume|kFSCatInfoNodeID|kFSCatInfoNodeFlags

/*
 * unlike pure-Carbonated functions,
 * MoreFiles functions hate colons in thier name field
 * in FSSpec that are fed as arguments.  There must be
 * replaced to '/'.  Then Darwin make it look like they
 * are colons (sigh).
 * So we define this function just for Copy.xs
 *
 */

static char *
colon2slash(char *str){
    char *p;
    for(p = str; *p != '\0'; p++){
	if (*p == ':') *p = '/';
    }
    return str;
}

static OSErr 
path2FSSpec(char *path, FSSpec *sp){
    OSErr         err;
    FSRef         Ref;
    FSCatalogInfo Catalog;
    Str255        fileName;

    if ((err = FSPathMakeRef(path, &Ref, NULL)) == noErr){
	/* Path Exists. OK. */
	return FSRef2FSSpec(&Ref,sp);
    }else if (err == fnfErr){
	/* Try its parent directory with new one */
	if (err = FSPathMakeRef(dirname(path), &Ref, NULL)){
	    return err;
	}
	if (err = FSGetCatalogInfo(&Ref, NEED2KNOW, &Catalog, 
				   NULL, NULL, NULL)){
	    return err;
	}
	/* Make sure dirname(path) is really a directory */
	if (Catalog.nodeFlags & kFSNodeIsDirectoryMask){
	    str2pstr(colon2slash(basename(path)), fileName);
	    err = FSMakeFSSpec(Catalog.volume, Catalog.nodeID, fileName, sp);
	    if (err == fnfErr) { err = noErr; }
	}else{
	    err = bdNamErr;
	}
    }
    return err;
}

static int
xs_copy(char *src, char *dst, unsigned int bufsize){
    FSSpec srcSpec, dstSpec;
    Str255 copyName;
    OSErr err;
    void *buf;
    if (bufsize != 0){
	New(0, buf, bufsize, char);
	if (buf == NULL){
	    bufsize = 0;
	}
    }else{
	buf = NULL;
    }
    if (err = path2FSSpec(src, &srcSpec)){
	return seterr(err);
    }
    if (err = path2FSSpec(dirname(dst), &dstSpec)){
	return seterr(err);
    }
    str2pstr(colon2slash(basename(dst)), copyName);
    err = FSpFileCopy(&srcSpec, &dstSpec, copyName, buf, bufsize, 1);
    if (buf != NULL) { Safefree(buf); };
    return seterr(err);
}

static int
xs_move(char *src, char *dst){
    FSRef dstRef;
    Str255 dstName;
    FSSpec srcSpec, dstSpec;
    FSCatalogInfo dstInfo;
    OSErr err;

    if (err = path2FSSpec(src, &srcSpec)){
	return seterr(err);
    }
    if (err = path2FSSpec(dst, &dstSpec)){
	return seterr(err);
    }
    return seterr( FSpCatMove(&srcSpec, &dstSpec));
 }

MODULE = MacOSX::File::Copy		PACKAGE = MacOSX::File::Copy		
PROTOTYPES: ENABLE

int
xs_copy(from, to, bufsize)
    char *from;
    char *to;
    unsigned int  bufsize;
    CODE:
        RETVAL = xs_copy(from, to, bufsize);
    OUTPUT:
	RETVAL

int
xs_move(from, to)
    char *from;
    char *to;
    unsigned int  bufsize;
    CODE:
        RETVAL = xs_move(from, to);
    OUTPUT:
	RETVAL
