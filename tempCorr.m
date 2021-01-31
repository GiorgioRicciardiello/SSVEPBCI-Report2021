function ccoeff = tempCorr(template, signal, e, toplot)

ccoeff = [];
for ct=1:40 %Iterate all templates
    [c l] = xcorr(template(:,:,ct), mean(signal(:,:),1),'coeff');
    ccoeff = [ccoeff; max(abs(c))];
end

ccoeff = normalize(ccoeff, 'range', [0 1]);

if toplot
    figure(1)
    stem(ccoeff)
    hold on
    plot(e,ccoeff(e),'r*')
    hold off    
end

end
