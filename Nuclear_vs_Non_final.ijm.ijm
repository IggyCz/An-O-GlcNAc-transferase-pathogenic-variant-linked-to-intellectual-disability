//Clears ROIs and results as well as sets measurement parameters (integrated means sum of pixels)
run("Clear Results");
roiManager("reset");
run("Set Measurements...", "area mean standard min integrated display redirect=None decimal=3");

//Dialog boxes to choose different thresholding approaches and number of channels in image
channel2 = false;
channel3 = false;
test_mode = true;
image_selection = false
manual_selection = true
ind_nuclei = true
//min_nuclear_size = 60
//max_nuclear_size = 100
//circularity = 0.3
threshold_types = newArray("Local", "Global");

global_thresholds = newArray("Default", "Huang", "Intermodes", 
"Isodata", "IJ_IsoData", "Li", "MaxEntropy","Mean", "MinEror", 
"Minimum", "Moments", "Otsu", "Percentile","RenyiEntropy", 
"Shanbhag", "Triangle", "Yen");

local_thresholds = newArray("Phansalkar", "Otsu", "Bernsen", "Contrast", "Mean", "Median",
"MidGrey", "Niblack", "Sauvola");

Dialog.create("Settings");
Dialog.addCheckbox("Select which images to include (otherwise all processed)", image_selection);
Dialog.addCheckbox("Manually select region of interest", manual_selection);
Dialog.addMessage("Number of non-DAPI channels (default 1):");
Dialog.addCheckbox("2", channel2);
Dialog.addCheckbox("3", channel3);
Dialog.addChoice("Thresholding type", threshold_types);
Dialog.addString("Total result file name", "Results");
Dialog.show();


image_selection = Dialog.getCheckbox();
manual_selection = Dialog.getCheckbox();
channel2= Dialog.getCheckbox();
channel3 = Dialog.getCheckbox();
threshold_types = Dialog.getChoice();
output_filename = Dialog.getString();


if (threshold_types == "Global"){
	Dialog.create("Thresholding");
	Dialog.addMessage("Thresholding method:");
	Dialog.addChoice("Thresholding method", global_thresholds);
	Dialog.show();
	threshold_method = Dialog.getChoice();
}

if (threshold_types == "Local"){
	Dialog.create("Thresholding");
	Dialog.addMessage("Thresholding method (only select try all in test mode):");
	Dialog.addChoice("Thresholding method", local_thresholds);
	Dialog.show();
	threshold_method = Dialog.getChoice();
}

File.setDefaultDir(getDirectory("Choose Folder This is in"))

//Establishes folders to take images from and place masks in
input = File.getDefaultDir + "\\RAW_Input\\";
output = File.getDefaultDir;
output_masks = File.getDefaultDir + "\\Masks\\";

//conditional to either show or hide analysis
if (test_mode == true){
	setBatchMode(false);
}
else {
	setBatchMode(true);
}

//Makes result file (.csv)
var resultFileLine;

resultFileLineMod("init", "FileName", true);

resultFileLineMod("append", "Nuclear Area", true);
resultFileLineMod("append", "Nuclear Mean Signal C1", true);
resultFileLineMod("append", "Nuclear StDev Signal C1", true);
resultFileLineMod("append", "Nuclear Sum Intensity C1", true);
resultFileLineMod("append", "Non-Nuclear C1 Area", true);
resultFileLineMod("append", "Non-Nuclear C1 Mean Signal", true);
resultFileLineMod("append", "Non-Nuclear StDev Signal C1", true);
resultFileLineMod("append", "Non-Nuclear C1 Sum Intensity", true);

if (channel2 == true){
	resultFileLineMod("append", "Nuclear Mean Signal C2", true);
	resultFileLineMod("append", "Nuclear StDev Signal C2", true);
	resultFileLineMod("append", "Nuclear Sum Intensity C2", true);
	resultFileLineMod("append", "Non-Nuclear C2 Area", true);
	resultFileLineMod("append", "Non-Nuclear C2 Mean Signal", true);
	resultFileLineMod("append", "Non-Nuclear StDev Signal C2", true);
	resultFileLineMod("append", "Non-Nuclear C2 Sum Intensity", true);
}

if (channel3 == true){
	resultFileLineMod("append", "Nuclear Mean Signal C3", true);
	resultFileLineMod("append", "Nuclear StDev Signal C3", true);
	resultFileLineMod("append", "Nuclear Sum Intensity C3", true);
	resultFileLineMod("append", "Non-Nuclear C3 Area", true);
	resultFileLineMod("append", "Non-Nuclear C3 Mean Signal", true);
	resultFileLineMod("append", "Non-Nuclear StDev Signal C3", true);
	resultFileLineMod("append", "Non-Nuclear C3 Sum Intensity", true);
}

resultFileLineMod("writeFile", output + output_filename + ".csv", false);

