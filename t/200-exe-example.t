use Test;

use File::Copy;
use File::Copy::Utils :list-files, :strip-dirs;
use Proc::Easier;

my $debug = 0;

# use some new test files and directories
lives-ok {
    cmd "examples/simple-file-copy.raku g";
}, "Run example program";

# delete all of them when finished
END {
    if not $debug {
        cmd "rm -rf d1";
        cmd "rm -rf d2";
    }
}

done-testing;
