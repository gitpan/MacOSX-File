/*
 * $Id: util.c,v 0.10 2002/01/06 13:57:13 dankogai Exp dankogai $
 */


#include <Files.h>

static int
seterr(int err)
{
    SV *OSerr;
    if (err){
	OSerr = perl_get_sv("MacOSX::File::OSErr", 1);
	sv_setiv(OSerr, err);
    }
    return err;}

#define  char2OSType(s) (OSType)(s[0]<<24|s[1]<<16|s[2]<<8|s[3])

static char *
dirname(char *path){
    static unsigned char result[1024];
    int i, len;
    if (strchr(path, '/') == NULL){
	return ".";
    }else{
	for (i = 0; path[i] != '\0'; i++){
	    if (path[i] == '/'){ len = i; }
	}
	strncpy(result, path, len);
    }
    return result;
}

static char *
basename(char *path){
    static unsigned char result[1024];
    int i, len;
    if (strchr(path, '/') == NULL){
	return path;
    }else{
	for (i = 0; path[i] != '\0'; i++){
	    if (path[i] == '/'){ len = i; }
	}
	strcpy(result, path+len+1);
    }
    return result;
}

static unsigned char *
str2pstr(unsigned char *str, unsigned char *pstr){
    pstr[0] = strlen(str);
    strncpy(pstr+1, str, pstr[0]);
    return pstr;
}

#define FSRef2FSSpec(r, s) FSGetCatalogInfo((r),kFSCatInfoNone,NULL,NULL,(s),NULL)

static OSErr 
path2FSSpec(char *path, FSSpec *sp){
    FSRef         Ref;
    OSErr         err;
    FSCatalogInfo info;
    Str255        name;

    if ((err = FSPathMakeRef(path, &Ref, NULL)) == noErr){
	/* Path Exists */
	return FSRef2FSSpec(&Ref,sp);

    }else if (err == fnfErr){
	/* 
         * See if the path of its parent directory exists
	 */
	if (err = FSPathMakeRef(dirname(path), &Ref, NULL)){
	    return err; 
	}
	/*
	 * Path does not exist but its parent does
         * So we make a new FSSpec based upon that
	 */
	if (err = FSGetCatalogInfo (&Ref,
				    kFSCatInfoVolume|kFSCatInfoNodeID,
				    &info,
				    NULL,
				    NULL,
				    NULL)
	    )
	{
	    return err;
	}
	str2pstr(basename(path), name);
	if ((err = FSMakeFSSpec (info.volume, info.nodeID, name, sp))
	     == fnfErr)
	{
	    return noErr;
	}
    }
    return err;
}
