#!/usr/bin/env raku

my $tdir = 't/test-doc'.IO;
my $da  = 'a';
my @todo = $tdir.dir;
#my @todo = $da.IO.dir;
my $n = 0;
my $N = 10;
while @todo {
    ++$n;
    my $from = @todo.pop;
    my $f = $from.d ?? "$from/" !! $from;
    say "from: $f";
    say "  (a directory)" if $from.d;
    say "  basename: '{$from.basename}'";
    say "  dirname: '{$from.dirname}'";
    say "  extension: '{$from.extension}'";
    say "  volume: '{$from.volume}'";
    say "  parent: '{$from.parent}'";
    @todo.push: $from if $from.d;
    last if $n > $N - 1;
}
say "Test complete with $N iterations.";

=finish

use lib <lib>;


use File::Copy;
use File::Utils :ALL;

my @paths;
my %paths;

my $tdir = 't/test-doc';

@paths = list-files $tdir; # , @paths, %paths;
my $n = @paths.elems;
say "#===== @paths (IO list); $n elements";
for @paths.sort -> $p {
    if $p.IO.d {
        say "{$p.Str}/";
    }
    else {
        say "{$p.Str}";
    }
}

my @paths2 = recursive-dir $tdir;
my $n2= @paths2.elems;
say "#===== @paths2 (IO list); $n2 elements";
for @paths.sort -> $p {
    if $p.IO.d {
        say "{$p.Str}/";
    }
    else {
        say "{$p.Str}";
    }
}

=finish

for %paths.keys.sort -> $p {
    say "{$p.Str}/";
    my @p = @(%paths{$p});
    for @p.sort -> $f {
        say "{$f.Str}";
    }
}

say "#===== tree (IO list)";
tree "t/test-doc";

=finish

#my @f = list-files "t/test-doc";
for @f -> $io {
    my $b  = $io.basename.Str;
    my $bc = $b.chars;

    my $p  = $io.Str;
    my $pc = $p.chars;

    if $io.d {
        say "{$p}/";
    }
    else {
        # substitute spaces for the dir
        my $n = $pc - $bc;
        my $spaces = ' ' x $n;
        #say "{$spaces}{$b}";
        say "{$p}";
    }
}

exit;

tree "t/test-doc";

copy 'a', 'b';
