%% ======================== OBJECTIVE ========================
%   
%   
%% ======================== INPUT ========================
%   epoch = Indicate the epoch/symbol we are using for the template 
%   BlockStruct = Data contaning the EEG recording for each block
%   tt = time array used to identify the time index accountign for the
%   physioligcal response in the epoch 
%   fn = block names
%   train_blocks 
%   test_blocks  
%   RM_COMP = ICA components to remove based on the json file 
%   Sy = Number of symbols
%% ======================== OUTPUT ========================
%   freq_sig_template = 3D matrix, containing on each third dimension the
%   estimated PSD for each symbol recorded from the nine EEG channels. 

function [sub_run, tmp_sig_filt, test_block] = TemporalTemplate(epoch, BlockStruct,tt,fn,train_blocks,test_blocks, RM_COMP, Sy)
    
    train_signals = [];
    tmp_sig = NaN(1, size(tt,2), Sy);
    NumTrainBlocks = numel(train_blocks);
    tmp_sig_filt = NaN(size(tmp_sig,1),size(tmp_sig,2), size(tmp_sig,3));
    
    for TrainBIdx=1:NumTrainBlocks
        train_signals = [train_signals; BlockStruct.(fn{train_blocks(TrainBIdx)})];
    end
    
   
    tmp_sig(1,:,epoch) = mean(train_signals(:,tt,epoch));  %mean on the same symbol/epoch
    
    %Smooth the template 

    WnTheta = 0.4;                                         %frequency cut off,
                                                           %filter low freq to
                                                           %smooth the function

    [b,a] = butter(6, WnTheta, 'low');         %Normalized to the 'frequecy' of
                                               %the signal we dont have a time
                                               %series function, so there is no
                                               %fs and ts.

    for i = 1:40
        tmp_sig_filt(1,:,i) = filtfilt(b,a,squeeze(double(tmp_sig(1,:,i))));
    end
    %

    % Epocht_interest = [0.14 5.14];      %[s]
    % [~, StartEpochIdx] = min(abs(t - Epocht_interest(1)));
    % %StartEpoch = t(StartEpochIdx);
    % [~, EndEpochIdx] = min(abs(t - Epocht_interest(2)));
    % 
    % t = 1/Fs:1/Fs:L/Fs;
    % plot1 = plot(t(StartEpochIdx:EndEpochIdx ), tmp_sig(1,:,1), 'b','LineWidth',2); 
    % hold on, 
    % plot(t(StartEpochIdx:EndEpochIdx ), tmp_sig_filt(1,:,1),'r','LineWidth',1); 
    % hold off
    % legend('Template', 'Filtered template','Interpreter','latex')
    % xlabel('time [s]','Interpreter','latex')
    % ylabel('$\mu [V]$','Interpreter','latex')
    % 
    % set(findall(gcf,'-property','FontSize'),'FontSize',16)
    %  
    % xlim([t(StartEpochIdx) t(EndEpochIdx)])
    % plot1.Color(4) = 0.5;
    % grid on
    % %grpdelay(b,a)
    % freqz(b,a)
    fvtool(b,a,'Fs',250)

    test_block = BlockStruct.(fn{test_blocks});

    sub_run = struct;
    sub_run.train = train_blocks;
    sub_run.test = test_blocks;
    sub_run.ICA = RM_COMP;
    
end

