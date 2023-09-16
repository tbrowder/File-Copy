#!/usr/bin/env raku

use lib "../lib";
use File::Copy;
use Temp::Path;

if not @*ARGS {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go

    Demonstrates use of 'File::Copy's exported routine 'cp.

    HERE
    exit;    
}

my $d1 = make-temp-dir;
my $d2 = make-temp-dir;

