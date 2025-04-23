% Almost done! Now loop through results file and get avgtortuosity,
% junction density and normalized volume

rawdata_dir = ; %enter raw data directory 
fijiResults_dir = ; %enter directory of fiji results

%%

listdir_fiji = dir(fullfile(fijiResults_dir,'*results_*'));

varTypes = ["double","double","string"];
varNames_temp = ["AvgTortuosity","TotalJunctions","FileName"];
temps = table('Size',[length(listdir_fiji),length(varNames_temp)],'VariableTypes',varTypes,'VariableNames',varNames_temp);

for i = 1:length(listdir_fiji)
    table2 = readtable(listdir_fiji(i).name);
    tort = table2.BranchLength./table2.EuclideanDistance;
    tort(isinf(tort))=[];
    junctions = height(table2);
    temps.AvgTortuosity(i) = mean(tort);
    temps.TotalJunctions(i) = junctions;
    temps.FileName(i) = listdir_fiji(i).name;
end

writetable(temps, "20250422_tort.xlsx") %change save name to whatever you like




%% Get volume norm from raw data

listdir_rawdata = dir(fullfile(rawdata_dir,'*nii*'));

varTypes = ["double","string"];
varNames_temp = ["Volume_norm","FileName"];
temps = table('Size',[length(listdir_rawdata),length(varNames_temp)],'VariableTypes',varTypes,'VariableNames',varNames_temp);
for i = 1:length(listdir_rawdata)
    nii_name = listdir_rawdata(i).name;
    nii_folder = listdir_rawdata(i).folder;
    info = niftiinfo(nii_name);
    volume_norm = info.PixelDimensions(1)*info.PixelDimensions(2)*info.PixelDimensions(3)*30;
    temps.Volume_norm(i) = volume_norm;
    temps.FileName(i) = nii_name;
end


writetable(temps, "20250422_volumenorm.xlsx") %change savename to whatever you like

