


% This is meant for an overview of pre-processing for vessel segmentation. 
% Steps include:
% 1. Unmixing GCaMP and SR101 channels (if necessary) 
% 2. Rotating volume to remove any pial/bone noise 
% 3. Normalize volume from 0-1 
% 4. Get pixel dimensions to read save into nifti file
% 5. Convert to Nifti

load('ZSer9466_res.mat')

vessel=squeeze(data(:,:,1,:));gcamp=squeeze(data(:,:,2,:)); % channel 1 or 2 might be switched depending on scanner
vessel=volwlevel(vessel,[],1);gcamp=volwlevel(gcamp,[],1); % normalize before unmixing
x = polyfit(gcamp(:),vessel(:),1); % unmix
y = vessel(:) - x(1)*gcamp(:) - x(2);
new = reshape(y,size(vessel));
new(new<-0.1)=-0.1; % determine threshold cutoff. Typicall between 0.1-0.2, sometimes 0 or 0.05
sliceViewer(new) %use sliceViewer function to view new volume

new = volwlevel(new,[],1); %normalize before rotation

[y,yparm]=reorientVolume1(new); %Typically need to rotate in ry and rx by 1-5 degrees. In this case, we rotate rx by +2

sliceViewer(y)% Check new volume, cut off top portion of image that only includes pial/bone noise

data_processed = volwlevel(y(:,:,7:85),[],1); % 7:85 is where good image quality is shown with limited noise

niftiwrite(data_processed,'ZSer9466_vesselExample.nii'); %create new Nifti File
info_nifti = niftiinfo('ZSer9466_vesselExample.nii');
info_nifti.PixelDimensions = cell2mat(info.PV_shared.micronsPerPixel); %Very important- you need to store pixel dimensions in nifti file

niftiwrite(data_processed,'ZSer9466_vesselExample.nii', info_nifti) % Save niftifile with new pixel dimensions

