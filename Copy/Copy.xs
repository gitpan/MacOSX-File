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

static int
xs_copy(char *src, char *dst, unsigned int bufsize){
    FSSpec srcSpec, dstSpec;
    unsigned char  copyName[255];
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
    if (err =  path2FSSpec(dirname(dst), &dstSpec)){
	return seterr(err);
    }
    str2pstr(basename(dst), copyName);
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
    err =   FSpCatMove(&srcSpec, &dstSpec);
    return  seterr(err);
 }

MODULE = MacOSX::File::Copy		PACKAGE = MacOSX::File::Copy		

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
