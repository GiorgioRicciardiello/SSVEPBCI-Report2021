%% ======================== OBJECTIVE ========================
%   Spectral template to correlate with the PSD of a test epoch. The
%   template is generated with the use of a the pwelch method for the
%   Fourier transformation and estimation. 
%   The length of the signal is zero padded to obtain a resolution of 0.1
%   Hz between samples. 

%   To generate the template for the selected subject, the same epoch of
%   each trial is concatenated in the variable 'train_signals'. This will
%   consist of the nine channels times the 5 differents blocks, 45 signals.
%   The mean is perfomed between this 45 signals, representing the
%   registration of a unique symbol. The result is stores in 'freq_sig_erp'
%   where the third column is the mean of a symbol. 
%
%   To each mean the pwelch method is implemented, and an estimate of the
%   PSD is obtained. This estimated PSD becomed the freqeuncy template for
%   he feature extraction and a further classification based on
%   correlation.
%% ======================== INPUT ========================
%   epoch = Indicate the epoch/symbol we are using for the template 
%   BlockStruct = Data contaning the EEG recording for each block
%   tt = time array used to identify the time index accountign for the
%   physioligcal response in the epoch 
%   BlockNames = names of the block used in the complete study 
%   train_blocks = integer array, blocks sued for training and template
%   design and specified
%   Fs = Sampling frequency
%   Sy = Number of symbols
%% ======================== OUTPUT ========================
%   freq_sig_template = 3D matrix, containing on each third dimension the
%   estimated PSD for each symbol recorded from the nine EEG channels. 
%%
function [freq_sig_template] = SpectralTemplate(epoch, BlockStruct, tt, BlockNames, train_blocks,Fs, Sy)

    freq_sig_erp = NaN(1, size(tt,2), Sy);              %Store mean over nine ch
    freq_sig_template = NaN(1, size(tt,2), Sy);         %Store pwelch result
    NumTrainBlocks = numel(train_blocks);               %Number training blocks
    %train_signals = NaN(size(BlockStruct.b1,1)*NumTrainBlocks, size(BlockStruct.b1,2), size(BlockStruct.b1,3));
    train_signals = [];

    for TrainBIdx=1:NumTrainBlocks
        train_signals = [train_signals; BlockStruct.(train_blocks(TrainBIdx))];
    end


    freq_sig_erp(1,:,epoch) = mean(train_signals(:,tt,epoch));  %mean all channels (45) from the same symbol/epoch

    %ERP = mean(BlockStruct.b1(:,tt,epoch),1);

    nfft = 2*length(freq_sig_erp(1,:,epoch));                   %Zero padding to get 0.1 Hz resolution
    noverlap = 75;
    freq_sig_template(1,:,epoch) = pwelch(freq_sig_erp(1,:,epoch),[],noverlap,nfft,Fs);


%     freq = round(0:Fs/nfft:Fs/2, 1)';                           %Frequency array
%     plot(freq,pxx)                                              %plot results
% 
%     [pks,locs] = findpeaks(pxx);                                %find peaks
%     freq(locs)                                                  %extract Hz of peaks 

end

