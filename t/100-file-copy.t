use Test;

use File::Copy;

plan *;

# use some new test files and directories
my $f1 = './t/f1';
spurt $f1, "some text";
my $f2 = './t/f2';
spurt $f2, "some text";
# a non-existent file
my $f3 = './t/f3';
my $d0 = './t/A';
my $d1 = './t/A/B';
mkdir $d1;
# a non-existent directory
my $d2 = './t/A/B/C';

# delete all of them when finished
END {
    unlink $f1;
    unlink $f2;
    unlink $f3;
    shell "rm -rf $d0";
}

# the existing test directory
# DO NOT MODIFY IT WITH THESE TESTS
constant $tdir = './t/test-doc';

#===== the actual tests:

# file to existing file
lives-ok { copy $f1, $f2; }

# file to non-existing file
lives-ok { copy $f1, $f3; }

# file to existing file
dies-ok { copy $f1, $f3, :createonly; }

# dir to existing file
dies-ok { copy $d2, $f1; }

done-testing;
