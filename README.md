# ThorStackSplitter
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

The files should be consistently labeled, e.g. if using a _001, _002, nomenclature ensure the 0th file also has a _000. 
When using a bulk rename the Original file is not given an appended file name which messed up the saving. They don't need to be contigous (e.g. 001 002 003, but they do all need to be formatted with a _xxx)

This is bad:
![image](https://user-images.githubusercontent.com/81972652/190514223-c4f5099f-5773-4509-92ae-67089f3c8b80.png)

This is good:
![image](https://user-images.githubusercontent.com/81972652/190513916-c32cd0ae-2af4-4ff3-8cb5-a129119e47f3.png)


Path=”C:/path/to/where/you/want the tiffs saved/”    (Also note the forward slash at the end, this says to look in that folder, otherwise it things it's a file.)
Your output folder (i.e. Path variable) should NOT be nestled within the Input folder as it will see the folder as an extra file. Put it anywhere else.)

Zstacks= number of z-stacks in the source file

Channels= number of channels in the source file

RemoveZplanes=1 or 0      ///set to 0 to keep all z-planes, set to 1 to enable the z-plane remover

KeepStackStart=number   ////this the first plane that it keeps

KeepStackEnd=number   ///this is the last plane that it keeps

________________________________________________________________________________________
Basic operations of this macro
1.	Open the tiff
2.	 Rearrange the stacks from XYZTC into a more common XYCZT
3.	Remove blank frames from end of recording and round to the nearest volume
4.	Remove any bad z-planes e.g. a flyback frame. (optional, and needs to be turned on or off)
5.	Break the files into pieces smaller than 4 gb. This is necessary for Suite2p as it wants files in a MultiPage TIFF format and if the files are >4gb ImageJ saves them as a SinglePage format. If the files are not <4gb suite2p will not ‘see’ them.
6.	Save the split files as _001, 002, 003, etc.
