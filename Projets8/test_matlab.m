clear all
close all
clc

fe=10000;
Ts=0.001;
Ns=5000;
Nfft=512;
xaxisf=-(fe/2):fe/Nfft:(fe/2)-(fe/Nfft);
n=128; %nombre de sous porteuses
l=16;%taille du préfixe cyclique

%association_bit_symbole

x=randi(2,1,Ns)-1;
ss= x*2-1;

%S/P


for k=1:(5000/n)
    ssp((k-1)*n+1:(k-1)*n+n)=ifft(ss((k-1)*n+1:(k-1)*n+n));
end;

%prefixe cyclique
spc=[ssp(n-15:n),ssp];
for j = 2:(length(ssp)/n);
    temp = ssp(j*n-15:j*n);
    spc_temp = [spc(1:(j-1)*n+(j-1)*16), temp];
    spc = [spc_temp , spc((j-1)*n+(j-1)*16+1:end)];
end;

%P/S : pas besoin sur Matlab

A = zeros(length(ssp)/n, n);
cpt_mat = 1;
  
for i = 1:5616 - n - l + 1;
  
    cpt = 0;
    buffer = spc(i:i+n+l-1);
    for i1 = 1:16
       if buffer(i1) ==  buffer(i1 + n)%bruit!
          cpt = cpt + 1; 
      end

    if cpt == 16
        A(cpt_mat, :) = buffer(17:n+l);
        cpt_mat = cpt_mat + 1;
        cpt = 0;
    end
end

%FFT

B = (real(fft(A.')'));

    