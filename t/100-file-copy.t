use Test;
use Test::Output;

use File::Copy;

plan *;

# use some new test files and directories
my $f1 = 'f1';
spurt $f1, "some text";
my $f2 = 'f2';
spurt $f2, "some text";
# a non-existent file
my $f3 = 'f3';
my $d1 = 'A/B';
mkdir $d1;
# a non-existent directory
my $d2 = 'A/B/C';
# and delete all of them when finished
END {
    unlink $f1;
    unlink $f2;
    unlink $f3;
    shell "rm -rf $d1";
    shell "rm -rf $d2";
}

# the existing test directory
# DO NOT MODIFY IT WITH THESE TESTS
constant $tdir = 't/test-doc';

#===== the actual tests:

# file to existent file
lives-ok { copy $f1, $f2; }

# file to non-existent file
dies-ok { copy $f1, $f3; }

# dir to existing file
dies-ok { copy $d2, $f1; }

done-testing;
