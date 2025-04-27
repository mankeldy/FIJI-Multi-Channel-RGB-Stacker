//Create the dialog GUI box for user
Dialog.create("Multi-channel Microscopy");

//Directory box
inputDir=getDirectory("image");
Dialog.addDirectory("Images path",inputDir);

//Add Channels and Thresholds
Dialog.addMessage("Add each channel substring (e.g. ch00) and what thresholding you'd like (see Image>Adjust>Threshold):");

// Getting list of all possible LUTs and appending them to an array to choose from
// Initialize an with the standard colors that are hard-coded into FIJI
LUTnames = newArray("Default","Grays", "Red", "Green", "Blue", "Cyan", "Magenta", "Yellow","Red/Green","Fire", "Ice", "Spectrum", "3-3-2 RGB");

// Get the LUTs directory
LUTDir = getDirectory("luts");

// List all files in the LUTs folder
LUTfilelist = getFileList(LUTDir);

// Loop through each file in the lut folder and add the names to the array
for (i = 0; i < LUTfilelist.length; i++) {
    if (endsWith(LUTfilelist[i], ".lut")) {
        LUTname = replace(LUTfilelist[i], ".lut", "");
        LUTnames = Array.concat(LUTnames, LUTname);
    }
}

//// for testing: Print the LUT names
//for (i = 0; i < LUTnames.length; i++) {
//    print(LUTnames[i]);
//}


//List of available channels, can increase more if necessary (in the ideal world, a user could add new channels, but it's unclear if it's possible in the macro language)
channel_array = newArray("C1","C2","C3","C4","C5","C6","C7","C8");

//Creating the Channel and Color boxes
for (i=0; i<lengthOf(channel_array); i++) {
    Dialog.addString(channel_array[i], "None");
    Dialog.addToSameRow();
    Dialog.addChoice("Color:", LUTnames);
}

//Show the dialog window
Dialog.show();

////////////////////////////////////////////////
//        Getting Input Variables            //
//////////////////////////////////////////////

//Get path string
inputDir=Dialog.getString();

//looping through the channel selections and putting them into new arrays without the None
selected_channels = newArray();
selected_colors = newArray();

for (i=0; i<lengthOf(channel_array); i++) {
	current_channel = Dialog.getString();
	current_color = Dialog.getChoice();
		if (current_channel!="None"){
			selected_channels = Array.concat(selected_channels, current_channel);
			selected_colors = Array.concat(selected_colors, current_color);
		}
}


//////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////
////////////////////////////////////////////////////////

print("-----Running------");
print("Here are your variables:");
print("path = ", inputDir);
for (i=0; i<lengthOf(selected_channels); i++) {
	print("C",i+1," = ",selected_channels[i],"    Colors =",selected_colors[i]);
}


//////////////////////////////////////////////////////////////

//Resetting things in case you have stuff open
run("Clear Results");
close("*");

//Getting all of the images in the directory
fileList = getFileList(inputDir);

//Picking the target substring to look for in all of the base file names, in this case it's just using the first channel
target_substring = selected_channels[0];
selected_data_channels = selected_channels;

iregex = ".*" + target_substring +".*";


////////////////////////////////////////////////
/////////// Main Analysis Loop /////////////////
////////////////////////////////////////////////

File.makeDirectory(inputDir+"/composite_images/tifs");
File.makeDirectory(inputDir+"/composite_images/pngs");

for (i = 0; i < lengthOf(fileList); i++){
	
	//enters the if-statement for each unique field of view (based on the counter-stain images)
	if(matches(fileList[i], iregex)){
		print("-----Analyzing "+ fileList[i]+ "-----");
		
		// Remove the file extension by splitting the string at the period and taking the first part
		fileNameWithoutExtension = substring(fileList[i], 0, lastIndexOf(fileList[i], "."));
		fov_name = replace(fileNameWithoutExtension, target_substring, "");

		//splits the file name in to two halves to get the file name structure so that it can be used to open each channel		
		//array of left (0) and right side (1) of the file name 
		index_channel_substring = indexOf(fileList[i], target_substring);
		imageName_split_by_channel = newArray(substring(fileList[i], 0, index_channel_substring),substring(fileList[i], index_channel_substring+lengthOf(target_substring)));
		
		//for error testing if the images aren't opening properly
		//print(imageName_split_by_channel[0],imageName_split_by_channel[1]);
	
		//Opens the channel images in each field of view 
		for (j = 0; j < lengthOf(selected_channels); j++){
		    img_path = inputDir + imageName_split_by_channel[0] + selected_channels[j] + imageName_split_by_channel[1];
		    print("opening " + img_path);
		    open(img_path);
		    run("8-bit");
		    setOption("BlackBackground", true);		    
		}
		
		//Converting images into a stack
		print("Converting the images to a stack");
		run("Images to Stack", "name=Image_Stack use");
		    
		//Converting the images to a hyperstack and changing the channel colors 
		//The order of images in the hyperstack is the order of the added channels, so we're going to take advantage of this by just looping through the arrays
		print("Converting the images to a hyperstack");
		run("Stack to Hyperstack...", "order=xyczt(default) channels="+lengthOf(selected_channels)+" slices=1 frames=1 display=Color");
		
		selectWindow("Image_Stack");
		for (j = 0; j < lengthOf(selected_channels); j++){
			//Getting slice name to find its position selected_colors, starts from 1
			stack_channel = j+1;
			Stack.setPosition(stack_channel, 1, 1);
			
			//Changing the LUT of the image
			if (selected_colors[j] != "Default") {
			    print("Changing color of channel " + selected_channels[j] + " to " + selected_colors[j]);
			    LUT_command = "run('"+selected_colors[j]+"')";
			    eval(LUT_command);
			} else {
			        print("Using default image color for channel: " + selected_channels[j]);
			} 
		}

		 // Create a composite image from the hyperstack
		print("Making composite image");
		run("Make Composite");
		
		print("Saving composite image as ");
		tif_savePath = inputDir+"/composite_images/tifs/"+fov_name+"_composite.tif";
		saveAs("Tiff", tif_savePath);
		
		png_savePath = inputDir+"/composite_images/pngs/"+fov_name+"_composite.png";
		saveAs("png", png_savePath);
		//Closing the images for this field of view to start it fresh for the next one
		close("*");
		}
	}


//Auto-save Log
selectWindow("Log");
File.makeDirectory(inputDir+"/rgb_stacker_log");
log_path = inputDir+"/rgb_stacker_log/rgb_stacker_log.txt";
saveAs("Text",log_path);