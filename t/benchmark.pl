#!/usr/local/bin/perl
#
# $Id: benchmark.pl,v 0.50 2002/01/18 18:30:51 dankogai Exp dankogai $
#

use lib qw(blib/arch blib/lib);
use MacOSX::File::Info;
use MacOSX::File::Catalog;
use File::stat ();
use Benchmark;

my $count = $ARGV[0] || 1024;
$MacOSX::File::Info::DEBUG = $ARGV[1];

timethese($count, {
    'CORE::stat'            => sub { my $stat = CORE::lstat($0) },
    'File::stat'            => sub { my $stat = File::stat::lstat($0) },
    'MacOSX::File::Info'    => sub { my $info = getfinfo($0) },
    'MacOSX::File::Catalog' => sub { my $catalog = getcatalog($0) },
});
