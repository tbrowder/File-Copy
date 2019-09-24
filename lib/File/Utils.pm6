unit module File::Utils;

#`{{

 Thanks to @antoniogomez and his Documentable module!

}}

#| Get a list of files inside a directory.
sub list-files ($dir) is export(:list-files) {
         gather for dir($dir) {
             take .Str if not .d;
             take slip sort list-files $_ if .d;
         }
}

#| This function returns a List of IO objects. Each IO object is one
#| file in $dir.
sub recursive-dir($dir) is export(:recursive-dir) {
    my @todo = $dir;
    gather while @todo {
        my $d = @todo.shift;
        next if ! $d.IO.e;
        for dir($d) -> $f {
            if $f.f {
                take $f;
            }
            else {
                @todo.append: $f.path;
            }
        }
    }
}

#| Get a resource file from the installation or the development
#| repository source.
sub zef-path($filename) is export(:zef-path) {
    my $filepath = "resources/$filename".IO.e ?? "resources".IO.add($filename).path !! %?RESOURCES{$filename}.IO.path;
    die "Path to $filename not found" unless $filepath;
    return $filepath;
}


sub tree($dir = '.', :$debug) is export(:tree) {
    constant $sp = '  ';
    my $level = 0;
    sub tab($level = 0) { my $tab = $level ?? $sp x $level !! ''}
    # from the docs on routine 'dir'
    my @dirlist;
    my %dirlist;
    my $last-dir = 0;

    my @curr-dir;
    @curr-dir.push: $dir;

    my @todo = $dir.IO;
    while @todo {
        for @todo.pop.dir -> $path {
           if $path.d {
               @todo.push: $path;

               @dirlist.push: "{$path.Str}/";

               $last-dir = $path;
               %dirlist{$path} = [];
           }
           else {
               @dirlist.push: "{$path.Str}";
               %dirlist{$last-dir}.push: $path;
           }
        }
    }

    .say for @dirlist.sort;

    say "#===== %dirlist (IO)";
    for %dirlist.keys.sort -> $d {
        say "{$d.Str}/";
        my @f = @(%dirlist{$d}).sort;
        say "---{$_.Str}" for @f;
    }
}
