# TissueCorrections

Scripts used in Harris Brain Lab to correct for tissue relaxation in single voxel spectroscopy.

Batch_Tissue_Correction is the script used to create a structure for each individual voxel with the LCModel output, along with the respective tissue fractions, runs the function and saves the output. 

LCM_Met_Quant_QCd is the function applied, which takes in an a structure with metabolite/s of interest and respective GM, WM and CSF fraction.
