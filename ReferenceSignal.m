%% =========================== OBJECTIVE ===========================
% Create the reference signa used in the visual stimulation. Reference is
% found in Brain–Computer Interfaces Handbook pg 431-432.
%% =========================== INPUT ===========================
%   EEGSignal: EEG data, of dimension [time x mChannels] 
%   Fs =  Sampling rate of EEG data
%   stimF = Vector of stimulation frequencies in Hz e.g. [6,7,8,9]
%   numHarm = Number of harmonics to detect
%% =========================== OUTPUT ===========================
% RefSign = Reference signal sued for stimualtion 

function  RefSign = ReferenceSignal(EEGsignal,Fs,stimF,numHarm)
    RefSign = zeros(size(EEGsignal,1),numHarm*2,length(stimF)); 
    t = (1/Fs:1/Fs:size(EEGsignal)/Fs)'; 
    for i = 1:length(stimF)
        for j = 1:numHarm
            RefSign(:,(2*j-1):(2*j),i) = [sin(2*pi*j*stimF(i)*t) cos(2*pi*j*stimF(i)*t)];
        end
    end
end