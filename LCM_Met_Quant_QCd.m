
function [LCM_CorrectedTable] = LCM_Met_Quant_MD_V2(LCM_Table,TE,TR,LCM_w_CONC) %will have to rename file name for the function to work

%% Inputs
% LCM_Table - structure with the LCModel outputs and the fGM, fWM and fCSF
% added from Gannet (or however)
% TR/TE - from acquisition
% LCM_w_CONC - the water concentration setting given to LCModel
% Default is 35880, water concentration of full white matter

%% Near 2020 NMR Biomed - Consensus paper 
% Molar
% c_metab_molar = S_met_obs * (fGMvoldGM*R_GM +fGMvoldWM *R_WM +fGMvoldCSF *R_CSF) / (S_H20_obs *
% (1-fCSF) * R_met) * 2/n_H_met * conc_H2o 

% Molal
% c_metab_molal = S_met_obs * (molal_f_GM * R_GM +molal_f_WM * R_WM +molal_f_CSF * R_CSF) / (S_H20_obs *
% (1-fCSF) * R_met) * 2/n_H_met * conc_H2o 
% assume negigilble concentration of metabolite in CSF

% where met_LCM = conc from LCM
% met_LCM = S_met_obs/S_H20_obs * 2/n_H * conc_H2o   where conc_H2o = setting in LCM 
% default is 35880, water concentration of full white matter
% We want to correct to concentration of water so we adjust by a factor of what we told LCM the water was
conc_H2o_adj = 55510/LCM_w_CONC; % where LCM_w_CONC is set at top - %this is somethign that needs to be checked 

%% Things from the literature

% Water Density
d_GM = 0.78; % Ernst 1993, from Gasparovic 2006
d_WM = 0.65; % Ernst 1993, from Gasparovic 2006
d_CSF = 0.97; % Ernst 1993, from Gasparovic 2006

% Water Relaxation
GM_T1_H2O = 1.1304; % Gasparovic 2006
GM_T2_H2O = 0.11; % Gasparovic 2006
WM_T1_H2O = 0.83; % Gasparovic 2006
WM_T2_H2O = 0.08; % Gasparovic 2006
CSF_T1_H2O = 4; % Gasparovic 2006
CSF_T2_H2O = 2.55; % Gasparovic 2006

% ADH Metabolite Constants>> need to check all of these - Mlynarnik et al
% NMRBiomed 2001; 14:325-331

% PL Metabolites included have been updated based on the more recent Posse
% et al paper describing several more metabolites on previous research. -
% Posse et al 2007 Magnetic Resonance in Medicine 58:236-244

% NAA
%NAA_T1_GM = 1.47; % Mlynarik et al 2001 (not region specific)
%NAA_T1_WM = 1.35; % Mlynarik et al 2001 (not region specific)
%NAA_T1_GM = 1.47; %Posse et al 2007
%NAA_T1_WM = 1.56; %Posse et al 2007
NAA_T1_COMB = 1.515; % Average of Posse values
%NAA_T2_GM = 0.247; % Mlynarik et al 2001 (not region specific)
%NAA_T2_WM = 0.295; % Mlynarik et al 2001 (not region specific)
%NAA_T2_GM = 0.247; %Posse et al 2007
%NAA_T2_WM = 0.301; %Posse et al 2007
NAA_T2_COMB = 0.274; % Average of Posse values

% Creatine  (Cr in LCM, referred to at CR)
%CR_T1_GM = 1.46; % Mlynarik et al 2001 (not region specific)
%CR_T1_WM = 1.24; % Mlynarik et al 2001 (not region specific)
%CR_T1_GM = 1.33; %Posse et al 2007
%CR_T1_WM = 1.4; %Posse et al 2007
CR_T1_COMB = 1.365;  % Average of Posse values
%CR_T2_GM = 0.152; % Mlynarik et al 2001 (not region specific)
%CR_T2_WM = 0.156; % Mlynarik et al 2001 (not region specific)
%CR_T2_GM = 0.162; %Posse et al 2007
%CR_T2_WM = 0.178; %Posse et al 2007
CR_T2_COMB = 0.17; % Average of Posse values

