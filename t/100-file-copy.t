use Test;

use File::Copy;
use File::Utils :list-files, :strip-dir;

my $debug = 0;

# use some new test files and directories
my $f1 = './t/f1';
spurt $f1, "some text";

my $f2 = './t/f2';
spurt $f2, "some more text";
# a non-existent file
my $f3 = './t/f3';

my $d0 = './t/A';
shell "rm -rf $d0" if 1 and $d0.IO.d;
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
        shell "rm -rf $d0";
    }
}

# the existing test directory
# DO NOT MODIFY IT WITH THESE TESTS
my $tdir = './t/test-doc'.IO;

#===== the actual tests:

# file to existing file
lives-ok { 
    copy $f1, $f2; 
}, "copy file to existing file";
is $f2.slurp, $f1.slurp, "copied file is identical to original";

# file to non-existing file
lives-ok { 
    copy $f1, $f3; 
}, "copy file to non-existing file";
is $f3.slurp, $f1.slurp, "copied file is identical to original";

# file to existing file
die "FATAL: file \$f3 does not exist" if not $f3.IO.f;
dies-ok { 
    copy $f1, $f3, :createonly;
}, "throw with :createonly and don't overwrite an existing file";

# dir to dir
# copy one dir to another
die "FATAL: dir \$tdir does not exist" if not $d1.IO.d;
die "FATAL: dir \$d1 does not exist" if not $d1.IO.d;
lives-ok { 
    copy $tdir, $d1 
}, "copy contents of one dir to another";

# compare dirs with is-deeply
my @f1 = list-files("$d1").sort;
@f1 = strip-dir $d1, @f1;
my @f2 = list-files("$tdir").sort;
@f2 = strip-dir $tdir, @f2;
is-deeply @f1, @f2, "Ensure dir to dir copy works and both dirs' contents are identical";

# dir to existing file
die "FATAL: dir \$d1 does not exist" if not $d1.IO.d;
die "FATAL: file \$f1 does not exist" if not $f1.IO.f;

# TODO fix problem of trying to copy dir to a file, should not touch the existing file!!
dies-ok { 
    copy $d1, $f1; 
}, "Throw when trying to copy dir to an existing file";
is $f1.IO.f, "file should be untouched from attempt to copy a dir to it";
#is (slurp $f2), (slurp $f1), "the file should be identical after the aborted attempt to copy a dir to it";

done-testing;
=finish

# TODO fix the bad case
# file to existing dir
die "FATAL: file \$f1 does not exist" if not $f1.IO.f;
die "FATAL: dir \$d1 does not exist" if not $d1.IO.d;
lives-ok { copy $f1, $d1; }
