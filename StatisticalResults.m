function  [Ts,Ts] = StatisticalResults(stats,ccFeatures,fpFeatures, SUBJECT, sub_run,ts)

    sum((stats(:,1)-stats(:,2))==0)/size(stats,1);

    sub_run.stats = stats;
    sub_run.acc = sum((stats(:,1)-stats(:,2))==0)/size(stats,1)*100;
    sub_run.corrFeatures = ccFeatures;
    sub_run.freqFeatures = fpFeatures; 

    rn=replace(SUBJECT,'S','');
    subnum = str2num(replace(rn,'.set',''));
    savename = replace(SUBJECT,'.set','.mat');
    savename = strcat(folder,savename);
    save(savename,'-struct','sub_run');


    Ts(ts) = SUBJECT;
    Ta(ts) = sub_run.acc;
end

