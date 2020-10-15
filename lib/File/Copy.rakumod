unit module File::Copy:ver<2>;

use File::Find;

#`{{

Possible copy LHS (from), RHS (to) situations:

    LHS        RHS        RESULT
    ===        ===        ======
    from.f     to.f       copy from.f -> to.f
               !to.e      copy from.f -> to.f
               to.d       copy from.f -> to.d/from.f

    from.d     to.f       THROW
               to.d       copy from.d/*.f -> to.d/*
                          for from.d/*.d -> {
                              copy p.d ->
                          }
               !to.e      mkdir to.d; copy from.d/* -> to.d/*

    !from.e    Any        THROW

}}

=begin pod

B<copy> copies files and directories from one location to another.

If the C<$from> location is a directory, all files and directories
B<below> C<$from> will be copied to the C<$to> location. A fatal error
will be thrown if C<$from> is a directory and C<$to> is a file.

Errors will also be thrown if the permissions in either location are
not appropriate for the selected operation.

Existing files B<will> be overwritten unless the C<:createonly> option
is selected.

=end pod

# the existing built-in method on class IO::Path
#   from: https://github.com/rakudo/rakudo/src/core.c/IO/Path.pm6
#
#    method copy(IO::Path:D: IO() $to, :$createonly --> True) {
#        $createonly and $to.e and fail X::IO::Copy.new:
#            :from($.absolute),
#            :to($to.absolute),
#            :os-error(':createonly specified and destination exists');
#
#        # XXX TODO: maybe move the sameness check to the nqp OP/VM
#        nqp::if(
#            nqp::iseq_s(
#                (my $from-abs :=   $.absolute),
#                (my $to-abs   := $to.absolute)),
#            X::IO::Copy.new(:from($from-abs), :to($to-abs),
#                :os-error('source and target are the same')).fail,
#            nqp::copy($from-abs, $to-abs));
#
#        CATCH { default {
#            fail X::IO::Copy.new:
#                :from($!abspath), :to($to.absolute), :os-error(.Str)
#        }}
#    }

# the existing built-in routine
#    from: https://github.com/rakudo/rakudo/src/core.c/io_operators.pm6
#                   ...
# proto sub copy($, $, *%) {*}
# multi sub copy(IO() $from, IO() $to, :$createonly) {
#     $from.copy($to, :$createonly)
# }

my $debug = 0;

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
               IO::Path $to where {$to.e and $to.d},
               :$createonly,
               --> True
              ) is export {
    copy $from, "{$to}/{$from.basename}", :$createonly;
}

#| Copy a directory's files and directories to another directory
multi sub copy(IO::Path $from where {$from.e and $from.d},
               IO::Path $to where {$to.e and $to.d},
               :$createonly,
               --> True
              ) is export {

    if $debug {
        my $f = $from.d ?? "$from/" !! $from;
        my $t = $to.d ?? "$to/" !! $to;
        note "DEBUG: from: ''; to: ''";
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
    #   sub MAIN($dir = '.') {
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
            @dirs.append: $p;
        }
        else {
            @fils.append: $p;
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
    #| Then resursively copy the sub directories
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
