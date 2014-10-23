#
# $Id: file.t,v 0.67 2004/05/03 14:53:30 dankogai Exp dankogai $
#
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
use strict;
my $Debug = $ARGV[0] || 0;
BEGIN { plan tests => 2 };

use MacOSX::File;
ok(1); # If we made it this far, we're ok.

$MacOSX::File::OSErr = 0;
MacOSX::File::strerr eq "noErr" ? ok(1) : ok(0);
