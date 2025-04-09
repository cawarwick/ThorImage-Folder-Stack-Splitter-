//Before using make sure to copy the Garbage.ijm macro into the macro folder in order to remove the memory leaks
//Also before using, go to Bio-Foramts Plugin Configuration, go to Formats tab, find TIFF (tagged image file format) and uncheck enable
//save location. Need to change this depending on the computer and intention
input="W:/DRGS project/#541 3-22-25/Time Lapse/Final FOV/Functional/Doubles/raw Doubles/" //where the files to process are located. Make sure they are forward slashes and it ends with a forward slash.
Path="W:/DRGS project/#541 3-22-25/Time Lapse/Final FOV/Functional/Doubles/Split/"; // save location of processed files
zstacks=4; //user input required 
channels=2; //user input required
//Remove any Z-planes (e.g. flyback issues)? Enter the relevant values here. This assumes 2 channels.
RemoveZplanes=0    ///set to 0 to keep all z-planes, set to 1 to enable the z-plane remover. This also enables T-removal
KeepStackStart=1  ////this the first plane that it keeps, planes start at 1.
KeepStackEnd=5   ///this is the last plane that it keeps
KeepFramesStart=1  ///This is the first frame that it keeps. Starts at 1. This is to remove any initial issues with flyback at the start.


runMacro("Garbage");
list=getFileList(input);
print("Number of files in folder:",list.length);

//list off all the files in order to make sure they are correct
for (i=0; i<list.length; i++) {
	//get parent folder names 
	file=list[i];
	eos=lengthOf(file);
	sos=eos-1;
	OriginalFileName=substring(file, 0,sos);
	print("File#",(i+1),OriginalFileName);
}
waitForUser;

