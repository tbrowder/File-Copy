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

say "Creating two directories: \$d1 and \$d2";
my $d1 = make-temp-dir;
my $d2 = make-temp-dir;
say "Creating some source file: \$f1 and \$f2";
my $text1 = "some text";
my $text2 = "some other text";
my $f1 = "$d1/f1";
mkdir "$d1/d11";
my $f2 = "$d1/d11/f2";
spurt $f1, $text1;
spurt $f2, $text2;
say "File \$f1 contents: '{$f1.IO.slurp}'";
say "File \$f2 contents: '{$f2.IO.slurp}'";