% Choline (GPCandPCh in LCM, referred to as CHO)
%CHO_T1_GM = 1.3; % Mlynarik et al 2001 (not region specific)
%CHO_T1_WM = 1.08; % Mlynarik et al 2001 (not region specific)
%CHO_T1_GM = 1.25; %Posse et al 2007
%CHO_T1_WM = 1.21; %Posse et al 2007
CHO_T1_COMB = 1.23; % Average of Posse values
%CHO_T2_GM = 0.207; % Mlynarik et al 2001 (not region specific)
%CHO_T2_WM = 0.187; % Mlynarik et al 2001 (not region specific)
%CHO_T2_GM = 0.222; %Posse et al 2007
%CHO_T2_WM = 0.222; %Posse et al 2007
CHO_T2_COMB = 0.222;  % Average of Posse values

% Myo-Inositol (Ins in LCM, referred to as INS)
%INS_T1_GM = 1.23; % Mlynarik et al 2001 (not region specific)
%INS_T1_WM = 1.01; % Mlynarik et al 2001 (not region specific)
%INS_T1_GM = 1.12; %Posse et al 2007
%INS_T1_WM = 0.96; %Posse et al 2007
INS_T1_COMB = 1.04; % Average of Posse values
%INS_T2_GM = 0.244; % Wyss et al 2018, taken from pACC value
%INS_T2_WM = 0.244; % Wyss et al 2018, taken from pACC value
%INS_T2_GM = 0.2; %Posse et al 2007
%INS_T2_WM = 0.2; %Posse et al 2007
INS_T2_COMB = 0.2; % Average of Posse values

% Glutamate (Glu in LCM, referred to as GLU)
%GLU_T1_GM = 1.27; % Mlynarik et al 2001 (not region specific)
%GLU_T1_WM = 1.17; % Mlynarik et al 2001 (not region specific)
GLU_T1_COMB = 1.22; % Average of Mlynarik values
%GLU_T2_GM = 0.135; % Wyss et al 2018, taken from pACC value
%GLU_T2_WM = 0.135; % Wyss et al 2018, taken from pACC value
GLU_T2_COMB = 0.135; % Wyss value
% CHECK! Only one T2 value given so put it in for both to be consistent

% GLX -Glu +Gln 
%GLX_T1_GM = 1.25; %Posse et al 2007 (Mlynarik et al 2001 occipital region was 1.2)
%GLX_T1_WM = 1.21; %Posse et al 2007 (Mlynarik et al 2001 occipital region was 0.96)
GLX_T1_COMB = 1.23;  % Average of Posse values
%GLX_T2_GM = 0.2; %Posse et al 2007
%GLX_T2_WM = 0.2; %Posse et al 2007
GLX_T2_COMB = 0.2;  % Average of Posse values

% Glutathione
%GLT_T1_GM
%GLT_T1_WM
%GLT_T2_GM
%GLT_T2_WM

% GABA
%GABA_T1_GM
%GABA_T1_WM
%GABA_T2_GM
%GABA_T2_WM



%% Things that we calculate for this MRS voxel (i.e. TR/TE dependent)

% Relax_tis = [exp(-TE/tis_T2_H2O)]*[1-exp(-TR/tis_T1_H2O)]
% Tissue Types
R_H2O_GM = [exp(-TE/GM_T2_H2O)]*[1-exp(-TR/GM_T1_H2O)];
R_H2O_WM = [exp(-TE/WM_T2_H2O)]*[1-exp(-TR/WM_T1_H2O)];
R_H2O_CSF = [exp(-TE/CSF_T2_H2O)]*[1-exp(-TR/CSF_T1_H2O)];

% Relax_met = [exp(-TE/T2_metab)]*[1-exp(-TR/T1_metab)]
R_NAA = (exp(-TE/NAA_T2_COMB)) * (1-exp(-TR/NAA_T1_COMB));
R_CR = (exp(-TE/CR_T2_COMB)) * (1-exp(-TR/CR_T1_COMB));
R_CHO = (exp(-TE/CHO_T2_COMB)) * (1-exp(-TR/CHO_T1_COMB));
R_INS = (exp(-TE/INS_T2_COMB)) * (1-exp(-TR/INS_T1_COMB));
R_GLU = (exp(-TE/GLU_T2_COMB)) * (1-exp(-TR/GLU_T1_COMB));
R_GLX = (exp(-TE/GLX_T2_COMB)) * (1-exp(-TR/GLX_T1_COMB));

%% Individual Level

fGM = LCM_Table.fGM;
fWM = LCM_Table.fWM; 
fCSF = LCM_Table.fCSF;

% Molar volume fraction
fGMvoldGM = fGM*d_GM; 
fWMvoldWM = fWM*d_WM;
fCSFvoldCSF = fCSF*d_CSF;

