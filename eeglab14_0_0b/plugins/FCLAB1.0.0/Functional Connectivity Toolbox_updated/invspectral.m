function r=invspectral(a,lambda,h)
n=length(a);
odd=mod(n,2); %check length is odd or even
if (odd==1)
    t=(n+1)/2;
else t=n/2+1;
end
r=zeros(2*h+1,1);
for m=1:(2*h+1)
    temp=0;
    for n=1:(2*t-1)
        temp=temp+a(n)*exp(sqrt(-1)*(m-(h+1))*lambda(n));
    end
    r(m)=real(temp)/(2*t-1);
end


    