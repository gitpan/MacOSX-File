#
# $Id: info.t,v 0.60 2002/01/27 16:43:21 dankogai Exp dankogai $
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
ok($finfo);

use Data::Dumper;
$Debug and print Dumper $finfo;

use File::Copy;
copy($0, "dummy");

$finfo->type('TEXT');
$finfo->creator('ttxt');
my $attr = $finfo->flags("avbstclinmed");
ok($attr eq "avbstclinmed");
$attr = $finfo->flags(-locked => 1);
ok($attr eq "avbstcLinmed");
ok($finfo->nodeFlags == 1);
ok(setfinfo($finfo, "dummy"));
my $asked = askgetfileinfo("dummy");
ok($asked eq "avbstcLinmed");
$Debug and warn $asked ;
$Debug and print Dumper $finfo;
unlink "dummy";
ok($!);
$Debug and warn $!;
$! = 0;
$finfo->unlock;
my $n;
ok(setfinfo($finfo, "dummy"));
$Debug and warn $n;
ok(unlink "dummy");
$Debug and warn $!;

$Debug or unlink "dummy";

sub askgetfileinfo{
    my $asked = qx(/Developer/Tools/GetFileInfo $_[0]);
    $asked =~ /^attributes: (\w+)/mi;
    return $1;
}
