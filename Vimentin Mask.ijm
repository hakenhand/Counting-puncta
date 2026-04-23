//Vimentin mask
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
rename("nuc");
selectWindow(syn);
rename("syn");
selectWindow(vim);
rename("vim");

//A mask is created based on vimentin image. Mask and area are saved.
selectWindow("vim");
run("Subtract Background...", "rolling=50 stack");
run("Median...", "radius=2");
selectWindow("vim");
run("Auto Threshold", "method=Huang white show stack");
run("Set Measurements...", "area redirect=None decimal=3");
run("Analyze Particles...", "  show=Nothing summarize stack");
selectWindow("Summary of vim");
saveAs("Results", path + im + "vimentin mask area.csv");
run("Close");
selectWindow("vim");
run("Invert");
saveAs("Tiff", path + im + "Vimentin mask.tif");
close();

selectWindow("nuc");
close();
selectWindow("syn");
close();
