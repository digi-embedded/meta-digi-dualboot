OpenEmbedded/Yocto Digi Embedded Dual Boot layer
================================================

This layer provides support for Digi Embedded Yocto (DEY) dual boot system for
Yocto Digi's BSP layers.

This layer depends on the following layer:

https://github.com/digi-embedded/meta-digi


Supported Platforms
-------------------

  * All Digi ConnectCore platforms


Installation
------------
1. Install Digi Embedded Yocto distribution

    https://github.com/digi-embedded/dey-manifest#installing-digi-embedded-yocto

2. Clone *meta-digi-dualboot* Yocto layer under the
   Digi Embedded Yocto sources directory

        ~$ cd <DEY-INSTALLDIR>/sources
        ~$ git clone https://github.com/digi-embedded/meta-digi-dualboot.git -b master


Create and build a project
--------------------------
We will use a ConnectCore 8M Nano as an example.

1. Create a project for your Digi platform

        ~$ mkdir <project-dir>
        ~$ cd <project-dir>
        ~$ . <DEY-INSTALLDIR>/mkproject.sh -p <platform>

2. Add *meta-digi-dualboot* layer to the project's
  *bblayers.conf* configuration file

        ~$ vi <project-dir>/conf/bblayers.conf

        <DEY-INSTALLDIR>/sources/meta-digi-dualboot

3. Build the images

        ~$ bitbake core-image-base
        ~$ bitbake dey-image-qt


License
-------
Copyright 2021, Digi International Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