% Molal fraction
f_GM_h2o = fGMvoldGM/(fGMvoldGM+fWMvoldWM+fCSFvoldCSF);
f_WM_h2o = fWMvoldWM/(fGMvoldGM+fWMvoldWM+fCSFvoldCSF);
f_CSF_h2o = fCSFvoldCSF/(fGMvoldGM+fWMvoldWM+fCSFvoldCSF);


%%
%Molar concentrations

LCM_Table.NAA_NAAG_conc_molar = (LCM_Table.NAA_NAAG * (fGMvoldGM * R_H2O_GM + fWMvoldWM * R_H2O_WM + fCSFvoldCSF * R_H2O_CSF) * conc_H2o_adj) / ...
           ((1-fCSF)*R_NAA);
       
LCM_Table.Cre_PCr_conc_molar = (LCM_Table.Cre_PCr * (fGMvoldGM * R_H2O_GM + fWMvoldWM * R_H2O_WM + fCSFvoldCSF * R_H2O_CSF) * conc_H2o_adj) / ...
           ((1-fCSF)*R_CR) * conc_H2o_adj;

% MD changed 'Cho_GPC_PCh' to 'GPC_PCh'
LCM_Table.GPC_PCh_conc_molar = (LCM_Table.GPC_PCh * (fGMvoldGM * R_H2O_GM + fWMvoldWM * R_H2O_WM + fCSFvoldCSF * R_H2O_CSF) * conc_H2o_adj) / ...
            ((1-fCSF)*R_CHO);
        
% MD changed Ins_Glyc to Ins       
LCM_Table.Ins_conc_molar = (LCM_Table.Ins * (fGMvoldGM * R_H2O_GM + fWMvoldWM * R_H2O_WM + fCSFvoldCSF * R_H2O_CSF) * conc_H2o_adj) / ...
           ((1-fCSF)*R_INS);
       
LCM_Table.Glu_conc_molar = (LCM_Table.Glu * (fGMvoldGM * R_H2O_GM + fWMvoldWM * R_H2O_WM + fCSFvoldCSF * R_H2O_CSF) * conc_H2o_adj) / ...
           ((1-fCSF)*R_GLU);

LCM_Table.Glu_Gln_conc_molar = (LCM_Table.Glu_Gln * (fGMvoldGM * R_H2O_GM + fWMvoldWM * R_H2O_WM + fCSFvoldCSF * R_H2O_CSF) * conc_H2o_adj) / ...
           ((1-fCSF)*R_GLX);
       
%Molal Concentrations

LCM_Table.NAA_conc_molal = (LCM_Table.NAA_NAAG * ((f_GM_h2o * R_H2O_GM) + (f_WM_h2o * R_H2O_WM) + (f_CSF_h2o * R_H2O_CSF)) * conc_H2o_adj) / ...
    ((1-f_CSF_h2o) * (R_NAA));

LCM_Table.Cre_PCr_conc_molal = (LCM_Table.Cre_PCr * ((f_GM_h2o * R_H2O_GM) + (f_WM_h2o * R_H2O_WM) + (f_CSF_h2o * R_H2O_CSF)) * conc_H2o_adj) / ... 
    ((1-f_CSF_h2o) * (R_CR));

LCM_Table.GPC_PCh_conc_molal = (LCM_Table.GPC_PCh * ((f_GM_h2o * R_H2O_GM) + (f_WM_h2o * R_H2O_WM) + (f_CSF_h2o * R_H2O_CSF)) * conc_H2o_adj) / ...
    ((1-f_CSF_h2o) * (R_CHO));

LCM_Table.Ins_conc_molal = (LCM_Table.Ins * ((f_GM_h2o * R_H2O_GM) + (f_WM_h2o * R_H2O_WM) + (f_CSF_h2o * R_H2O_CSF)) * conc_H2o_adj) / ...
    ((1-f_CSF_h2o) * (R_INS));

LCM_Table.Glu_conc_molal = (LCM_Table.Glu * ((f_GM_h2o * R_H2O_GM) + (f_WM_h2o * R_H2O_WM) + (f_CSF_h2o * R_H2O_CSF)) * conc_H2o_adj) / ...
    ((1-f_CSF_h2o) * (R_GLU));

LCM_Table.Glu_Gln_conc_molal = (LCM_Table.Glu_Gln * ((f_GM_h2o * R_H2O_GM) + (f_WM_h2o * R_H2O_WM) + (f_CSF_h2o * R_H2O_CSF)) * conc_H2o_adj) / ...
    ((1-f_CSF_h2o) * (R_GLX));

% Save
LCM_CorrectedTable = LCM_Table;

end