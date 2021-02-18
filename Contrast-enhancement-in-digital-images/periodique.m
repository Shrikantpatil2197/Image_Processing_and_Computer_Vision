function img_prd = periodique( imageData )
%PERIODIQUE Summary of this function goes here
%   Detailed explanation goes here
        [M,N]=size(imageData);
        img_prd=zeros(M*2,N*2);
        img_prd(1:M,1:N)=imageData(1:M,1:N);
        img_prd(M+1:M*2,1:N)=imageData(M:-1:1,1:N);
        img_prd(1:M,N+1:N*2)=imageData(1:M,N:-1:1);
        img_prd(M+1:M*2,N+1:N*2)=imageData(M:-1:1,N:-1:1);
        
end