//function for making and writing to result file
function resultFileLineMod(command, parameter, addSeparator){
	resultFileSeparator=", ";
	if (command=="init")	{
		resultFileLine=""+parameter;	
		if (addSeparator)	{
			resultFileLine=resultFileLine+""+resultFileSeparator;	}	}
	else if (command=="append")	{
		resultFileLine=resultFileLine+""+parameter;
		if (addSeparator)	{
			resultFileLine=resultFileLine+""+resultFileSeparator;	}	}
	else if (command=="report")	{
		print(resultFileLine);	}
	else if (command=="writeFile")	{
		File.append(resultFileLine, parameter);	}
}

//function to saves images (in this context overlay of ROI)
function make_overlay(image, selection_index){
	selectImage(image);
	//name = getTitle();
	roiManager("deselect");
	roiManager("select", selection_index);
	roiManager("draw");
	return image
	//saveAs("Tiff", output_masks + substring(name, 0, lengthOf(name)-5) + s);
}

function title_from_ID(imageID){
	selectImage(imageID);
	return getTitle();
}

function select_ROI(){
	setBatchMode(false);
	waitForUser("Select region of interest");
	roiManager("add");
	roiManager("select", 0);
	run("Crop");
	run("Clear Outside");
	roiManager("reset");
	resetMinAndMax();
	if (test_mode == false){
		setBatchMode(true);
	}
}

function export_overlay(){
	overlay_DAPI = title_from_ID(overlay_DAPI_ID);
	overlay_C2 = title_from_ID(overlay_C2_ID);
	if (channel3 == true){
		overlay_C3 = title_from_ID(overlay_C3_ID);
		overlay_C4 = title_from_ID(overlay_C4_ID);
		run("Merge Channels...", "c1=["+overlay_DAPI+"] c2=["+overlay_C2+"] c3=["+overlay_C3+"] c4=["+overlay_C4"] create");
		saveAs("Tiff", output_masks + Original + s);
	}
	else if (channel2 == true){
		overlay_C3 = title_from_ID(overlay_C3_ID);
		run("Merge Channels...", "c1=["+overlay_DAPI+"] c2=["+overlay_C2+"] c3=["+overlay_C3+"]  create");
		saveAs("Tiff", output_masks + Original + s);
	}
	else{
		run("Merge Channels...", "c1=["+overlay_DAPI+"] c2=["+overlay_C2+"] create");
		saveAs("Tiff", output_masks + Original + s);
	}
}

//Segmentation of nuclei, global threshold approach not optimised, Phansalkar local best
function nuclear_mask(DAPI){
	selectImage(DAPI);
	run("Duplicate...", " ");
	//Raw image for mask output
	for_export = getImageID();
	if (threshold_types == "Local"){
		selectImage(DAPI);
		//blur to reduce effect of uneven nuclear staining 
		run("Median...", "radius=1.5");
		run("Duplicate...", " ");
		pDAPI = getImageID();
		selectImage(DAPI);
		setAutoThreshold("MinError dark");
		setOption("BlackBackground", false);
		run("Convert to Mask");
		run("Create Selection");
		roiManager("add");
		selectImage(pDAPI);
		//stretches histogram across total range of possible pixel values
		run("Enhance Contrast...", "saturated=0 equalize");
		run("Duplicate...", " ");
		roiManager("select", 0)
		run("Clear Outside");
		run("Select None");
		roiManager("reset");
		run("Duplicate...", " ");
		temp_threshold = getImageID();
		setAutoThreshold("Otsu dark no-reset");
		//run("Threshold...");
		setOption("BlackBackground", false);
		run("Convert to Mask");
		run("Create Selection");
		roiManager("add");
		if (test_mode == true){
		waitForUser("debug");	
		}
		close();
		selectImage(pDAPI);
		roiManager("select", 0);
		run("Clear Outside");	
		roiManager("reset");
		run("Select None");
		run("8-bit");
		run("Auto Local Threshold", "method="+threshold_method+" radius=15  parameter_1=0 parameter_2=0 white");
		if (test_mode == true){
		waitForUser("debug");	
		}
		run("Invert");
		run("Erode");
		run("Erode");
		run("Dilate");
		run("Dilate");
		//run("Watershed");
		if (test_mode == true){
		waitForUser("debug");	
		}
		run("Create Selection");
		roiManager("add");
		close();
		close();
		}
	else {
		selectWindow(DAPI);
		setAutoThreshold(""+threshold_method+" white");
		//run("Threshold...");
		setOption("BlackBackground", false);
		run("Convert to Mask");
		run("Dilate");
		run("Dilate");
		run("Erode");
		run("Erode");
		run("Invert");
		run("Create Selection");
	}
	if (test_mode == true){
		waitForUser("debug");	
	}
	return make_overlay(for_export, 0);
}

