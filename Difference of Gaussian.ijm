//Difference of Gaussian

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