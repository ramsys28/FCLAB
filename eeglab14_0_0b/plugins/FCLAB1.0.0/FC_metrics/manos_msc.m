function outEEG=fcmetric_MSC(inEEG)

[m1 n1]=size(EEG.data);
for i1=1:m1-1
    for j1=i+1:m1
        [Cxy F]=mscohere(EEG.data(i1,:),EEG.data(j1,:),50,1,[],EEG.srate);
        [m n]=size(F);
        for i=1:m
            if F(i,1)>0.5
                start_delta=i;
                break;
            end;
        end;
        for i=1:m
            if F(i,1)>4
                start_theta=i;
                break;
            end;
        end;
        for i=1:m
            if F(i,1)>8
                start_alpha1=i;
                break;
            end;
        end;
        for i=1:m
            if F(i,1)>10
                start_alpha2=i;
                break;
            end;
        end;

        for i=1:m
            if F(i,1)>12
                start_beta=i;
                break;
            end;
        end;

        for i=1:m
            if F(i,1)>30
                start_gamma=i;
                break;
            end;
        end;

        for i=2:m
            if F(i,1)>45
                end_gamma=i-1;
                break;
            end;
        end;
        
        MSC.delta(i1,j1)=mean(Cxy(start_delta:start_theta-1,1));
        MSC.theta(i1,j1)=mean(Cxy(start_theta:start_alpha1-1,1));
        MSC.alpha1(i1,j1)=mean(Cxy(start_alpha1:start_alpha2-1,1));
        MSC.alpha2(i1,j1)=mean(Cxy(start_alpha2:start_beta-1,1));
        MSC.betta(i1,j1)=mean(Cxy(start_beta:start_gamma-1,1));
        MSC.gamma(i1,j1)=mean(Cxy(start_gamma:end_gamma,1));
        
        
    end;
end;

        