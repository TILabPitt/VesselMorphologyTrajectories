
%wrapper for post-processing to skeletonize segmentations. First manually
%check that segmentation was good. Manually input location of segmentation
%as data_dir and save location as save_dir
%make sure raw data and segmented data are in separate files

segdata_dir = ; % enter location of segmentation
save_dir_mat = ; % enter location of saving skeleton .mat file
rawdata_dir = ;% enter location of raw data

listdir = dir(fullfile(segdata_dir,'*mask*'));

for i = 1:length(listdir)
    filename = fullfile(listdir(i).folder,listdir(i).name);
    postProcess(filename,segdata_dir,save_dir_mat)
end


%% Save to skeleton after finished processing
listdir_mat = dir(fullfile(save_dir_mat,'*mat*'));
listdir_rawdata = dir(fullfile(rawdata_dir,'*nii*'));

for i = 1:length(listdir_rawdata)
    nii_name = listdir_rawdata(i).name;
    nii_folder = listdir_rawdata(i).folder;
    for j = 1:length(listdir_mat)
        matname = listdir_mat(j).name;
        newname = erase(erase(matname,'mask_'),'.mat');
        if strcmp([newname,'.nii'],nii_name)
            info = niftiinfo(fullfile(nii_folder,nii_name));
            load(fullfile(save_dir,matname))
            C(C>0)=1;
            niftiwrite(C,[newname,'_skel.nii'],info)
        end
    end
end

