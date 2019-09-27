use Test;

use File::Copy;
use File::Utils :list-files, :strip-dir;

plan 8;

# use some new test files and directories
my $f1 = './t/f1';
spurt $f1, "some text";
my $f2 = './t/f2';
spurt $f2, "some text";
# a non-existent file
my $f3 = './t/f3';

my $d0 = './t/A';
my $d1 = './t/A/B'.IO;
mkdir $d1;
# a non-existent directory
my $d2 = './t/A/C';

# delete all of them when finished
END {
    if 1 {
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
lives-ok { copy $f1, $f2; }
is (slurp $f2), (slurp $f1);

# file to non-existing file
lives-ok { copy $f1, $f3; }
is (slurp $f3), (slurp $f1);

# file to existing file
dies-ok { copy $f1, $f3, :createonly; }

# dir to existing file
dies-ok { copy $d2, $f1; }

# file to existing dir
lives-ok { copy $f1, $d2; }

# dir to dir
# copy one dir to another
copy $tdir, $d1;

# compare dirs with is-deeply
my @f1 = list-files("$d1").sort;
@f1 = strip-dir $d1, @f1;
my @f2 = list-files("$tdir").sort;
@f2 = strip-dir $tdir, @f2;
is-deeply @f1, @f2;
