function outEEG=fcmetric_mutualinf(inEEG)
w = warning('query','last')
id = w.identifier;
warning('off',id)
mf = size(inEEG.FC.parameters.bands,1);
for bands=1:mf
    freq_range=str2num(inEEG.FC.parameters.bands{bands,1});
    for i=1:inEEG.nbchan-1
        for j=i+1:inEEG.nbchan
           Matrix(i,j)=mutualinf(inEEG.data(i,:)',inEEG.data(j,:)',inEEG.srate,freq_range(1),freq_range(2));
        end;
    end;
    Matrix=Matrix+Matrix';
     eval(['outEEG.FC.mutualinf.' strrep(inEEG.FC.parameters.bands{i,2},' ','_') '.adj_matrix=Matrix;']);
end;
            
       