[![Actions Status](https://github.com/tbrowder/File-Copy/workflows/linux/badge.svg)](https://github.com/tbrowder/File-Copy/actions) [![Actions Status](https://github.com/tbrowder/File-Copy/workflows/macos/badge.svg)](https://github.com/tbrowder/File-Copy/actions) [![Actions Status](https://github.com/tbrowder/File-Copy/workflows/windows/badge.svg)](https://github.com/tbrowder/File-Copy/actions)

TITLE
=====

**File::Copy** - Provides the essential functions of the POSIX `cp` command

SYNOPSIS
========



    use File::Copy; # exports routine 'cp'
    cp "/use/share/fonts/", "/home/fonts"; # the trailing slash is not required

DESCRIPTION
===========

Exported function `cp` copies files and directories from one location to another. Its behavior is intended to be very similar to the POSIX `cp` utility program.

If the `$from` location is a directory, it and all its top-level files will copied to the `$to` location. A fatal error will be thrown if `$from` is a directory and `$to` is a file.

Errors will also be thrown if the permissions in either location are not appropriate for the selected operation.

Existing files **will** be overwritten unless the `:createonly` option is selected.

Current options:

  * `-i` 'interactive' - Asks permission to overwite an existing file.

  * `-r` 'recursive' - When the source is a directory, copy recursively.

  * `:createonly` - Existing files will <not> be overwritten, but notice will be given.

  * `-q` 'quiet' - Only fatal errors will be reported. 

