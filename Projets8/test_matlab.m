clear all
close all
clc


%% Param�tres


fe=10000;
Ts=0.001;
Ns=128*3;
Nfft=512;
xaxisf=-(fe/2):fe/Nfft:(fe/2)-(fe/Nfft);
n=128; %nombre de sous porteuses
l=16;%taille du pr�fixe cyclique

% Bruit
sigma = 0.0001;
moyenne = 0;
bruit_r = moyenne + sigma*randn(1,Ns+l*(Ns/n));
bruit_i = moyenne + sigma*randn(1,Ns+l*(Ns/n));
Err = 0.001;


%% Emission

%association_bit_symbole

x=randi(2,1,Ns)-1;
ss= x*2-1;

%S/P


for k=1:(Ns/n)
    ssp((k-1)*n+1:(k-1)*n+n)=ifft(ss((k-1)*n+1:(k-1)*n+n));
end;

%prefixe cyclique

spc=[ssp(n-15:n),ssp];
cpt=2;
prefixes = zeros(length(ssp)/n, l);
prefixes(1,:)=ssp(n-15:n);
for j = 2:(length(ssp)/n);
    temp = ssp(j*n-15:j*n);
    spc_temp = [spc(1:(j-1)*n+(j-1)*16), temp];
    spc = [spc_temp , spc((j-1)*n+(j-1)*16+1:end)];
    prefixes(cpt,:)=temp;
    cpt=cpt+1;
    
end;

%P/S : pas besoin sur Matlab


%% Canal

%Bruit

spc_b = spc + bruit_r + i*bruit_i;

%% R�ception

%Detection prefixe
A = zeros(length(ssp)/n, n);
cpt_mat = 1;
prefixes_detect =zeros(length(ssp)/n, l);
for i = 1:length(spc_b)-n-l+1;
  
    buffer = spc_b(i:i+n+l-1);
    test = (buffer(1:l)-buffer(n+1:n+l));
    
    if abs(sum(test)) < Err
         A(cpt_mat, :) = buffer(17:n+l);
         prefixes_detect(cpt_mat,:)=buffer(1:l);
         cpt_mat = cpt_mat + 1;
    end;
end;


% for i = 1:length(spc) - n - l + 1;
%   
%     cpt = 0;
%     buffer = spc(i:i+n+l-1);
%     for i1 = 1:16
%        if abs(buffer(i1) -  buffer(i1 + n)) < Err%bruit!
%           cpt = cpt + 1; 
%       end
% 
%     if cpt == 16
%         A(cpt_mat, :) = buffer(17:n+l);
%         cpt_mat = cpt_mat + 1;
%         cpt = 0;
%     end
%     end;
% end

%FFT

B = ((fft(A.')));


%P -> S

B=B(:);
B=B';


%Symbole -> bits

B(B >= 0) = 1;
B(B < 0) = -1;

B=(B+1)/2;

%TEB

cpt_teb =0;
for k=1:Ns
    if (B(k)~=x(k))
        cpt_teb=cpt_teb+1;
    end;
end;

TEB = cpt_teb/Ns;

% subplot(211)
% stem(spc);
% subplot(212)
% stem(spc_b);


    