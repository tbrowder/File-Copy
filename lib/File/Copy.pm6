unit module File::Copy;

use File::Find;

#|{{

B<copy> copies files and directories from one
location to another.

If the C<$from> location is a directory, all files
and directories B<below> C<$from> will be copied to the
C<$to> location. A fatal error will be thrown
if C<$from> is a directory and C<$to> is a file.

Errors will also be thrown if the permissions in either
location are not appropriate for the selected operation.

No files will be overwritten unless the C<:force> option
is selected.

Alternatively, one can use the C<:prompt> option for
choosing individual files to be overwritten.

Examples:

    A/B/c

    copy "A", "D";


}}

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

#| Copy file to dir
multi sub copy(IO::Path $from where *.f,
               IO::Path $to where $to.IO.d,
               :$force,
              ) is export {
    mkdir $to if !$to.IO.d;
    $from.copy: $to;
}

#| Copy directory and its files to another directory
multi sub copy(IO::Path $from where *.d,
               IO::Path $to where *.d,
               :$force,
              ) is export {

    for $from.dirs -> $d {
        if $d.IO.d {
            note "DEBUG: \$from child '$d' is a directory" if $debug;
        }
        else {
            note "DEBUG: \$from child '$d' is a file";
        }
    }

    for $to.dirs -> $d {
        if $d.IO.d {
            note "DEBUG: \$from child '$d' is a directory";
        }
        else {
            note "DEBUG: \$from child '$d' is a file";
        }
    }
}

=finish

sub rename($from, $to, :$force, :$prompt) is export(:rename) {
    move($from, $to, :$force, :$prompt) is export(:move);
}
sub move($from, $to, :$force, :$prompt) is export(:move) {
}
sub rmdir($dir, :$force, :$prompt) is export(:rmdir) {
}
