This contains a modified version of Makefile.windows found at 
    http://git.gitorious.org/~ylatuya/jhbuild/ylatuyas-jhbuild.git

It has been changed to have the jhbuild python module installed to 
/lib/python/site-packages/jhbuild/ and /bin/jhbuild to point to that 
instead of the current home directory.

This has been done to have a machine-wide jhbuild instead of a user-specific 
one that would have had to be an unwanted extra post-install step.

msys.patch includes several fixes for running jhbuild in an msys env.