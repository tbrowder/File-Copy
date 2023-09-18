#!/usr/bin/env raku

use lib "../lib";
use File::Copy;
use Temp::Path;
use Proc::Easier;

if not @*ARGS {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go

    Demonstrates use of 'File::Copy's exported routine 'cp'.

    Note it does not test interactive options.

    HERE
    exit;    
}

say "Creating two directories: \$d1 and \$d2";
my $d1 = mkdir "d1";
my $d2 = mkdir "d2";
say "Creating source files: \$f1 and \$f2";
my $text1 = "some text";
my $text2 = "some other text";
my $f1 = "$d1/f1";
mkdir "$d1/d11";
my $f2 = "$d1/d11/f2";
spurt $f1, $text1;
spurt $f2, $text2;
say "File \$f1 is at '\$d1/f1'";
say "File \$f2 is at '\$d1/d11/f2'";

say "File \$f1 contents: '{$f1.IO.slurp.Str}'";
say "File \$f2 contents: '{$f2.IO.slurp.Str}'";
say "Copying first level children of \$d1 to \$d2";
cp $d1, $d2, :v;

say "Copying all children of \$d1 to \$d2";
cp $d1, $d2, :v, :r;

say "Copying all children of \$d1 to \$d2";
cp $d1, $d2, :r;
