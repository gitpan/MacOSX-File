#
# $Id: Makefile.PL,v 0.10 2002/01/06 13:57:12 dankogai Exp dankogai $
#

$^O =~ /darwin/o or die "$^O is not darwin!";

use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

makemorefiles();

sub makemorefiles{
    warn "-- Making MoreFiles a priori\n";
    chdir 'MoreFiles';
    system 'make';
    chdir '..';
    warn "-- Making MoreFiles: done\n";
}

WriteMakefile(
    'NAME'		=> 'MacOSX::File',
    'VERSION_FROM'	=> 'File.pm', # finds $VERSION
    'PREREQ_PM'		=> {}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'File.pm', # retrieve abstract from module
       AUTHOR     => 'Dan Kogai <dankogai@dan.co.jp>') : ()),
);
