function [ALLEEG, EEG, CURRENTSET, BlockStruct] = EEG_LAB(FILEPATH)

    %%EEGLAB Pre process
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
    EEG = pop_loadset('filename',SUBJECT,'filepath',FILEPATH);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    EEG = eeg_checkset( EEG );
    EEG = pop_subcomp( EEG, RM_COMP, 0);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    close all

    data = ALLEEG(2).data([48, 54:58, 61:63],:,:);
    BlockStruct = struct;
    
    %% Seperating data into blocks
    for i = 1:6
        BlockStruct.(BlockNames{i})=data(:,:,BlockIdx(i):BlockIdx(i+1)-1);
    end
    fn=fieldnames(BlockStruct);

   
    Fs = 250;             % Sampling frequency
    T = 1/Fs;             % Sampling period
    L = length(data);     % Length of signal
    t = (0:L-1)*T;        % Time vector

    %% Create template from mean of blocks and test_signal
    tt = [Fs*0.64:L-Fs*0.36]; % From literature recommends 0.14s visual latency
    % 0.5 + 0.14 = 0.64 -> 5.64 seconds time window
end

