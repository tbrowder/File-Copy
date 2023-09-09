unit module File::Copy:ver<0.0.2>;

use File::Find;

#`{{

Copy should act like *nix cp

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

B<copy> copies files and directories from one location to another.

If the C<$from> location is a directory, all files and directories
B<below> C<$from> will be copied to the C<$to> location. A fatal error
will be thrown (by the core) if C<$from> is a directory and C<$to> is a file.

Errors will also be thrown (by the core) if the permissions in either location are
not appropriate for the selected operation.

Existing files B<will> be overwritten unless the C<:createonly> option
is selected.

=end pod

# the existing built-in method on class IO::Path
# updated to include my PR to fix Rakudo issue #
#
#   from: https://github.com/rakudo/rakudo/src/core.c/IO/Path.pm6
=begin comment
    method copy(IO::Path:D: IO() $to, :$createonly --> True) {
        self.d and $to.f and fail X::IO::Copy.new:
            :from($.absolute),
            :to($to.absolute),
            :os-error('cannot copy a directory to a file');

        $createonly and $to.e and fail X::IO::Copy.new:
            :from($.absolute),
            :to($to.absolute),
            :os-error(':createonly specified and destination exists');

        # XXX TODO: maybe move the sameness check to the nqp OP/VM
        nqp::if(
            nqp::iseq_s(
                (my $from-abs :=   $.absolute),
                (my $to-abs   := $to.absolute)),
            X::IO::Copy.new(:from($from-abs), :to($to-abs),
                :os-error('source and target are the same')).fail,
            nqp::copy($from-abs, $to-abs));

        CATCH { default {
            fail X::IO::Copy.new:
                :from($!abspath), :to($to.absolute), :os-error(.Str)
        }}
    }
=end comment

# the existing built-in routine
#    from: https://github.com/rakudo/rakudo/src/core.c/io_operators.pm6
#                   ...
# proto sub copy($, $, *%) {*}
# multi sub copy(IO() $from, IO() $to, :$createonly) {
#     $from.copy($to, :$createonly)
# }

my $debug = 0;

my class CPath is IO::Path {
    use nqp;

    method copy(IO::Path:D: IO() $to is copy, :$createonly --> True) {
    #method copy(IO::Path:D: IO() $to, :$createonly --> True) {
        nqp::if(
            $to.d,
            ($to.=add(self.basename))
        );

        nqp::if(
            $to.d,
            (nqp::die("FAILURE: \$to is still a directory"))
        );

        $createonly and $to.e and fail X::IO::Copy.new:
            :from($.absolute),
            :to($to.absolute),
            :os-error(':createonly specified and destination exists');

        # XXX TODO: maybe move the sameness check to the nqp OP/VM
        nqp::if(
            nqp::iseq_s(
                (my $from-abs := $.absolute),
                (my $to-abs   := $to.absolute)),
            X::IO::Copy.new(:from($from-abs), :to($to-abs),
                            :os-error('source and target are the same')).fail,
            nqp::copy($from-abs, $to-abs)
        );

        CATCH { default {
                      fail X::IO::Copy.new:
                      :from($.absolute), :to($to.absolute), :os-error(.Str)
                  }}
    }
}

my sub get-typ($p) {
    return 'dir' if $p.d;
    return 'fil' if $p.f;
    return 'unknown';
}

proto sub copy($, $, *%) {*}
multi sub copy(IO() $from, IO() $to, :$createonly) is export {
   
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
    }
    return;


#    if 1 or $debug {
    note "DEBUG: early return from my proto copy subroutine";
        my $ftyp = get-typ $from;
        my $ttyp = get-typ $to;
        note "  types: DEBUG: from: '$ftyp'; to: '$ttyp'";
#    }

    if $ftyp eq 'fil' and $ttyp eq 'dir' {
        # TODO use nqp::copy here!!!
        #die("FAILURE: \$from is a file and \$to is a directory");
        note("FAILURE: \$from is a file and \$to is a directory");
        # TODO for nqp::copy:
        #     ensure $to exists and is a dir
        #     ensure $from exists and is a file
        #     get the basename of $from
        #     construct the $to path by adding the file basename to it
        #     do the copy
    }
    if $ftyp eq 'dir' and $ttyp eq 'fil' {
        # TODO bail here to save the file
        note ("FAILURE: \$from is a directory and \$to is a file");
        #die("FAILURE: \$from is a directory and \$to is a file");
        # TODO for this situation
        #     use the failure msg form and throw it here
    }
    if $ftyp eq 'dir' and $ttyp eq 'dir' {
        # TODO use nqp::copy here!!!
        #die("FAILURE: \$from is a directory and \$to is a file");
        note("FAILURE: \$from is a directory and \$to is a file");
        # TODO for nqp::copy:
    }

    # may not need CPath after all since I don't seem to affect its behavior
    my $F = CPath.new: $from;
    $F.copy($to, :$createonly);
}

=finish

# from github/com/rakudo/rakudo PR #2043 bt @jkramer:
#   affecting file rakudo/rakudo/src/core/IO/Path.pm6:
# TODO 2020-10-19 need to update code for latest Raku master source!!
=begin comment
my class IO::Path is Cool does IO {
    # ...
    method copy(IO::Path:D: IO() $to is copy, :$createonly --> True) {
        nqp::if(
            $to.d,
            ($to.=add(self.basename))
        );
        # ...
    }
    #...
}
=end comment

#| Ensure attempting to copy a directory to a file throws
multi sub copy(IO::Path $from where {$from.e and $from.d},
               IO::Path $to where {$to.e and $to.f},
               :$createonly,
               --> True
              ) is export {
    note "DEBUG-1: trying to copy dir to a file" if 1;
    die "fix a better throw";
}

=begin comment
#| Copy a file to a file
multi sub copy(IO::Path $from where {$from.e and $from.f},
               IO::Path $to where *.f,
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
