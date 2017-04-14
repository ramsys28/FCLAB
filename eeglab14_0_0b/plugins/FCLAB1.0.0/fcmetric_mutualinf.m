function Matrix=fcmetric_mutualinf(EEG)
for i=1:EEG.nbchan
    for j=1:EEG.nbchan
        Matrix(i,j)==mutualinf(EEG.data(i,:),EEG.data,sr,lambdamin,lambdamax)
       