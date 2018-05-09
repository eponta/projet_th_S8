clc
close all
clear all

%% Paramètres


%Paramètres globaux

fe=10000;       %fréquence d'échantillonnage
Ts=0.001;       %temps symbole 
Nfft=512; 
xaxisf=-(fe/2):fe/Nfft:(fe/2)-(fe/Nfft);
n=128;          %nombre de sous-porteuses
l=16;           %taille du préfixe cyclique
N=10;           %nombre de trames
Nsync = 0;      %nombre de trames de synchro
Ns=n*N;         %nomre de symboles total
offset=0;       %offset introduit par le canal

%% Emission

% Génération du signal aléatoire

x=randi(2,1,Ns)-1; 

% Association_bit_symbole

ss= x*2-1;

%S/P

for k=1:(N+Nsync)
    ssp((k-1)*n+1:(k-1)*n+n)=ifft(ss((k-1)*n+1:(k-1)*n+n))./sqrt(n);
end;

%Insertion CP

spc = insert_cp(ssp, N, n, l);

[cp, ind_cp] = cp_calc(ssp, N, n, l, offset);

for i = 1 : N
   for j = 1 : l
      test(i ,j) = spc((i-1)*(n+l)+i)-cp(i, j); %faux... 
   end
end

test

ind_cp
