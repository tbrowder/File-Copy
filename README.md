[![Build Status](https://travis-ci.com/tbrowder/File-Copy.svg?branch=master)](https://travis-ci.com/tbrowder/File-Copy)

# File::Copy

This module aims to enhance the built-in routine `copy` to handle
*file-to-directory* and *directory-to-directory* copying operations.

Future plans are to provide enhanced versions of other built-in
routines such as: `move`, `rename`, and `rmdir`.

## Synopsis:


```
#!/usr/bin/env raku

use File::Copy;

# ...create some directories and files...
copy $file, $dir1;
copy $dir1, $dir2;
```

See the internal documentation in the terminal window
by entering:

```
$ p6doc File::Copy
```

CREDITS
=======

Thanks for help from IRC `#raku` friends:

+ `sena_kun` (for insights on implementing enhanced versions of built-in routines)
+ `tony-o` (for improving the `.travis.yml` file for faster testing)
+ `antoniogamez` (for insights on advanced use of `Raku` (aka Perl 6))
+ `jmerelo` (for keeping us all focused on the big picture)

AUTHOR
======

Tom Browder, `<tom.browder@gmail.com>`

COPYRIGHT & LICENSE
===================

Copyright (c) 2019-2020 Tom Browder, all rights reserved.

This program is free software; you can redistribute it or modify
it under the same terms as Raku itself.

See that license [here](./LICENSE).
