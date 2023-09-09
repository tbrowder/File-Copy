[![Actions Status](https://github.com/tbrowder/File-Copy/workflows/linux/badge.svg)](https://github.com/tbrowder/File-Copy/actions) [![Actions Status](https://github.com/tbrowder/File-Copy/workflows/macos/badge.svg)](https://github.com/tbrowder/File-Copy/actions) [![Actions Status](https://github.com/tbrowder/File-Copy/workflows/windows/badge.svg)](https://github.com/tbrowder/File-Copy/actions)

WARNING: THIS MODULE IS EXPERIMENTAL
====================================

FILES AND DIRS MAY BE LOST WITHOUT NOTICE
=========================================

THIS MODULE IS BEING REMOVED FROM CPAN
======================================

Description
-----------

`copy` copies files and directories from one location to another. Its behavior is intended to be very similar to the POSIX `cp` program.

If the `$from` location is a directory, it and all its contents will be recursively copied to the `$to` location. A fatal error will be thrown if `$from` is a directory and `$to` is a file.

Errors will also be thrown if the permissions in either location are not appropriate for the selected operation.

Existing files **will** be overwritten unless the `:createonly` option is selected.

