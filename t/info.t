#
# $Id: info.t,v 0.10 2002/01/06 13:57:13 dankogai Exp dankogai $
#
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
use strict;
my $Debug = $ARGV[0] || 0;
BEGIN { plan tests => 10 };

use MacOSX::File::Info;
ok(1); # If we made it this far, we're ok.

my $finfo = MacOSX::File::Info->get($0);
$finfo ? ok(1) : ok(0);

use Data::Dumper;
$Debug and print Dumper $finfo;

use File::Copy;
copy($0, "dummy");

$finfo->type('TEXT');
$finfo->creator('ttxt');
my  $attr = $finfo->flags("avbstclinmed");
$attr eq "avbstclinmed" ? ok(1) : ok(0);
$attr = $finfo->flags(-locked => 1);
$attr eq "avbstcLinmed" ? ok(1) : ok(0);
$finfo->nodeFlags == 1 ? ok(1) : ok(0);

setfinfo($finfo, "dummy") ? ok(1) : ok(0);
my $asked = askgetfileinfo("dummy");
$asked eq "avbstcLinmed" ? ok(1) : ok(0);
$Debug and warn $asked ;
$Debug and print Dumper $finfo;
unlink "dummy";
$! ? ok(1) : ok(0);
$Debug and warn $!;
$! = 0;
$finfo->unlock;
my $n = setfinfo($finfo, "dummy") ? ok(1) : ok(0);
$Debug and warn $n;
unlink "dummy" ? ok(1) : ok(0);
$Debug and warn $!;

$Debug or unlink "dummy";

sub askgetfileinfo{
    my $asked = qx(/Developer/Tools/GetFileInfo $_[0]);
    $asked =~ /^attributes: (\w+)/mi;
    return $1;
}
