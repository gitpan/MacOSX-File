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
#include "filecopy.c"


static int
xs_copy(char *src, char *dst, int maxbufsize, int nocopycat){
    OSErr err = filecopy(src, dst, maxbufsize, nocopycat);
    return seterr(err);
}

/* */

MODULE = MacOSX::File::Copy		PACKAGE = MacOSX::File::Copy

PROTOTYPES: ENABLE

int
xs_copy(src, dst, maxbufsize, nocopycat)
    char *src;
    char *dst;
    int maxbufsize;
    int nocopycat;
    CODE:
        RETVAL = xs_copy(src, dst, maxbufsize, nocopycat);
    OUTPUT:
	RETVAL
