#
# $Id: copy.t,v 0.10 2002/01/06 13:57:13 dankogai Exp dankogai $
#
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
use strict;
my $Debug = 0;
BEGIN { plan tests => 5 };

use MacOSX::File::Copy;
ok(1); # If we made it this far, we're ok.

copy($0, "dummy") ? ok(1) : ok(0);
copy($0, "dummy", 0) ? ok(1) : ok(0);
move("dummy", "dummy2") ? ok(1) : ok(0);
move("dummy2", "t/dummy2") ? ok(1) : ok(0);
unlink "t/dummy2";
