unit module File::Copy:ver<0.0.2>;

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

Existing files B<will> be overwritten unless the C<:createonly> option
is selected.

=end pod

my $debug = 0;

my sub get-typ($p) {
    return 'dir' if $p.d;
    return 'fil' if $p.f;
    return 'unknown';
}

sub cp(IO() $from, IO() $to, :$createonly) is export {
   
    # take care of the easy part first
    if $from.f and not $to.d {
        # the core should take care of this okay
        $from.copy($to, :$createonly);
        return;
    }

    if $from.d and $to.f {
        # the core should fail on this after my PR
        $from.copy($to, :$createonly);
        return;
    }

    if $from.d and $to.d {
        # collect all files and dirs in $from and
        # transfer them as individual files, making
        # subdirs as needed in $to
        return;
    }
}

=finish
               :$createonly,
              ) is export {
    copy $from, $to, :$createonly;
}
=end comment


#| Copy a file to an existing directory
multi sub copy(IO::Path $from where {$from.e and $from.f},
               IO::Path $to is copy where {$to.e and $to.d},
               :$createonly,
               --> True
              ) is export {

    note "DEBUG-2: trying to copy file to a dir" if 1;

    =begin comment
    my $F = CPath.new: $from;
    $F.copy($to, :$createonly);
    =end comment

    =begin comment
    use nqp;
    nqp::if(
        $to.d,
        ($to.=add($from.basename))
    );
    =end comment

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
        note "debug: copy $d, {$to}/{$d.basename}" if $debug;
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
