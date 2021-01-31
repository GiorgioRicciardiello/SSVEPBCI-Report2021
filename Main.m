%%  ================= OBJECTIVE ====================
%   Detection of SSVEP for BCI speller application. The code works
%   alongside with EEGLAB tool for pre process protocol. To implement ICA
%   removal on subjects is necessary to store the component to remove on a
%   json file, stored in the same directory of the main file, the json variable 
%   file name is 'fname'. 

%   On this speller 40 symbols are uniquely presented to the subject. Each
%   symbol is visualize by the subject in an epoch (40 epochs), from which a template
%   training and a classification is perfomed. Infromation about the
%   visual stimulus are given in the 'Freq_Phase' file. The Trials of the 
%   subject are defined as blocks, on the former dataset 6 blocks are given,
%   from which a division of test_blocks and train_blocks is implemented. 
%   The subjects files of interest are in '.set' format. 

%   The algorithm is divided in three diferent steps: pre process, template
%   creation and classification. 

%   Pre process is done by calling the function 'PreProcess_EpochEx', this
%   function uses EEGLAB to perform the requieres pre process on the data

%   Template creation is done in temporal and spectral domain, for such two
%   different functions 'TemporalTemplate' and 'SpectralTemplate' are
%   defined. This functions simultaneously reads the same epoch of each 
%   training block, thus are nested in an for loop, iterating each symbol
%   and perfoming a mean with the recorded data of each symbol, separately.

%   Feature extraction and classifcation, is done in a combination of
%   temporal and spectral characteristics. At the moment the time domain
%   implements a correlation 

%% Json with ICA components to remova
clear all
fname = 'artifact_components.json';
fid = fopen(fname);
raw = fread(fid,inf);
str = char(raw');
fclose(fid);
REMOVE_COMPONENTS = jsondecode(str);

%%      Input variables

%Directories-------
FILEPATH = 'D:\giorg\Documents\MATLAB\EEGLAB\ProcessData\PreProcessICA'; %With NO ICA
%FILEPATH = 'D:\giorg\Documents\MATLAB\EEGLAB\ProcessData\AFTERICA\PreProcess\RenamedForScript' %With  ICA
folder = 'D:\giorg\Documents\MATLAB\EEGLAB\ProcessData\ProcessData';    %Destination

subjects = dir('D:\giorg\Documents\MATLAB\EEGLAB\ProcessData\PreProcessICA');  %With NO ICA
%subjects = dir('D:\giorg\Documents\MATLAB\EEGLAB\ProcessData\AFTERICA\PreProcess\RenamedForScript');    %With ICA
%------------------

%Ica----------------
APPLY_ICA = 0;                                              %define ICA
%------------------


%block---------------
Sy = 40;                                                    %Symbols 
test_blocks = 4;                                            %test blocks
train_blocks = [1,2,3,5,6];                                 %training blocks

BlockNames = {'b1','b2','b3','b4','b5','b6'};               %block names
BlockIdx = (1:Sy:280);                                      %Block index
%------------------


NSubj = floor(length(subjects)/2);                          %.set and .fdt 
                                                            %files, we want 
                                                            %.set

Ts=strings(NSubj,1);
Ta=zeros(NSubj,1);
ts=0;

Fs = 250;                                                   %Sampling frequ
T = 1/Fs;                                                   %Sampling period
    
load('Freq_Phase.mat');                                     %Input file

numHarm = 4;                                                %Number harmonics for reference signal

%Classification variables-------------------
featureVals = zeros(Sy,2);              %Feature values of the true class
ccFeatures = zeros(Sy,Sy);
fpFeatures = zeros(Sy,Sy);
stats = zeros(40,2);
stats(:,1) = (1:Sy);
%------------------
%%
for s=1:NSubj

    %% File selection 
    somename = subjects(s).name;
    if endsWith(somename,'.set')
        ts=ts+1;
        SUBJECT = somename;
    else %ghost files
        continue
    end

    
    %%  Pre process
    if APPLY_ICA
        callICA = replace(SUBJECT,'.set','');
        RM_COMP = REMOVE_COMPONENTS.(callICA)
    else
        RM_COMP = [];
    end
    
    [BlockStruct,tt,BlockNames] = PreProcess_EpochEx(SUBJECT, FILEPATH,Fs, RM_COMP, BlockNames, BlockIdx); 
    
    %% Reference Signal 
    numHarm = 4;                           
    RefSign = ReferenceSignal(BlockStruct.(BlockNames{train_blocks(1)}),Fs,freqs,numHarm);

    %% Training and template creation 
    % Each epoch is a symbol, we are taking the same epoch of each block and
    % creating the corresponing template 
    for epoch=1:Sy
        [sub_run, tmp_sig_filt] = TemporalTemplate(epoch, BlockStruct,tt,BlockNames, train_blocks, test_blocks,RM_COMP, Sy);
        [freq_sig_pwelch] = SpectralTemplate(epoch, BlockStruct,tt,BlockNames, train_blocks,Fs, Sy);
    end

    %% Classification    
    for epoch=1:Sy

        test = BlockStruct.(BlockNames{test_blocks})(:,tt,epoch);   %From test block
                                                                    %select time index
                                                                    %and epoch time
                                              
        p = calcFreqPowers(test,freqs,epoch,0);
        cc = tempCorr(tmp_sig_filt,test,epoch,0);

        ccFeatures(e,:) = cc;
        fpFeatures(e,:) = p;

        % Classify
        feature_comb = p+cc;
        [~, class] = max(feature_comb);

        stats(e,2) = class;
        featureVals(e,:) = [p(e); cc(e)];

    end

    % figure(3)
    % scatter(featureVals(:,1),featureVals(:,2),'*');
    % xlabel('Frequency Power')
    % ylabel('Correlation Coefficient')
    % 

    [Ta,Ts] = StatisticalResults(stats,ccFeatures,fpFeatures, SUBJECT, sub_run,ts);
    

end


[sortedTa,sidx] = sort(Ta,'descend');
sortedTs = Ts(sidx);
results = cat(2,sortedTs,sortedTa);


%% Some plots
%     figure(3)
%     plot(p,cc,'*');
%     hold on
%     plot(p(epoch),cc(epoch),'r*')
%     xlabel('Frequency Power')
%     ylabel('Correlation Coefficient')
%     s=strcat('Epoch ',num2str(epoch),' = ',num2str(freqs(epoch)), 'Hz');
%     
%     % Linear fit
%     ply=polyfit(p,cc,1);
%     pf=polyval(ply,p)
%     plot(p,pf,'m-');
%     title(s)
%     hold off
%     pause
%     


