#
# $Id: Makefile.PL,v 0.10 2002/01/06 13:57:12 dankogai Exp dankogai $
#
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

WriteMakefile
    (
     NAME              => 'MacOSX::File::Info',
     VERSION_FROM      => 'Info.pm',
     PREREQ_PM         => {}, # e.g., Module::Name => 1.1
     LIBS	=> qq(-L../MoreFiles -lMoreFiles),
     LDDLFLAGS  => qq(-bundle -flat_namespace -undefined suppress -framework Carbon),
     INC	=> qq(-I../ -I/Developer/Headers/FlatCarbon),
    );
