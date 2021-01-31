function pows = calcFreqPowers(signal, fz, e, toplot)
% Power stuff %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

x = mean(signal,1);
Fs = 250;

lpad = 2*length(x); % Zero padding to get 0.1 Hz resolution
xdft = fft(x,lpad);
xdft = xdft(1:lpad/2+1);
xdft(2:end-1) = 2*xdft(2:end-1);
freq = 0:Fs/lpad:Fs/2;
freq = round(freq,1)';

% Power index
fpidx=cast((fz+0.1)*10,'int16'); % Index on the frequency axis
%spidx=fpidx*2;
spidx=floor((fpidx*2)-1);
fpows = zeros(length(fz),1);
spows = zeros(length(fz),1);
for i = 1:numel(fpidx)
    % Fundamental frequency
    fpows(i) = sum(abs(xdft(fpidx(i)-1:fpidx(i)+1)).^2);
    % Second harmonics
    spows(i) = sum(abs(xdft(spidx(i)-1:spidx(i)+1)).^2);
end

% Weighting factor from book
%aw = (sum(fpows./(fpows+spows)))/40;

% Equation from book
% pows = aw.*fpows + (1-aw).*spows;
pows = fpows + spows;
pows = normalize(pows,'range',[0 1]);

if toplot
    figure(2)
    plot(freq,abs(xdft).^2)
    hold on
    xlabel('Hz')
    ylabel('Amplitude')
    plot(freq(spidx(e)),abs(xdft(spidx(e))),'ro')
    plot(freq(fpidx(e)),abs(xdft(fpidx(e))),'ro')
    s=sprintf('%.1d & %.1d',fz(e),fz(e)*2);
    title(s)
    hold off
end

end