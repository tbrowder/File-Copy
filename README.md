[![Actions Status](https://github.com/tbrowder/File-Copy/workflows/linux/badge.svg)](https://github.com/tbrowder/File-Copy/actions) [![Actions Status](https://github.com/tbrowder/File-Copy/workflows/macos/badge.svg)](https://github.com/tbrowder/File-Copy/actions) [![Actions Status](https://github.com/tbrowder/File-Copy/workflows/windows/badge.svg)](https://github.com/tbrowder/File-Copy/actions)

TITLE
=====

**File::Copy** - Provides the essential functions of the POSIX `cp` command

SYNOPSIS
========



    use File::Copy; # exports routine 'cp'
    cp "/usr/share/fonts/", "/home/fonts"; # the trailing slash is not required

DESCRIPTION
===========

Exported function `cp` copies files and directories from one location to another. Its behavior is intended to be very similar to the POSIX `cp` utility program.

If the `$from` location is a directory, it and all its top-level files will copied to the `$to` location. A fatal error will be thrown if `$from` is a directory and `$to` is a file. If the recursive option (`:r`) is used, all below the `from` path will be copied.

Errors will also be thrown if the permissions in either location are not appropriate for the selected operation.

Existing files **will** be overwritten unless the `:createonly` option is selected.

Current named options:

  * `:i` (or `:interactive`) - Asks permission to overwrite an existing file.

  * `:r` (or `:recursive`) - When the source (`$from`) is a directory, copy recursively.

  * `:c` (or `:createonly`) - Existing files will <not> be overwritten, but notice will be given.

  * `:v` (or `:verbose`) - Informs the user about copying details.

See an example Raku program using this module in the module package repository at [examples](examples).

AUTHOR
======

Tom Browder <tbrowder@acm.org>

COPYRIGHT AND LICENSE
=====================

© 2023 Tom Browder

This library is free software; you may redistribute it or modify it under the Artistic License 2.0.

