function [u,v,cr]=eigen(x,y,t,k,R,J,lambda) %x,y are matrixes here
[v11,v12,v22]=covmatrix(x,y,t,k);
A=zeros(2*(k+2),2*(k+2));
B=zeros(2*(k+2),2*(k+2));
A(1:(k+2),(k+2+1):2*(k+2))=J*v12*J;
A((k+2+1):2*(k+2),1:(k+2))=J*v12'*J;
B(1:(k+2),1:(k+2))=J*v11*J+lambda*R;
B((k+2+1):2*(k+2),(k+2+1):2*(k+2))=J*v22*J+lambda*R;
[V,D]=eig(A,B);
l=V(:,1);
u=l(1:(k+2));
v=l((k+2+1):(2*(k+2)));
cr=D(1,1);
end



