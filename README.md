IEEE 802.15.5 implementation for TinyOS 2.1
==========
Authors:
<ul>
<li>David Rodenas-Herraiz (rodenasherraiz.david@gmail.com) (GitHub user: dr424)</li>
<li>Antonio-Javier Garcia-Sanchez (antoniojavier.garcia@upct.es)</li>
<li>Felipe Garcia-Sanchez (felipe.garcia@upct.es)</li>
<li>Joan Garcia-Haro (joang.haro@upct.es)</li>
</ul>
==========

Download and install the most recent version of TinyOS.See installation instructions here: 
http://tinyos.stanford.edu/tinyos-wiki/index.php/Main_Page

After installing TinyOS, create a new directory in $(TOSDIR)/lib/ and name it as "mesh". Then, add the directory "mesh155" (located at /mesh directory) in the "mesh" directory.

Files PibP.nc and TKN154.h, located at $(TOSDIR)/lib/mac/tkn154, need to be patched by using the files PibP.patch and TKN154.patch (located at /patches directory), respectively. Use the followings commands:

$ patch -p0 PibP.nc < PibP.patch
$ patch -p0 TKN154.h < TKN154.patch

Test applications are located within the mesh155/apps/ directory.

Further reading:

David Rodenas-Herraiz, Antonio-Javier Garcia-Sanchez, Felipe Garcia-Sanchez, Joan Garcia-Haro, An Experimental Test Bed for the Evaluation of the Hidden Terminal Problems on the IEEE 802.15.5 Standard, Proceedings of the 2014 IEEE ITU Kaleidoscope Conference, Saint Petersburg, Russia, June 3-5, 2014.
