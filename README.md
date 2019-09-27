[![Build Status](https://travis-ci.org/tbrowder/File-Copy.svg?branch=master)](https://travis-ci.org/tbrowder/File-Copy)

# File::Copy

This module aims to enhance the built-in routine `copy` to handle
*file-to-directory* and *directory-to-directory* copying operations.

Future plans are to provide enhanced versions of other built-in
routines such as: `move`, `rename`, and `rmdir`.

## Synopsis:

~~~
#!/usr/bin/env perl6

use File::Copy;

# ...create some directories and files...
copy $file, $dir1;
copy $dir1, $dir1;
~~~

See the internal documentation in the terminal window
by entering:

~~~
$ p6doc File::Copy
~~~

CREDITS
=======

Thanks for help from:

+ @sena_kun
+ @tony-o
+ @antoniogamez
+ @jmerelo

AUTHOR
======

Tom Browder, `<tom.browder@gmail.com>`

COPYRIGHT & LICENSE
===================

Copyright (c) 2019 Tom Browder, all rights reserved.

This program is free software; you can redistribute it or modify
it under the same terms as Perl 6 itself.

See that license [here](./LICENSE).
