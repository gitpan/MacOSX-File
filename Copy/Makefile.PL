#
# $Id: Makefile.PL,v 0.60 2002/01/27 16:43:18 dankogai Exp $
#
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

WriteMakefile
    (
     NAME              => 'MacOSX::File::Copy',
     VERSION_FROM      => 'Copy.pm',
     PREREQ_PM         => {}, # e.g., Module::Name => 1.1
     LIBS	=> qq(),
     LDDLFLAGS  => qq(-bundle -flat_namespace -undefined suppress -framework Carbon),
     INC	=> qq(-I../ -I/Developer/Headers/FlatCarbon),
    );
