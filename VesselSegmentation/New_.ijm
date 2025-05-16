setBatchMode(true);

input = "/Volumes/LaCie/MicrogliaProject/Vessel_tortuosity_processing/SkelNifti/";
output = "/Volumes/LaCie/MicrogliaProject/Vessel_tortuosity_processing/SkelNifti/FijiResults/";

function action(input, output, filename) {
	//open(input + filename);
	//run("8-bit");
	openimagename = input + filename;
        run("Bio-Formats Importer", "open="+openimagename);
        run("Analyze Skeleton (2D/3D)", "prune=none show");
        name = filename +".csv";
        saveAs("Results",output+"results_"+name);
        selectWindow("Results");
	saveAs("Results",output+"branchinfo_"+name);
close();
close();
}
list = getFileList(input);
for (i = 0; i < list.length; i++){
        action(input, output, list[i]);
}

setBatchMode(false);
