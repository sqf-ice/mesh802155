IEEE 802.15.5 implementation for TinyOS 2.1
==========
* David Rodenas-Herráiz (rodenasherraiz.david@gmail.com)		
* Antonio-Javier García-Sánchez (antoniojavier.garcia@upct.es)
* Felipe García-Sánchez (felipe.garcia@upct.es)
* Joan García-Haro (joang.haro@upct.es)
==========

Download and install the most recent version of TinyOS.See 
installation instructions here: 
http://tinyos.stanford.edu/tinyos-wiki/index.php/Main_Page

After installing TinyOS, create a new directory in $(TOSDIR)/lib/ 
and name it as "mesh". Then, add the directory "mesh155" (located at 
/mesh directory) in the "mesh" directory.

Files PibP.nc and TKN154.h, located at $(TOSDIR)/lib/mac/tkn154,
 need to be patched by using the files PibP.patch and TKN154.patch
(located at /patches directory), respectively. Use the followings commands:

$ patch -p0 PibP.nc < PibP.patch
$ patch -p0 TKN154.h < TKN154.patch

Test applications are located within the mesh155/apps/ directory.

Further reading:

David Rodenas-Herraiz, Antonio-Javier Garcia-Sanchez, Felipe Garcia-Sanchez, 
Joan Garcia-Haro, “An Experimental Test Bed for the Evaluation of the Hidden 
Terminal Problems on the IEEE 802.15.5 Standard”, Proceedings of the 2014 
IEEE ITU Kaleidoscope Conference, Saint Petersburg, Russia, June 3–5, 2014.