//makes conservative i.e. maximal mask of given channel and adds as ROI
function channel_masks(channel){
	selectImage(channel);
	run("Select None");
	run("Duplicate...", "duplicate");
	mask_image = getImageID();
	selectImage(mask_image);
	setAutoThreshold("MinError dark");
	//run("Threshold...");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Erode");
	run("Erode");
	run("Erode");
	run("Dilate");
	run("Dilate");
	run("Dilate");
	run("Create Selection");
	roiManager("Add");
	close();
}

function measure_parameters(channel){
	//duplicate nuclear roi as roiManager("combine") replaces instead of adding
	roiManager("select", 0)
	roiManager("Add")
	channel_masks(channel);
	selectImage(channel);
	nuclear_and_TFs = newArray(1,2);
	//Make a new ROI representing DAPI signal AND CX signal (i.e. cytoplasm and nuclear signal in one ROI from nuclear and C1 signal)
	roiManager("select", nuclear_and_TFs);
	roiManager("Combine");
	roiManager("Add");
	//Make a new ROI representing non-nuclear CX signal (i.e. cytoplasm CX from exclusive OR of nuclear and CX+nuclear signal)
	//Total signal now has index 3, rest same (i.e. orignal nuclear at 0, channel at 2)
	nuclear_and_total = newArray(0, 3);
	roiManager("select", nuclear_and_total);
	roiManager("XOR");
	roiManager("Add");
	roiManager("show all without labels");
	//result of XOR at index 4 i.e. infered cytoplasm
	nuclear_and_cytoplasmic = newArray(0,4);
	roiManager("select", nuclear_and_cytoplasmic);
	selectImage(channel);
	roiManager("Measure");
	//as only relevant ROI selected, index of cytoplasm results is 1
	resultFileLineMod("append", getResult("Mean", 0), true);
	resultFileLineMod("append", getResult("StdDev", 0), true);
	resultFileLineMod("append", getResult("IntDen", 0), true);
	resultFileLineMod("append", getResult("Area", 1), true);
	resultFileLineMod("append", getResult("Mean", 1), true);
	resultFileLineMod("append", getResult("StdDev", 1), true);
	resultFileLineMod("append", getResult("IntDen", 1), true);
	run("Clear Results");
	overlay = make_overlay(channel, 3);
	roiManager("select", newArray(1,2,3,4));
	roiManager("delete");
	return overlay
	
}
//function which ties analysis together
function nuclear_vs_non(){
	Original = getTitle();
	Original_ID = getImageID();
	run("Duplicate...", "duplicate");
	Duplicate = getTitle();
	run("Split Channels");
	selectWindow("C1-" + Duplicate);
	DAPI = getImageID();
	selectWindow("C2-" + Duplicate);
	pC2 = getImageID();
	if (channel2 == true){
		selectWindow("C3-" + Duplicate);
		pC3 = getImageID();
		
	}
	if (channel3 == true){
		selectWindow("C4-" + Duplicate);
		pC4 = getImageID();
	}

	resultFileLineMod("init", Original, true);
	overlay_DAPI_ID = nuclear_mask(DAPI);
	//measures nuclear area	roiManager("Measure");
	
	roiManager("Measure");
	resultFileLineMod("append", getResult("Area", 0), true);
	run("Clear Results");
	run("Select None");
	overlay_C2_ID = measure_parameters(pC2);
	
	if (channel2 == true){
		overlay_C3_ID = measure_parameters(pC3);
		}

	if (channel3 == true){
		overlay_C4_ID = measure_parameters(pC4);
		}
	export_overlay();
	print("Analysis Complete: " + Original + s);
}


function keep_image(){
	setBatchMode(false);
	keep_image_bool = getBoolean("Keep image?");
	if (test_mode == false){
		setBatchMode(true);
	}
	if(keep_image_bool == true){
		if (manual_selection == true){
			select_ROI();
		}
		return true;
	}
	else{
		return false;
	}
}

function bio_formats_open(in_dir, out_dir, filename){
	run("Bio-Formats Macro Extensions");
	seriesToOpen = newArray;
	sIdx = 0;
	path = in_dir+filename;
	print(path);
	Ext.setId(path);
	Ext.getSeriesCount(seriesCount);
	for(s = 1; s <= seriesCount; s++){
	run("Bio-Formats Importer", "open=[" + path + "] autoscale color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_"+s+"");
	if (image_selection == true){
		if (keep_image() == true){
			nuclear_vs_non();	
		}
		else{
			close();
		}
	}
	else{
		if (manual_selection == true){
			select_ROI();
		}
		nuclear_vs_non();
	}
	run("Close All");
	resultFileLineMod("writeFile", output + output_filename + ".csv", false);
	roiManager("reset")
	}
}

list = getFileList(input);

for (i = 0; i < list.length; i++){
	if (test_mode == false){
		setBatchMode(true);
	}
        bio_formats_open(input, output, list[i]);
}

setBatchMode(false); 
