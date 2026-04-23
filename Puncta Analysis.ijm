//Macro that analyzes how many post synaptic puncta are in the image

//First step ist to specify the folder in which to save the final data.
//Then the image ist split into its three channels. A dialogue is shown in which user specifies which channel is which structure.
path = "C:/Users/simon/Desktop/20250324 siPSD siGphn + FingR/data/"
im = getTitle();
path = path + im + "/"
File.makeDirectory(path);
run("Duplicate...", "title=copy duplicate");
run("Split Channels");
titles = getList("image.titles");
Dialog.create("Choose the correct channels");
Dialog.addChoice("Nuclei", titles, "C1-copy");
Dialog.addChoice("Synaptoids", titles, "C2-copy");
Dialog.addChoice("Vimentin", titles, "C3-copy");
Dialog.show();

//Images are duplicated and renamed nuc, syn and vim according to the choices the user made in the dialogue.
nuc = Dialog.getChoice();
syn = Dialog.getChoice();
vim = Dialog.getChoice();

selectWindow(nuc);
run("Duplicate...", "title=nuc duplicate");
selectWindow(syn);
run("Duplicate...", "title=syn duplicate");
selectWindow(vim);
run("Duplicate...", "title=vim duplicate");

//User is asked to count the number of nuclei in the image. Answer is saved in "Image_name nuclein.txt"
selectWindow("nuc");
run("Z Project...", "projection=[Sum Slices]");
Dialog.create("Count the number of nuclei");
Dialog.addNumber("No. of nuclei", 0);
Dialog.show();
nuclein = Dialog.getNumber();
File.saveString(nuclein, path + im +" nuclein.txt");

//Counting synaptoids. 
//This is done 3 times, each time accounting by a different factor for which of the puncta are actually inside the cells (aka inside vimentin signal).

//1. Background subtraction
selectWindow("syn");
run("Subtract Background...", "rolling=50 stack");

//2. Enhancing puncta using difference of gaussian ("DoG")
run("Duplicate...", "title=[syn1] duplicate");
run("Duplicate...", "title=[syn2] duplicate");
selectWindow("syn1");
run("Gaussian Blur...","sigma=1 stack");
selectWindow("syn2");
run("Gaussian Blur...","sigma=2.5 stack");
imageCalculator("subtract stack create", "syn1", "syn2");
print("Done DoG calculation!");
selectWindow("syn1");
close();
selectWindow("syn2");
close();

//4. Do Threshold and Analyze Particles on one copy of DoG. Save and keep one initial copy (multiply vim) for following steps.
selectWindow("Result of syn1");
run("Duplicate...", "title=[mask vim] duplicate");
selectWindow("Result of syn1");
saveAs("Tiff", path + im +" normal.tif");
run("Auto Threshold", "method=Otsu white show stack");
saveAs("Results", path + im +" normal otsu results.csv");
run("Clear Results");
setThreshold(4, 255, "raw");
run("Analyze Particles...", "summarize stack");
saveAs("Results", path + im +" normal results.csv");
run("Clear Results");
saveAs("Tiff", path + im +" normal results.tif");
close();

//5. Vimentin Image: Subtract Background, copy, and enhance contrast in one copy (vim enhanced).
selectWindow("vim");
run("Subtract Background...", "rolling=50 stack");
run("Median...", "radius=2");
run("Duplicate...", "title=[vim enhanced] duplicate");
run("Enhance Contrast...", "saturated=0.35 process_all");
selectWindow("vim");
run("Auto Threshold", "method=Huang white show stack");
run("Invert");

//6. Subtract "vim"/mask from "mask vim" in order to only keep the synaptoids which are close to vimentin, i.e. inside the cell
//A copy of the final image is saved.
imageCalculator("subtract stack create", "mask vim", "vim");
selectWindow("Result of mask vim");
saveAs("Tiff", path + im +" mask vim.tif");

//7. Run Auto Threshold Otsu on mask vim, analyze particles and save results.
run("Auto Threshold", "method=Otsu white show stack");
run("Analyze Particles...", "summarize stack");
saveAs("Results", path + im +" mask vim results.csv");
run("Clear Results");
saveAs("Tiff", path + im +" mask vim results.tif");
close();

//8. Do steps 6 and 7 but with "vim enhanced" instead of vim. A copy of the image after step 6 is saved
imageCalculator("multiply stack create 32-bit", "mask vim", "vim enhanced");
run("16-bit");
selectWindow("Result of mask vim");
saveAs("Tiff", path + im +" mult vim enh.tif");
run("Auto Threshold", "method=Otsu white show stack");
run("Analyze Particles...", "summarize stack");
saveAs("Results", path + im +" mult vim enh results.csv");
run("Clear Results");
saveAs("Tiff", path + im +" mult vim enh results.tif");
close();

//Close all images, which are no longer needed.
selectWindow("Log");
saveAs("Text", path + im + " threshold log.txt");

selectWindow("syn");
close();
selectWindow("nuc");
close();
selectWindow("vim");
close();
selectWindow("mask vim");
close();
selectWindow("SUM_nuc");
close();
selectWindow("vim enhanced");
close();
selectWindow(syn);
close();
selectWindow(nuc);
close();
selectWindow(vim);
close();
