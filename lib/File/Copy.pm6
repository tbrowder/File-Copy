unit module File::Copy;

use File::Find;

#|{{

B<copy> copies files and directories from one
location to another.

If the C<$from> location is acdirectory, all files
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

#| Copy file to dir
multi sub copy(IO::Path $from where *.f,
               IO::Path $to where $to.IO.d,
               :$create-dir,
               :$force,
               :$prompt,
              ) is export {
    my $f = $from.IO.basename;
    mkdir $to if $create-dir;
    $from.copy: $to;
}

multi sub copy(IO::Path $from where *.d, IO::Path $to, :$create-dir, :$force, :$prompt, :$debug) is export {

    #| Fail to copy a directory and its files to another file
    if $from.IO.d && $to.IO.f {
        die "FAILURE: Cannot copy a directory ($from) onto a file ($to)";
    }

    #| Copy file to directory
    if $from.IO.f && $to.IO.d {
        my $f = $from.IO.basename;
        copy $f, "$to/$f";
        return;
    }

    #| Copy directory and its files to another directory
    my $err1 = 0;
    my $err2 = 0;
    ++$err1 unless $from.IO.d;
    ++$err2 unless $to.IO.d;
    if $err1 || $err2 {
        note "ERROR: Location '$from' is not a directory" if $err1;
        note "ERROR: Location '$to' is not a directory" if $err2;
        die "FATAL: Too many errors.";
    }

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
