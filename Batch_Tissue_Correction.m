%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Script to perform batch tissue correction on LCM .csv files

% Script is designed to analyze LCM .csv files saved in participant folders in a 
% larger study directory with the ID of the csv
% file matching that of the segmented T1. Takes each csv and matches it to
% line in structure of GannetCoRegStandAlone structure.

% Data is saved in Output_date folder in the directory that contains
% the participant folders. Output table is saved in .mat and .csv format
% (.csv file can be directly imported into SPSS for statistical analysis)

%% Important Settings

% Voxel Details
TE = 0.035; % IN SECONDS!!! TE 35MS becomes 0.035, TE 30MS becomes 0.030
TR = 2; % In seconds
% Water Concentration Set in LCModel
LCM_w_CONC=55510;

% Home location
HomeFolder = '/XXX/';


%% Loop through all files
% Coregistration for voxel of interest - taken from Gannet CoReg Function 
coreg_file = 'XXX.mat';
load(coreg_file);
ID_array=MRS_struct.metabfile;
region='regionname';

% CSV file from the LCModel Output - set up the path for the CSV of
% interest

% can grab from bash or by doing 
% csvfile = '/Users/maz/Documents/OneDriveBackup/RAPT_Re_Run/Data/RAPT-*/BIG/*.csv'; ls(csvfile) 
csv_path={
'pathofcsv1'
'pathofcsv2'
};

% Loop that reads in .csv file and MRS_struct and runs in through LCM_Met_Quant

cd (HomeFolder)
j = [];
for p = 1:numel(csv_path)   
    
    % You will get an error " Warning: Table variable names were modified to make them valid MATLAB identifiers. The original names are saved in the VariableDescriptions property."
    % This is because of all the symbols in the LCModel output
    LCM_Table = readtable(csv_path{p}); %reads in LCM .csv file
    LCM_Table.Row = {csv_path{p}}; %changes first variable to be LCM file ID
    LCM_Table.Properties.VariableNames{'Row'} = 'FullPath'; %adds LCM file ID to table
    LCM_Table.Properties.VariableNames{'Col'} = 'File_ID'; %adds LCM file ID to table

    
    % MD use file name to identify row for inclusion
    % Identifies the row that the metabolite file 
    target_name=csv_path{p};
    target_name=split(target_name,"/");
    target_length=numel(target_name);
    target_name=target_name(target_length);
    target_name=split(target_name,".");
    target_name=target_name(1);
    row_no=contains(ID_array,target_name);
    row_no=find(row_no);
    LCM_Table.File_ID=target_name;
    
    % Add name of T1 nifti and PFile that were used
    LCM_Table.PFile_Seg= MRS_struct.metabfile(row_no);
    LCM_Table.T1_nii = MRS_struct.mask.vox1.T1image(row_no);
    LCM_Table.MRS_mask = MRS_struct.mask.vox1.outfile(row_no);
    
    % Add tissue fractions to the individual LCModel table 
    % These are used to tissue correct and called in the function
    % You may need to adapt the MRS_struct... naming depending on your defaults
    LCM_Table.fGM = MRS_struct.out.vox1.tissue.fGM(row_no);
    LCM_Table.fWM = MRS_struct.out.vox1.tissue.fWM(row_no);
    LCM_Table.fCSF = MRS_struct.out.vox1.tissue.fCSF(row_no);

    % Run LCM_Met_Quant and save output in table
    LCM_Met_Quant_MD_QCd(LCM_Table,TE,TR,LCM_w_CONC);
    LCM_CorrectedTable = [j;ans]; % adds new LCM_Met_Quant output to existing output table
    j = LCM_CorrectedTable;
end

%% Returns to study folder, makes output folder and output.csv file

cd(HomeFolder)
OutputDir = (strcat('Output_',date));
mkdir(OutputDir)
cd(strcat(HomeFolder,strcat('/',OutputDir)))
writetable(LCM_CorrectedTable,strcat(region,'_LCM_CorrectedTable_',strcat(datestr(now,'mm-dd-yyyy-HH-MM'),'.csv')))
save(strcat(region,'_LCM_Corrected_Table.mat'),'LCM_CorrectedTable');
% save LCM_CorrectedTable.mat