for (i=0; i<list.length; i++) {
	//get parent folder names 
	file=list[i];
	eos=lengthOf(file);
	sos=eos-1;
	OriginalFileName=substring(file, 0,sos);
	Z=OriginalFileName;
	print("Working on file #",(i+1)," ",OriginalFileName);
	tempfile=input+" "+list[i];
	File.rename(input+list[i], tempfile);//this produces a 1 it renamed successfully
	npath=tempfile+"Image_scan_1_region_0_0.tif";
	print("Opening 1st file from:",npath);
	open(npath);//open the 1st half of the doublet
	run("Slice Keeper", "first=1 last=999999 increment=1"); //not sure if this is necessary since the (v) stack sometimes messes up the concat
	close("\\Others");
	
	npath=tempfile+"Image_scan_1_region_0_1.tif";
	//open the second half if applicable
	if(File.exists(npath)) {
		rename("Part1");
		print("Opening 2nd half of file from:",npath);
		open(npath); //open the second half
		rename("closeme");	
		run("Slice Keeper", "first=1 last=999999 increment=1");
		rename("Part2");
		close("closeme");
		//concat the two halves together
		concatname = "  title="+OriginalFileName+" image1="+"Part1"+" image2="+"Part2";
		run("Concatenate...", concatname);//concat them together and then proceed as normal
		rename(OriginalFileName);
		OG_filename=File.name;
		Stack.getDimensions(Wd,Ht,Ch,Sl,F);
		runMacro("Garbage");
	}
	else {
		rename(OriginalFileName);
		OG_filename=File.name;
		Stack.getDimensions(Wd,Ht,Ch,Sl,F);
		runMacro("Garbage");
	}

	//Rearrange the stacks from XYZTC into a more common XYCZT
	run("Stack Splitter", "number=2");  //For ThorImage, first half is Gcamp, second half is red channel
	close(OriginalFileName);
	runMacro("Garbage");
	B="stk_0001_"+OG_filename;
	C="stk_0002_"+OG_filename;
	run("Interleave", "stack_1=C stack_2=B"); //interleaving the two channels to make it XYCZT
	Stack.getDimensions(Wd,Ht,Ch,Sl,F);
	close("Stk*");
	File.rename(tempfile, input+list[i]);
	runMacro("Garbage");
	
	//remove blank frames from end of recording
	Stack.getDimensions(Wd,Ht,Ch,Sl,F);
	//print("slices=",Sl,"Frames=",F);
	Y=getInfo("window.title");
	//print("Name of window:",Y);
	Stack.setSlice(Sl);
	roiManager("reset");
	Table.reset("Results");
	run("Select All");
	roiManager("add");
	roiManager("measure");
	Mean=Table.get("Mean", 0);
	//print("Mean value of last frame:",Mean);
	increment=zstacks*channels;
	//print("Number of frames to increment:",increment);
	
	while (Mean==0) {
		Stack.getDimensions(Wd,Ht,Ch,Sl,F);
		slstart=(Sl-increment)+1;
		mksub="slices="+slstart+"-"+Sl+" delete";
		//print("input to substack",mksub);
		run("Make Substack...", mksub);
		close("Substack*");
		Table.reset("Results");
		roiManager("measure");
		Mean=Table.get("Mean", 0);
		print("Mean value of last frame:",Mean);
		Table.reset("Results");
	}
	Stack.getDimensions(Wd,Ht,Ch,Sl,F);
	RRSl=Sl/10/increment;
	RRSl=round(RRSl);
	RRSl=(RRSl*10*increment);
	if (RRSl!=Sl) {
		RRSl=Sl/10/increment;
		RRSl=Math.floor(RRSl);
		RRSl=(RRSl*10*increment);
		RRSl=(RRSl+1);
		Stack.getDimensions(Wd,Ht,Ch,Sl,F);
		mksub="slices="+RRSl+"-"+Sl+" delete";
		//print("input to substack",mksub);
		run("Make Substack...", mksub);
		close("Substack*");
		print("removed some frames to make it divisible by 10, if that matters to you");
	}
	print("All zeroes removed");
	
	//remove any bad z-planes e.g. a flyback frame
	if (RemoveZplanes==1) {
		Stack.getDimensions(Wd,Ht,Ch,Sl,F);
		frames=Sl/zstacks/channels;
		hyperstack="order=xyczt(default) channels="+channels+" slices="+zstacks+" frames="+frames+" display=Color";
		print("input to hyperstack",hyperstack);
		run("Stack to Hyperstack...", hyperstack);
		substk="channels=1-"+channels+" slices="+KeepStackStart+"-"+KeepStackEnd+" frames="+KeepFramesStart+"-"+frames;
		print("input to substack",substk);
		run("Make Substack...", substk);
		close("\\Others");	
		rename("Combined Stacks");
		runMacro("Garbage");
	}
	
	//Breaking large images into pieces that are less than 4 gigabytes per file
	Size=getValue("image.size");//get image size in gb
	Stack.getDimensions(Wd,Ht,Ch,Sl,F);
	//print("Sl",Sl);
	//print("F",F);
	F=Sl*F*Ch;
	//print("newF",F);
	//print("Slice Size",Sl);
	//print("Stack Size",F);
	//print("ImageSize", Size);
	S=Size/4E9; //divide the image size by 4 gigabytes 
	S=Math.round(S);//round and then increment 
	S++;
	//print("Initial Split number",S);
	Remainder=F/S; //if it's an integer that's the 'correct' number of splits otherwise it goes to the while loop
	//print("Initial Frames/File",Remainder);
	RR=Math.round(Remainder);
	numframes=(Remainder/increment); //Remainder is the number of images in each split so if it is valid it should be evenyl divisible by the increment (C&Z)
	RRnumframes=(round(numframes));
	while(RR!=Remainder || RRnumframes!=numframes ){//this is saying, while the remainder is NOT equal to the roudned value, increase the split number by 1 and retest
		S++;
		Remainder=F/S;
		RR=Math.round(Remainder);
		numframes=(Remainder/increment); //Remainder is the number of images in each split so if it is valid it should be evenyl divisible by the increment (C&Z)
		RRnumframes=(round(numframes));
	}
	//print("Final splits",S);
	//print("Final Frames/file",Remainder);
	//print("Splits Calculated");
	run("Stack Splitter", "number=S");//run stack splitter based on the correct number of splits
	close("Com*");
	runMacro("Garbage");
	
	//Saving the split stacks to the hardrive
	for (g = 0; g < S; g++) {//for the number of splits, create a filename, select that filename, save it, then close it
	start="stk_";//Goofy nonesense for selecting each window 
	end="_Combined Stacks"; 
	gg=g+1;
	mid=String.pad(gg,4);
	wind=start+mid+end; //basically recreating each name individually and then joining them together
	selectWindow(wind);
	A=getInfo("window.title");
	A=substring(A, 5,8); //pull out the series split number
	//print("Trimmed file name:",Z);
	Filename=Z+"_"+A; //create a filename based on the original and the series split number
	//print("Path",Path);
	//print("filename",Filename);
	output=Path+Filename;//where it's being saved and how it's being named
	saveAs("Tiff", output);
	close();
	}
	run("Close All");
	close("*");
	print("File#",(i+1)," Finished");
	runMacro("Garbage");
}
print("All Files Completed");
