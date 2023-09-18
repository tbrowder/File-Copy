unit module File::Copy;

use File::Find;

#`{{

'cp' should act like *nix cp

Possible copy LHS (from), RHS (to) situations:

  Without :createonly

    LHS        RHS        RESULT
    ===        ===        ======
    from.f     to.f       copy from.f -> to.f
               !to.e      copy from.f -> to.f
               to.d       copy from.f -> to.d/from.f

    from.d     to.f       THROW
               to.d       mkdir to.d/from.d.basename
                          recursively copy from.d/* -> to.d/from.d.basename/*
               !to.e      mkdir to.d
                          recursively copy from.d/* -> to.d/*

    !from.e    Any        THROW

}}

=begin pod

B<cp> copies files and directories from one location to another.

If the C<$from> location is a directory, all files and directories
B<below> C<$from> will be copied to the C<$to> location. A fatal error
will be thrown (by the core) if C<$from> is a directory and C<$to> is a file.

Errors will also be thrown (by the core) if the permissions in either location are
not appropriate for the selected operation.

Existing files B<will> be overwritten unless the C<:c> (C<:createonly>) option
is selected.

=end pod

my $debug = 0;

sub cp(IO() $from, 
       IO() $to, 
       Bool :$c, 
       Bool :$r, 
       Bool :$i, 
       Bool :$v,
       Bool :$debug,
      ) is export {
   
    # take care of the easy part first
    if $from.f and not $to.d {
        # the core should take care of this okay
        say "Copying file '$from' to file '$to'." if $v;
        my $createonly = $c ?? True !! False;
        $from.copy($to, :$createonly);
        return;
    }

    if $from.d and $to.f {
        # the core should fail on this
        $from.copy($to);
        return;
    }

    if $from.d and $to.d {
        # collect all files and dirs in $from and
        # transfer them as individual files, making
        # subdirs as needed in $to

        # must consider the options recurse, interactive, createonly, verbose
        my @frompaths;
        if not $r {
            note "Collecting paths (non-recursively) from directory '$from'." if $v;
            @frompaths = find :dir($from), :!recursive;
        }
        else {
            note "Collecting paths (recursively) from directory '$from'." if $v;
            @frompaths = find :dir($from);
        }

        # cycle through the paths and ensure all subdirs are created
        # in the new directory
        my $subpath;
        my $topath;
        PATH: for @frompaths -> $frompath {
            # transform the from path to the new path 
            $subpath = $frompath;
            $subpath ~~ s/$from\///;
            $topath = "$to/$subpath";

            #note "DEBUG: full path: |$path|";
            # say the subdir part;
            #note "DEBUG: subdir path: |$subdir|";
            #exit;

            if $r and $frompath.IO.d {
                # create the subdir in the $to directory
                say "Creating directory '$topath'." if $v;
                mkdir $topath;
            }
            else {
                say "Copying file '$frompath' to '$topath'." if $v;
                if $topath.IO.f {
                    if $c {
                        # createonly takes precedence
                        say "Skipping existing file '$topath'" if $v;
                        next PATH;
                    }
                    unless $i {
                        # overwrite is default
                        say "Overwriting existing file '$topath'" if $v;
                        copy $frompath, $topath;
                        next PATH;
                    } 
                    my $repeat = 1;
                    while $repeat {
                        my $res = prompt "Overwrite the existing file '$topath'(y/N)? ";
                        if $res ~~ /:i y/ {
                            say "Overwriting '$topath'...";
                            $repeat = 0;
                        }
                        elsif $res ~~ /:i n/ {
                            say "Skipping this file...";
                            next PATH;
                        }
                        else {
                            say "'$res' is an invalid response.";
                        }
                    }
                }
                copy $frompath, $topath;
            }
        }
        return
    }

    if $from.f and $to.d {
        my $topath = "$to/{$from.basename}";
        say "Copying file '$from' to directory '$to'." if $v;
        my $createonly = $c ?? True !! False;
        copy $from, $topath, :$createonly;
        return;
    }

    die q:to/HERE/;
        FATAL: Unexpected situation.
               Please file an issue with as much detail as possible.
        HERE
}

=finish

#| Copy a file to an existing directory
multi sub copy(IO::Path $from where {$from.e and $from.f},
               IO::Path $to is copy where {$to.e and $to.d},
               :$createonly,
               --> True
              ) is export {

    note "DEBUG-2: trying to copy file to a dir" if 1;

    my $topath = "{$to.absolute}/{$from.basename}".IO;
    copy $from.absolute, $topath, :$createonly;

    =begin comment
    # this doesn't work
    copy $from, "{$to}/{$from.basename}", :$createonly;
    =end comment
    =begin comment
    # get the parent directory of the file
    my $dir = $from.dirname;
    # the basename, too
    my $f = $from.basename;
    my @fils;
    my @dirs;
    for $dir.IO.dir -> $p {
        if $p.d {
            next;
            #@dirs.push: $p;
        }
        else {
            @fils.push($p) if $p.Str eq $from.Str;
        }
    }
    for @fils -> $ff {
        note "    $ff" if $debug;
        copy $ff, "{$to}/{$ff.basename}";
    }
    =end comment
}

#| Copy a directory's files and directories to another directory
multi sub copy(IO::Path $from where {$from.e and $from.d},
               IO::Path $to where {$to.e and $to.d},
               :$createonly,
               --> True
              ) is export {

    note "DEBUG-3: trying to copy dir to a dir" if 1;

    =begin comment
    my $F = CPath.new: $from;
    $F.copy($to, :$createonly);
    =end comment

    if 1 or $debug {
        my $f = $from.d ?? "$from/" !! $from;
        my $t = $to.d ?? "$to/" !! $to;
        note "DEBUG: from: '$f'; to: '$t'";
    }

    # copy from a dir and its files to a dir:
    #   from/           to/
    #   from/a          to/a
    #   from/A/         to/A/
    #          b        to/A/b
    #          c        to/A/c
    #        D/         to/D/
    #          e        to/D/e

    # the recursive example from the docs:
    # search for routine 'dir'
    # important: use $ instead of @ for lazyness??
    #            see module IO::Dir for hints
    # important: ensure the starting dir path is absolute!!
    #   e.g.:
    #   sub MAIN($dir = '.'.IO.d.absolute) {
    #       my @todo = $dir.IO;
    #       while @todo {
    #           for @todo.pop.dir -> $path {
    #               say $path.Str;
    #               @todo.push: $path if $path.d;
    #           }
    #       }
    #   }

    my @fils;
    my @dirs;
    for $from.IO.dir -> $p {
        if $p.d {
            @dirs.push: $p;
        }
        else {
            @fils.push: $p;
        }
    }

    note "DEBUG: from dir: '$from'" if $debug;
    note "DEBUG: files:" if $debug;

    #| Copy all the files in $from first
    for @fils -> $f {
        note "    $f" if $debug;
        copy $f, "{$to}/{$f.basename}";
    }

    note "DEBUG: dirs:" if $debug;
    #| Then recursively copy the sub directories
    for @dirs -> $d {
        $*ERR.say: "debug: copy $d, {$to}/{$d.basename}" if $debug;
        my $todir = "{$to}/{$d.basename}";
        mkdir $todir;
        copy $d, "{$to}/{$d.basename}".IO;
    }
    #die "DEBUG exit" if $debug;

}

=finish

# for future use:
sub rename($from, $to, :$force, :$prompt) is export(:rename) {
    move($from, $to, :$force, :$prompt) is export(:move);
}
sub move($from, $to, :$force, :$prompt) is export(:move) {
}
sub rmdir($dir, :$force, :$prompt) is export(:rmdir) {
}
