/*
 * $Id: util.c,v 0.30 2002/01/12 20:30:26 dankogai Exp dankogai $
 */

#include <sys/param.h>
#include <Files.h>

static int
seterr(int err)
{
    SV *OSerr;
    if (err){
	OSerr = perl_get_sv("MacOSX::File::OSErr", 1);
	sv_setiv(OSerr, err);
    }
    return err;
}

#define  char2OSType(s) (OSType)(s[0]<<24|s[1]<<16|s[2]<<8|s[3])

static char *
dirname(char *path){
    static unsigned char result[MAXPATHLEN];
    int i, len;
    if (strchr(path, '/') == NULL){
	return ".";
    }else{
	for (i = 0; path[i] != '\0'; i++){
	    if (path[i] == '/'){ len = i; }
	}
	strncpy(result, path, len);
	result[len] = '\0'; /* make sure you terminate the string! */
    }
    return result;
}

static char *
basename(char *path){
    static unsigned char result[MAXPATHLEN];
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
