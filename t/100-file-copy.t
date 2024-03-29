use Test;

use File::Copy;
use File::Copy::Utils :list-files, :strip-dirs;
use Proc::Easier;

my $debug = 0;

# use some new test files and directories
my $f1 = './t/f1';
spurt $f1, "some text";

my $f2 = './t/f2';
spurt $f2, "some more text";
# a non-existent file
my $f3 = './t/f3';

my $d0 = './t/A';

cmd "rm -rf $d0" if 1 and $d0.IO.d;
my $d1 = './t/A/B'.IO;
mkdir $d1;
# a non-existent directory
my $d2 = './t/A/C';

# delete all of them when finished
END {
    if not $debug {
        unlink $f1;
        unlink $f2;
        unlink $f3;
        cmd "rm -rf $d0";
        cmd "rm -rf $d1";
    }
}

# the existing test directory
# DO NOT MODIFY IT WITH THESE TESTS
my $tdir = './t/test-doc'.IO;

#===== the actual tests:

# file to existing file
lives-ok { 
    cp $f1, $f2; 
}, "cp file to existing file";
is $f2.IO.slurp, $f1.IO.slurp, "copied file is identical to original";

# file to non-existing file
lives-ok { 
    cp $f1, $f3; 
}, "cp file to non-existing file";
is $f3.IO.slurp, $f1.IO.slurp, "copied file is identical to original";

# file to existing file
die "FATAL: file \$f3 does not exist" if not $f3.IO.f;
dies-ok { 
    cp $f1, $f3, :createonly;
}, "Throw with :createonly and don't overwrite an existing file";

# dir to dir
# cp one dir to another
die "FATAL: dir \$tdir does not exist" if not $tdir.IO.d;
die "FATAL: dir \$d1 does not exist" if not $d1.IO.d;
lives-ok { 
    cp $tdir, $d1 , :r;
}, "cp contents of one dir to another";

# compare dirs with is-deeply
my @f1 = list-files("$d1").sort;
#note "output of copied-to-dir \@f1: {@f1.raku}";
@f1 = strip-dirs $d1, @f1;
#note "stripped-dirs output of copied-to-dir \@f1: {@f1.raku}";

my @f2 = list-files("$tdir").sort;
#note "output of \@f2: {@f2.raku}";
@f2 = strip-dirs $tdir, @f2;
#note "stripped-dirs output of \@f2: {@f2.raku}";
is-deeply @f1, @f2, "Ensure dir-to-dir cp works and both dirs\' contents are identical";

# dir to existing file
die "FATAL: dir \$d1 does not exist" if not $d1.IO.d;
die "FATAL: file \$f1 does not exist" if not $f1.IO.f;

# TODO fix problem of trying to cp dir to a file, should not touch the existing file!!
dies-ok { 
    cp $d1, $f1; 
}, "Throw when trying to cp dir to an existing file";
is $f1.IO.f, True, "file should be untouched from attempt to cp a dir to it";

#done-testing;
#=finish

# TODO fix the bad case
# file to existing dir
die "FATAL: file \$f1 does not exist" if not $f1.IO.f;
die "FATAL: dir \$d1 does not exist" if not $d1.IO.d;
lives-ok { 
    cp $f1, $d1; 
}, "cp file to directory works";
#say $f1.IO.slurp;
#say "$d1/{$f1.IO.basename}".IO.slurp;
is $f1.IO.slurp, "$d1/{$f1.IO.basename}".IO.slurp, "files are identical";

done-testing;
