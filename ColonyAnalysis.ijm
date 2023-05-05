OG =	 getTitle();
n = 	roiManager("count")
for 	(i=1; i<=n; i++) {
	roiManager("Select", i-1);
	run("Duplicate...", "duplicate");
	run("Tiff...");
	run("Clear Outside");
	rename(i);
	selectWindow(OG);}
for 	(i=1; i<=n; i++) {
	selectWindow(i);
	setAutoThreshold("MaxEntropy");
	setOption("BlackBackground", true);
	run("Convert to Mask");}
roiManager("reset");
for 	(i=1; i<=nImages-1;i++){
	roiManager("reset")
	selectWindow(i);
run("Analyze Particles...", "size=80-Infinity circularity=0.01-1.00 display exclude clear add");
	saveAs("Results");}
while 	(nImages>0) { 
	selectImage(nImages); 
      	close();} 
roiManager("reset");
