use Test;
use Test::Output;

use File::Copy :ALL;

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
lives-ok { tree $tdir; }

done-testing;

exit;

# file to non-existent file
lives-ok { Copy $f1, $f3; }

# file to existent file
dies-ok { Copy $f1, $f2; }

# dir to existing file
dies-ok { Copy $d2, $f1; }

# rm an existing dir
lives-ok { Rmdir $d1; }


done-testing;

