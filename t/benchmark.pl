#!/usr/local/bin/perl
#
# $Id: benchmark.pl,v 0.60 2002/01/27 16:43:20 dankogai Exp $
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
