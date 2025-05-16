# 2Photon_Vessel_Seg

Residual U-Net  for segmentation of vessels in 2-photon scans of mice injected with the vascular dye, Sulforhodamine 101. 

Before beginning, please download the ".pt" model and example ".mat" file located at: 

https://drive.google.com/drive/folders/1NNXniJ7EG8ihmjhxrq7y1aq7_3__klzX?usp=drive_link 

Additionally, the following packages/toolkits are needed:
1. The NIL-functions toolkit located at: https://github.com/neuroimlabpitt
2. MONAI + all optional dependencies: https://docs.monai.io/en/stable/installation.html#installing-the-recommended-dependencies 


Each step below requires manual input of data locations, plus manual inspection is highly encouraged.
1. Run "preprocessing_vesselseg_steps.m" 
2. Once the nifti file is created, run "EvalDatasets.ipynb"
3. Manually inspect segmentations and then run "postProcess_wrap.m"
4. Go to ImageJ and go to Plugins -> New -> Macro and enter in text from "New_.ijm" and then hit run.
5. Go back to matlab and run "processFijiResults.m"

You are done!
