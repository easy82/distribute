Description
-----------

Love Distribution Tool (LDT) is a command line application for distributing games created with the awesome LOVE framework. It creates a .love file and a native executable depending on the host operating system.


Requirements
------------

1. You need to have the LOVE 0.8.0 framework installed. If you don't have it already, download it at http://love2d.org/

2. On Linux and on MacOSX LDT assumes you have zip installed on your system (which you most probably do).

3. On Windows LDT needs 7-Zip or WinRAR to be installed on your system. You can download 7-Zip from http://www.7-zip.org/ or WinRAR from http://www.rarlab.com/


Installation
------------

A) Installing on Linux or MacOSX:

Download LDT and put it whereever you want it.


B) Installing on Windows:

Download LDT and put it into the directory where LOVE is installed on your system. This is usually at 'C:\Program Files\LOVE'.


Usage
-----

1. Open the Terminal (or Command Prompt on Windows)

2. Navigate to the directory where you've put LDT to. Example: 'cd Downloads' (or 'cd /d C:\Program Files\LOVE' on Windows).

3. Type 'love distribute.love PathToYourProject'. Example: 'love distribute.love ~/MyProjects/MyGame' (or 'love distribute.love F:\MyProjects\MyGame' on Windows).

4. If everything went all right, you can run the .love file by hitting F5, or the native executable by hitting F6. You will find the binaries inside your project directory, under the 'bin' folder.


Known Issues
------------

- LDT is completely untested on MacOSX! Mac developer needed...

- LDT will pack the binaries it finds: 32 or 64 bits, and won't check if they are really 32 or 64 bits.


Contribute
----------

- Source: https://github.com/easy82/distribute

- E-mail: easy82 (dot) contact (at) gmail (dot) com


License
-------

Copyright (C) 2013 by Peter Szöllősi (easy82)

This software is provided 'as-is', without any express or implied
warranty. In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented; you must not
claim that you wrote the original software. If you use this software
in a product, an acknowledgment in the product documentation would be
appreciated but is not required.

2. Altered source versions must be plainly marked as such, and must not be
misrepresented as being the original software.

3. This notice may not be removed or altered from any source
distribution.

