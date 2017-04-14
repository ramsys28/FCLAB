function Y_sm=smoothing(Y,P,N,M_i,T,auto,nloop,K,norder)
if nargin<8,norder=4; K=min(floor(1/4*T),35)+norder;end
if nargin<7,nloop=500;end
if nargin<6,auto=0.7;end

M = sum(M_i);                   % total number of trials 
        ids = zeros(M,1);
        temp=0;
         for m=1:N
             
             for l=(1:M_i(m))
                 ids(temp+l)=m;
             end
             temp=temp+M_i(m);
         end
G=1;
group=ones(N,1);
groups=ones(length(ids),1);
orth=1;


bsl=create_bspline_basis([1,T],K,norder);  %k is the number of basis 
R=bsplinepen(bsl,int2Lfd(2),[1,T],0);

[U D]=eig(R);
D_plus=D(3:K,3:K);
U_F=U(:,1:2);
U_R=U(:,3:K);
phi_t=eval_basis(1:1:T,bsl)';
x_xi= U_F'*phi_t;
z_zeta=sqrt(D_plus)*U_R'*phi_t;
phi_t=[x_xi; z_zeta];
if(orth==1)
    temp=[x_xi' z_zeta'];
    for k=1:K
        for q=1:(k-1)
            temp(:,k)=temp(:,k)-(temp(:,k)'*temp(:,k-q)/(temp(:,k-q)'*temp(:,k-q)))*temp(:,k-q);
        end
        temp(:,k)=temp(:,k)/sqrt(temp(:,k)'*temp(:,k));
    end
    temp=temp';
    x_xi=temp(1:2,:);
    z_zeta=temp(3:K,:);
    phi_t=temp;
    clear temp
end
X_D_xi=cell(T,1);
Z_D_zeta=cell(T,1);
for t=1:T
    X_D_xi{t}=x_xi(:,t)';
    Z_D_zeta{t}=z_zeta(:,t)';
    for p=2:P
        X_D_xi{t}=blkdiag(X_D_xi{t},x_xi(:,t)');
        Z_D_zeta{t}=blkdiag(Z_D_zeta{t},z_zeta(:,t)');
    end
end        
Phi_D=cell(T,1);
for t=1:T
    Phi_D{t}=zeros(P,P*K);
    for p=1:P
        Phi_D{t}(p,((p-1)*K+1):(p*K))=phi_t(:,t)';
    end
end
        % number of iterations

           
        
        % initialize parameters

            B=zeros(P,P,nloop+1);
            for q=1:nloop+1
                B(:,:,q)=auto*eye(P);
            end
            XI_IJ=zeros(P*2,M,nloop+1);
            ZETA_IJ=zeros(P*(K-2),M,nloop+1);
            XI_I=zeros(P*2,N,nloop+1);
            ZETA_I=zeros(P*(K-2),N,nloop+1);
            XI_G=zeros(P*2,G,nloop+1);
            ZETA_G=zeros(P*(K-2),G,nloop+1);
            SIGMA_EPS=zeros(P,P,G,nloop+1);
            for g=1:G
                SIGMA_EPS(:,:,g,1)=eye(P);
            end
            SIGMA_XI=zeros(2*P,2*P,nloop+1);
            SIGMA_XI(:,:,1)=eye(2*P);
            SIGMA_XI_G=zeros(2*P,2*P,G,nloop+1);
            for g=1:G
                SIGMA_XI_G(:,:,g,1)=eye(2*P);
            end
            SIGMA_SQ_ZETA=.1*ones(1,nloop+1);
            SIGMA_ZETA_G=zeros(K-2,K-2,P,G,nloop+1);
            for p=1:P
                for g=1:G
                    SIGMA_ZETA_G(:,:,p,g,1)=eye(K-2);
                end
            end
            D=inv(D_plus);
            for p=2:P
                D=blkdiag(D,inv(D_plus));
            end                
            Y_SM=zeros(T,P,M,nloop+1);
            EPS=zeros(T,P,M);
            
        %Hyperparameters

            pi1=.01;
            pi2=.01;
            eta_P=P;
            S_P=0.01*eye(P);
            eta_2P=2*P;
            S_2P=.001*eye(2*P);
            eta_K2=(K-2);
            S_K2=.001*eye(K-2);
            c=1000;

            
        % run MCMC to smooth data


            for iter=1:nloop

iter
            

            
            % Draw SIGMA_EPS

                for g=1:G
                    S_eps_g=eta_P*S_P;
                    M_g=0;
                    for i=1:N
                        g_i=groups(ids==i);
                        if(g_i(1)==g)
                            Xi_i=XI_IJ(:,ids==i,iter);
                            Zeta_i=ZETA_IJ(:,ids==i,iter);
                            Y_i=Y(:,:,ids==i);
                            EPS_i=EPS(:,:,ids==i);
                            for j=1:M_i(i)
                                M_g=M_g+1;
                                Xi_ij=Xi_i(:,j);
                                Zeta_ij=Zeta_i(:,j);
                                Y_ij=Y_i(:,:,j);
                                EPS_ij=EPS_i(:,:,j);
                                for t=1:T
                                    if(t>1)
                                        S_eps_g=S_eps_g+(Y_ij(t,:)'-X_D_xi{t}*Xi_ij-Z_D_zeta{t}*Zeta_ij-B(:,:,iter)*EPS_ij(t-1,:)')*...
                                            (Y_ij(t,:)'-X_D_xi{t}*Xi_ij-Z_D_zeta{t}*Zeta_ij-B(:,:,iter)*EPS_ij(t-1,:)')';
                                    else
                                        S_eps_g=S_eps_g+(Y_ij(t,:)'-X_D_xi{t}*Xi_ij-Z_D_zeta{t}*Zeta_ij)*...
                                            (Y_ij(t,:)'-X_D_xi{t}*Xi_ij-Z_D_zeta{t}*Zeta_ij)';
                                    end
                                end
                            end
                        end
                    end
                    eta_eps_g = eta_P+M_g*T;
                    S_eps_g = .5*(S_eps_g+S_eps_g');
                    inv_S_eps_g = inv(S_eps_g);
                    inv_S_eps_g = .5*(inv_S_eps_g+inv_S_eps_g');
                    SIGMA_EPS(:,:,g,iter+1)=inv(wishrnd(inv_S_eps_g,eta_eps_g));                   
                end
                
                
            % Draw B
            
%                 B(:,:,iter+1)=B(:,:,iter);
%                 for(p=1:P)
%                     Sigma_b_p=eye(P)/c;
%                     mu_b_p=0*ones(P,1);
%                     for(i=1:N)
%                         Y_i=Y(:,:,find(ids==i));
%                         EPS_i=EPS(:,:,find(ids==i));
%                         g_i=groups(find(ids==i));
%                         for(j=1:M_i(i))
%                             Y_ij=Y_i(:,:,j);
%                             EPS_ij=EPS_i(:,:,j);
%                             for(t=2:T)
%                                Sigma_b_p=Sigma_b_p+EPS_ij(t-1,p)^2*inv(SIGMA_EPS(:,:,g_i(1),iter+1));
%                                temp=EPS_ij(t,:)';
%                                for(p_prime=1:P)
%                                    if(not(p_prime==p))
%                                        temp=temp-EPS_ij(t-1,p_prime)*B(:,p_prime,iter+1);
%                                    end
%                                end
%                                mu_b_p=mu_b_p+EPS_ij(t-1,p)*inv(SIGMA_EPS(:,:,g_i(1),iter+1))*temp;
%                             end
%                         end
%                     end
%                     Sigma_b_p=.5*(Sigma_b_p+Sigma_b_p');
%                     Sigma_b_p=inv(Sigma_b_p);
%                     Sigma_b_p=.5*(Sigma_b_p+Sigma_b_p');
%                     mu_b_p=Sigma_b_p*mu_b_p;
%                     B(:,p,iter+1)=mvnrnd(mu_b_p,Sigma_b_p)';
%                 end
               % if(iter<=20)
               %     B(:,:,iter+1)=1*eye(P);
               % end

            
            
            % Draw XI_IJ
            
                for i=1:N
                    Y_i=Y(:,:,ids==i);
                    g_i=groups(ids==i);
                    Xi_i=XI_I(:,i,iter);
                    Zeta_ij=ZETA_IJ(:,ids==i,iter);
                    Xi_ij=XI_IJ(:,ids==i,iter);
                    for j=1:M_i(i)
                        Sigma_xi_ij=inv(SIGMA_XI(:,:,iter));
                        mu_xi_ij=inv(SIGMA_XI(:,:,iter))*Xi_i;
                        for t=1:T
                            if(t==1)
                                Sigma_xi_ij=Sigma_xi_ij+X_D_xi{t}'*inv(SIGMA_EPS(:,:,g_i(1),iter+1))*X_D_xi{t};
                                mu_xi_ij=mu_xi_ij+X_D_xi{t}'*inv(SIGMA_EPS(:,:,g_i(1),iter+1))*(Y_i(t,:,j)'-Z_D_zeta{t}*Zeta_ij(:,j));
                            else
                                Sigma_xi_ij=Sigma_xi_ij+(X_D_xi{t}-B(:,:,iter+1)*X_D_xi{t-1})'*inv(SIGMA_EPS(:,:,g_i(1),iter+1))*...
                                    (X_D_xi{t}-B(:,:,iter+1)*X_D_xi{t-1});
                                mu_xi_ij=mu_xi_ij+(X_D_xi{t}-B(:,:,iter+1)*X_D_xi{t-1})'*inv(SIGMA_EPS(:,:,g_i(1),iter+1))*...
                                    (Y_i(t,:,j)'- Z_D_zeta{t}*Zeta_ij(:,j)- B(:,:,iter+1)*(Y_i(t-1,:,j)'-Z_D_zeta{t-1}*Zeta_ij(:,j)));
                            end
                        end
                        Sigma_xi_ij=.5*(Sigma_xi_ij+Sigma_xi_ij');
                        Sigma_xi_ij=inv(Sigma_xi_ij);
                        Sigma_xi_ij=.5*(Sigma_xi_ij+Sigma_xi_ij');
                        mu_xi_ij=Sigma_xi_ij*mu_xi_ij;
                        Xi_ij(:,j)=mvnrnd(mu_xi_ij,Sigma_xi_ij)';
                    end
                    XI_IJ(:,ids==i,iter+1)=Xi_ij;
                end
                %XI_IJ(:,:,iter+1)=b(1:2,:);                

                
                        % Compute Y_SM and EPS

                            for i=1:N
                                Y_i=Y(:,:,ids==i);
                                Xi_ij=XI_IJ(:,ids==i,iter+1);
                                Zeta_ij=ZETA_IJ(:,ids==i,iter);
                                Y_sm_i=Y_SM(:,:,ids==i,iter+1);
                                EPS_i=EPS(:,:,ids==i);
                                for j=1:M_i(i)
                                    for t=1:T
                                        Y_sm_i(t,:,j)=(X_D_xi{t}*Xi_ij(:,j)+Z_D_zeta{t}*Zeta_ij(:,j))';
                                        EPS_i(t,:,j)=Y_i(t,:,j)-Y_sm_i(t,:,j);
                                    end
                                end
                                Y_SM(:,:,ids==i,iter+1)=Y_sm_i;
                                EPS(:,:,ids==i)=EPS_i;
                            end
                            %Y_SM(:,:,:,iter+1)=bold;                            
                            %EPS=Y-bold;                            

                            
            % Draw XI_I
            
                for i=1:N
                    g_i=groups(ids==i);
                    Sigma_xi_i=inv(M_i(i)*inv(SIGMA_XI(:,:,iter))+inv(SIGMA_XI_G(:,:,g_i(1),iter)));
                    Sigma_xi_i=.5*(Sigma_xi_i+Sigma_xi_i');
                    Xi_ij=XI_IJ(:,ids==i,iter+1);
                    Xi_g=XI_G(:,g_i(1),iter);
                    mu_xi_i=inv(SIGMA_XI_G(:,:,g_i(1),iter))*Xi_g;
                    for j=1:M_i(i)
                        mu_xi_i=mu_xi_i+inv(SIGMA_XI(:,:,iter))*Xi_ij(:,j);
                    end
                    mu_xi_i=Sigma_xi_i*mu_xi_i;
                    XI_I(:,i,iter+1)=mvnrnd(mu_xi_i,Sigma_xi_i)';
                end
                
                
            % Draw XI_G
            
                for g=1:G
                    N_g=sum(group==g);
                    Sigma_xi_g=inv(N_g*inv(SIGMA_XI_G(:,:,g,iter))+eye(2*P)/c);
                    Sigma_xi_g=.5*(Sigma_xi_g+Sigma_xi_g');
                    mu_xi_g=zeros(2*P,1);
                    for i=1:N
                        g_i=groups(ids==i);
                        if(g_i(1)==g)
                            mu_xi_g=mu_xi_g+inv(SIGMA_XI_G(:,:,g,iter))*XI_I(:,i,iter+1);
                        end
                    end
                    mu_xi_g=Sigma_xi_g*mu_xi_g;
                    XI_G(:,g,iter+1)=mvnrnd(mu_xi_g,Sigma_xi_g)';
                end

                
            % Draw SIGMA_XI
            
                eta_xi = eta_2P+M;
                S_xi=eta_2P*S_2P;
                for i=1:N
                    Xi_ij=XI_IJ(:,ids==i,iter+1);
                    for j=1:M_i(i)
                        S_xi=S_xi+(Xi_ij(:,j)-XI_I(:,i,iter+1))*(Xi_ij(:,j)-XI_I(:,i,iter+1))';
                    end
                end
                S_xi = .5*(S_xi+S_xi');
                inv_S_xi = inv(S_xi);
                inv_S_xi = .5*(inv_S_xi+inv_S_xi');
                SIGMA_XI(:,:,iter+1) = inv(wishrnd(inv_S_xi,eta_xi));
                

            % Draw SIGMA_XI_G
            
                for g=1:G
                    N_g=sum(group==g);
                    eta_xi_g = eta_2P+N_g;
                    S_xi_g=eta_2P*S_2P;
                    for i=1:N
                        g_i=groups(ids==i);
                        if(g_i(1)==g)
                            Xi_i=XI_I(:,i,iter+1);
                            S_xi_g=S_xi_g+(Xi_i-XI_G(:,g,iter+1))*(Xi_i-XI_G(:,g,iter+1))';
                        end
                    end
                    S_xi_g = .5*(S_xi_g+S_xi_g');
                    inv_S_xi_g = inv(S_xi_g);
                    inv_S_xi_g = .5*(inv_S_xi_g+inv_S_xi_g');
                    SIGMA_XI_G(:,:,g,iter+1) = inv(wishrnd(inv_S_xi_g,eta_xi_g));
                end
                
                
            % Draw ZETA_IJ
            
                for i=1:N
                    Y_i=Y(:,:,ids==i);
                    g_i=groups(ids==i);
                    Zeta_i=ZETA_I(:,i,iter);
                    Zeta_ij=ZETA_IJ(:,ids==i,iter);
                    Xi_ij=XI_IJ(:,ids==i,iter+1);
                    for j=1:M_i(i)
                        %Sigma_zeta_ij=inv(SIGMA_SQ_ZETA(1,iter)*D);
                        Sigma_zeta_ij=inv(SIGMA_SQ_ZETA(1,iter)*eye(P*(K-2)));
                        mu_zeta_ij=Sigma_zeta_ij*Zeta_i;
                        for t=1:T
                            if(t==1)
                                Sigma_zeta_ij=Sigma_zeta_ij+Z_D_zeta{t}'*inv(SIGMA_EPS(:,:,g_i(1),iter+1))*Z_D_zeta{t};
                                mu_zeta_ij=mu_zeta_ij+Z_D_zeta{t}'*inv(SIGMA_EPS(:,:,g_i(1),iter+1))*(Y_i(t,:,j)'-X_D_xi{t}*Xi_ij(:,j));
                            else
                                Sigma_zeta_ij=Sigma_zeta_ij+(Z_D_zeta{t}-B(:,:,iter+1)*Z_D_zeta{t-1})'*...
                                    inv(SIGMA_EPS(:,:,g_i(1),iter+1))*(Z_D_zeta{t}-B(:,:,iter+1)*Z_D_zeta{t-1});
                                mu_zeta_ij=mu_zeta_ij+(Z_D_zeta{t}-B(:,:,iter+1)*Z_D_zeta{t-1})'*inv(SIGMA_EPS(:,:,g_i(1),iter+1))*...
                                    (Y_i(t,:,j)'-X_D_xi{t}*Xi_ij(:,j)- B(:,:,iter+1)*(Y_i(t-1,:,j)'-X_D_xi{t-1}*Xi_ij(:,j)));
                            end
                        end
                        Sigma_zeta_ij=.5*(Sigma_zeta_ij+Sigma_zeta_ij');
                        Sigma_zeta_ij=inv(Sigma_zeta_ij);
                        Sigma_zeta_ij=.5*(Sigma_zeta_ij+Sigma_zeta_ij');
                        mu_zeta_ij=Sigma_zeta_ij*mu_zeta_ij;
                        Zeta_ij(:,j)=mvnrnd(mu_zeta_ij,Sigma_zeta_ij)';
                    end
                    ZETA_IJ(:,ids==i,iter+1)=Zeta_ij;
                end
                %ZETA_IJ(:,:,iter+1)=b(3:5,:);                

                % Compute Y_SM and EPS

                            for i=1:N
                                
                                Y_i=Y(:,:,ids==i);
                                Xi_ij=XI_IJ(:,ids==i,iter+1);
                                Zeta_ij=ZETA_IJ(:,ids==i,iter+1);
                                
                                %b_i=squeeze(b(:,:,find(ids==i)));
                                %bold_i=bold(:,:,find(ids==i));
                                %e_i=e(:,:,find(ids==i));
                                %b_i-[Xi_ij' Zeta_ij']'
                                
                                Y_sm_i=Y_SM(:,:,ids==i,iter+1);
                                EPS_i=EPS(:,:,ids==i);
                                                                
                                for j=1:M_i(i)
                                    for t=1:T
                                        Y_sm_i(t,:,j)=X_D_xi{t}*Xi_ij(:,j)+Z_D_zeta{t}*Zeta_ij(:,j);
                                        EPS_i(t,:,j)=Y_i(t,:,j)-Y_sm_i(t,:,j);
                                    end

                                    %b_ij=b_i(:,j);
                                    %b_ij-[Xi_ij(:,j)' Zeta_ij(:,j)']'
                                    %bold_ij=bold_i(:,j);                                    
                                    %Y_sm_i-bold_i
                                    %EPS_i-e_i
                                end
                                Y_SM(:,:,ids==i,iter+1)=Y_sm_i;
                                EPS(:,:,ids==i)=EPS_i;
                            end
                            %Y_SM(:,:,:,iter+1)=bold;                            
                            %EPS=Y-bold;                            


            % Draw ZETA_I
                
                for i=1:N
                    g_i=groups(ids==i);
                    Sigma_zeta_g=SIGMA_ZETA_G(:,:,1,g_i(1),iter);
                    for p=2:P
                        Sigma_zeta_g=blkdiag(Sigma_zeta_g,SIGMA_ZETA_G(:,:,p,g_i(1),iter));
                    end
                    Sigma_zeta_i=inv(M_i(i)*inv(SIGMA_SQ_ZETA(1,iter)*D)+inv(Sigma_zeta_g));
                    % Sigma_zeta_i=inv(M_i(i)*inv(SIGMA_SQ_ZETA(1,iter)*eye(P*(K-2)))+inv(Sigma_zeta_g));
                    Sigma_zeta_i=.5*(Sigma_zeta_i+Sigma_zeta_i');
                    Zeta_ij=ZETA_IJ(:,ids==i,iter+1);
                    Zeta_g=ZETA_G(:,g_i(1),iter);
                    mu_zeta_i=inv(Sigma_zeta_g)*Zeta_g;
                    for j=1:M_i(i)
                        mu_zeta_i=mu_zeta_i+inv(SIGMA_SQ_ZETA(1,iter)*D)*Zeta_ij(:,j);
                        %mu_zeta_i=mu_zeta_i+inv(SIGMA_SQ_ZETA(1,iter)*eye(P*(K-2)))*Zeta_ij(:,j);
                    end
                    mu_zeta_i=Sigma_zeta_i*mu_zeta_i;
                    ZETA_I(:,i,iter+1)=mvnrnd(mu_zeta_i,Sigma_zeta_i)';
                end

                
            % Draw ZETA_G
            
                for g=1:G
                    N_g=sum(group==g);
                    Sigma_g=SIGMA_ZETA_G(:,:,1,g,iter);
                    for p=2:P
                        Sigma_g=blkdiag(Sigma_g,SIGMA_ZETA_G(:,:,p,g,iter));
                    end
                    Sigma_zeta_g=inv(N_g*inv(Sigma_g)+eye((K-2)*P)/c);
                    Sigma_zeta_g=.5*(Sigma_zeta_g+Sigma_zeta_g');
                    mu_zeta_g=zeros((K-2)*P,1);
                    for i=1:N
                        g_i=groups(ids==i);
                        if(g_i(1)==g)
                            mu_zeta_g=mu_zeta_g+inv(Sigma_g)*ZETA_I(:,i,iter+1);
                        end
                    end
                    mu_zeta_g=Sigma_zeta_g*mu_zeta_g;
                    ZETA_G(:,g,iter+1)=mvnrnd(mu_zeta_g,Sigma_zeta_g)';
                end

                
            % Draw SIGMA_SQ_ZETA
            
                pi1_zeta=pi1+(K-2)*M/2;
                pi2_zeta=pi2;
                for i=1:N
                    Zeta_ij=ZETA_IJ(:,ids==i,iter+1);
                    Zeta_i=ZETA_I(:,i,iter+1);
                    for j=1:M_i(i)
                        %pi2_zeta=pi2_zeta+.5*(Zeta_ij(:,j)-Zeta_i)'*inv(D)*(Zeta_ij(:,j)-Zeta_i);
                        pi2_zeta=pi2_zeta+.5*(Zeta_ij(:,j)-Zeta_i)'*(Zeta_ij(:,j)-Zeta_i);
                    end
                end
                SIGMA_SQ_ZETA(1,iter+1)=1/gamrnd(pi1_zeta,1/pi2_zeta);


            % Draw SIGMA_ZETA_G
            
                for g=1:G
                    N_g=sum(group==g);
                    for p=1:P
                        eta_zeta_pg = eta_K2+N_g;
                        S_zeta_pg=eta_K2*S_K2;
                        ind_p=((K-2)*(p-1)+1):((K-2)*(p));                        
                        for i=1:N
                            g_i=groups(ids==i);
                            if(g_i(1)==g)
                                Zeta_pi=ZETA_I(ind_p,i,iter+1);
                                S_zeta_pg=S_zeta_pg+(Zeta_pi-ZETA_G(ind_p,g,iter+1))*(Zeta_pi-ZETA_G(ind_p,g,iter+1))';
                            end
                        end
                        S_zeta_pg = .5*(S_zeta_pg+S_zeta_pg');
                        inv_S_zeta_pg = inv(S_zeta_pg);
                        inv_S_zeta_pg = .5*(inv_S_zeta_pg+inv_S_zeta_pg');
                        SIGMA_ZETA_G(:,:,p,g,iter+1) = inv(wishrnd(inv_S_zeta_pg,eta_zeta_pg));
                    end
                end
                
               
                
            end                    

            
            % Compute means of smooths
            
                first=nloop/2;
                last=nloop+1;
                Y_sm=mean(Y_SM(:,:,:,first:last),4);

                
