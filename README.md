# ThorStack Folder Splitter
This is an ImageJ macro which takes in the OME Tiffs output from ThorImageLS and does a variety of things to get them ready for image stabilization and processing. 
NOTE: This splitter is specific for ThorImageLS output files. ThorImageLS writes Tiffs as XYZTC rather than the typical XYCZT which messes up most TIFF importers (e.g. Suite2p) as they expect Tiffs in XYCZT.
_____________________________________________________________________________________
To do before using the macro:

1. Install the garbage.ijm macro into the macro folder in your fiji installation (e.g. fiji-win64\Fiji.app\macros)

The garbage.ijm macro clears unused but occupied RAM use. ImageJ has some bad memory management and it leaks RAM. For some reason running the garbage collection from inside the macro doesn't always work so launching an external macro seems to more consistently clear RAM 

2. Disable the Bio-Formats Plugin importer. Go to Bio-Formats Plugin Importer Configuration, go to Formats tab, find TIFF (tagged image file format) and uncheck enable. 
![image](https://user-images.githubusercontent.com/81972652/174402159-72164825-3a24-468e-810c-cd80dd388a9d.png)

If this is turned on, it will launch each time the macro tries to open a file and will pause until there is user input to confirm how to import it, for fully autonomous processing leave this turned off, but you can always just keep a stock copy of Fiji if you use this function.
________________________________________________________________________________________
User provided information for running the macro os located at the top of the macro when opened in FIJI.
For example:
![image](https://user-images.githubusercontent.com/81972652/174402485-e8a77311-daa6-4556-a7fa-1c58c6b3d3c4.png)

These are the folllowing variables you will need to change to run the macro.

Input=”C:/path/to/where/the tiffs are/”   (note the forward slashes, if you copy from Windows Explorer they are back slashes)
For example here we have all of our files raw from the microscope in a single folder and we have used the directory "/DRGS project/#542 3-25-25/Final FOV/Functional/Raw Files/" as the input folder as it contains all our files
![image](https://github.com/user-attachments/assets/a1391f32-0bfa-49c8-9198-67700ea04faa)

Path=”C:/path/to/where/you/want the tiffs saved/”    (Also note the forward slash at the end, this says to look in that folder, otherwise it things it's a file.)

Your output folder (i.e. Path variable) should NOT be nestled within the Input folder as it will see the folder as an extra file. Put it anywhere else.)

Zstacks= number of z-stacks in the source file

Channels= number of channels in the source file

RemoveZplanes=1 or 0      ///set to 0 to keep all z-planes, set to 1 to enable the z-plane remover

KeepStackStart=number   ////this the first plane that it keeps

KeepStackEnd=number   ///this is the last plane that it keeps

________________________________________________________________________________________
Basic operations of this macro
1.	Open the tiffs in the experimental folder
2.	If the are 2 files, open and concat them into a single file
3.	Rearrange the stacks from XYZTC into a more common XYCZT
4.	Remove blank frames from end of recording and round to the nearest volume
5.	Remove any bad z-planes e.g. a flyback frame. (optional, and needs to be turned on or off)
6.	Break the files into pieces smaller than 4 gb. This is necessary for Suite2p as it wants files in a MultiPage TIFF format and if the files are >4gb ImageJ saves them as a SinglePage format. If the files are not <4gb suite2p will not ‘see’ them.
7.	Save the split files as _001, 002, 003, etc.
