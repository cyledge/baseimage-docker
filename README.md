# cyLEDGE Base Image

Base image to be used as source (Dockerfile:FROM) for other images.
It is based on the well tested [Phusion Baseimage](http://phusion.github.io/baseimage-docker/).
Applause for the baseimage-docker contributors!

Though the file structure is evolved many tweaks and optimizations are still used from the original images.
Also the whole my_init/runit stuff is still the same.




## RTFM

Please dive into the nature of this image by reading the [README of phusion/base-image](https://github.com/phusion/baseimage-docker/blob/567a53db24b1b5e47c7aa41a8444011cd4bb99cd/README.md)


## Building

Please use (and maybe read through before) the `build.py` script to build this image. It handles rewriting of `Dockerfile` for different Ubuntu releases.
