/*
 * $Id: filecopy.c,v 0.50 2002/01/18 18:30:50 dankogai Exp dankogai $
 */

#include <Files.h>
#include "common/util.c"

static UniCharCount 
Utf8toUni(UInt8 *src, UniChar *dst){
    UniChar       ucs2;
    UInt8         c1, c2, c3;
    UniCharCount  nchar = 0;

    for(; *src != '\0'; src++, nchar++){
	if (*src < 0x80) {     /* 1 byte */
	    ucs2 = *src;
	}
	else if (*src < 0xE0){ /* 2 bytes */
	    c1 = *src++; c2 = *src;
	    ucs2 = ((c1 & 0x1F) << 6) | (c2 & 0x3F);
	}else{                 /* 3 bytes */
	    c1 = *src++; c2 = *src++; c3 = *src;
	    ucs2 = ((c1 & 0x0F) << 12) | ((c2 & 0x3F) << 6)| (c3 & 0x3F);
	}
	*dst++ = ucs2;
    }
    return nchar;
}

static OSErr 
newfile(char *path, FSRef *FSrefp, FSCatalogInfo *Catp){
    FSRef         parentFS;
    UniCharCount  namelen;
    UniChar       name[256];
    Boolean       isDir = 1;
    OSErr err;

    if (err = FSPathMakeRef(dirname(path), &parentFS, &isDir)){
	return err;
    }
    if ((namelen = Utf8toUni(colon2slash(basename(path)), name)) == 0){
	return fnfErr;
    }
    err = FSCreateFileUnicode(&parentFS, 
			      namelen, name,
			      kFSCatInfoSettableInfo, Catp,
			      FSrefp, NULL);
    return err;
}

#define MINCOPYBUFSIZE 4096
static UInt8 MinCopyBuf[MINCOPYBUFSIZE];

typedef struct{
    UInt64  s;
    UInt8  *b;
} copybuf ;

static copybuf CopyBuf = { MINCOPYBUFSIZE, MinCopyBuf };

#ifdef FILECOPY_DEBUG
#define fpf fprintf
#else
static void fpf(FILE *fp, ...){};
#endif

static void
freebuf() {
    if(CopyBuf.b != MinCopyBuf){ 
	fpf(stderr, "free(CopyBuf.b = 0x%x)\n", CopyBuf.b);
	free(CopyBuf.b); 
	CopyBuf.s = MINCOPYBUFSIZE; CopyBuf.b = MinCopyBuf;
    }
}

static UInt64
setbufsiz(UInt64 newsize){
    UInt8 *newb;
    fpf(stderr, "Request %qd: Current %qd\n", newsize, CopyBuf.s);
    if (CopyBuf.s < newsize){ /* (re|m)alloc only when larger */
	if (CopyBuf.b == MinCopyBuf){ /* first time */
	    if ((newb = (UInt8 *)malloc(newsize)) != NULL){
		fpf(stderr, "malloc ok (0x%x)\n", newb);
		CopyBuf.b = newb; CopyBuf.s = newsize;
	    }else{
		fpf(stderr, "malloc failed! using MinCopyBuf\n");
		CopyBuf.b = MinCopyBuf; CopyBuf.s = MINCOPYBUFSIZE;
	    }
	}else{
	    if ((newb = (UInt8 *)realloc((UInt8 *)CopyBuf.b, newsize))
		!= NULL)
	    {
		fpf(stderr, "realloc ok (0x%x)\n", newb);
		CopyBuf.b = newb;
	    }else{
		fpf(stderr, "remalloc failed! using old value.\n");
	    }
	}
    }
    fpf(stderr, "Buffer size == %qd\n", CopyBuf.s);
    return CopyBuf.s;
}

static OSErr 
copyfork(HFSUniStr255 *forkName, FSRef *src, FSRef *dst){
    OSErr err, eof;
    SInt16 srcfork, dstfork;
    UInt32 bufsize;
    ByteCount nread;
   
    if (err = FSOpenFork(src, forkName->length, forkName->unicode,
			 fsRdPerm, &srcfork)){ 
	fpf(stderr, "Cannot open src. fork\n");
	return err; 
    }
    if (err = FSOpenFork(dst, forkName->length, forkName->unicode,
			 fsWrPerm, &dstfork)){ 
	fpf(stderr, "Cannot open dst. fork\n");
	FSCloseFork(srcfork); /* src fork is already open ! */
	return err; 
    }
    while(1){
	eof = FSReadFork(srcfork, fsAtMark, 0, CopyBuf.s, CopyBuf.b, &nread);
	if (err = FSWriteFork(dstfork, fsAtMark, 0, nread, CopyBuf.b, NULL)){
	    goto CLOSE;
	}
	if (eof){ goto CLOSE; }
    }
	
 CLOSE:
    FSCloseFork(srcfork);
    FSCloseFork(dstfork);
    return err;
}

#define min(x, y) ((x) < y) ? (x) : (y)

static OSErr
filecopy(char *src, char *dst, UInt64 maxbufsize, int preserve){
    OSErr err;
    FSCatalogInfo srcCat, dstCat;
    FSRef srcFS, dstFS;
    HFSUniStr255 forkName;
    UTCDateTime  now;
    
    if (err = FSPathMakeRef(src, &srcFS, NULL)) 
    { return err; }
    
    if (err = FSGetCatalogInfo(&srcFS, kFSCatInfoGettableInfo, &srcCat, 
			       NULL, NULL, NULL))
    { return err; }

    bcopy(&srcCat, &dstCat, sizeof(FSCatalogInfo));

    if (err = newfile(dst, &dstFS, &dstCat)){ 
	fpf(stderr, "Cannot Create File %s\n", dst);
	return err; 
    }
    if (srcCat.dataLogicalSize){
	setbufsiz(min(srcCat.dataPhysicalSize, maxbufsize));
	FSGetDataForkName(&forkName); 
	if (err = copyfork(&forkName, &srcFS, &dstFS))
	{ return err; }
    }
    if (srcCat.rsrcLogicalSize){
	setbufsiz(min(srcCat.rsrcPhysicalSize, maxbufsize));
	FSGetResourceForkName(&forkName);
	if (err = copyfork(&forkName, &srcFS, &dstFS))
	{ return err; }
    }
    freebuf();
    if (preserve){
	err =  FSSetCatalogInfo(&dstFS, kFSCatInfoSettableInfo, &srcCat);
    }
    return err;
}

/*
static OSErr 
filemove(char *src, char *dst){
}
*/

#ifndef _INC_PERL_XSUB_H

int main(int argc, char **argv){
    OSErr         err;
    int preserve = (argc > 3) ? 1 : 0;
    if (argc > 2){
	err = filecopy(argv[1], argv[2], 0, preserve);
	fpf(stderr, "Err = %d, preserve = %d\n", err, preserve);
    }
}

#endif