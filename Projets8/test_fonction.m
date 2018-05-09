clc
close all;
clear all;


%% Param�tres


%Param�tres globaux

fe=10000; %fr�quence d'�chantillonnage
Ts=0.001; %temps symbole
n=128; %nombre de sous-porteuses
l=16;%taille du pr�fixe cyclique
N=20; %nombre de trames
Ns=n*N; %nomre de symboles total
Nsync=0;
n_moy_offset = 10; %nb de termes pour le calcul de la moy offset*
delta=0; %decalage de phase dans le canal
H=[0.407, 0.815, 0.407]; %canal
offset=0;

% Bruit

% SNR = 1000;
% sigma2 = 0.01; %carr� de la variance du bruit
% moyenne = 0; %offset du bruit
% bruit_r = moyenne + sqrt(sigma2/2)*randn(1,Ns+l*(Ns/n)); %calcul du bruit r�el
% bruit_i = moyenne + sqrt(sigma2/2)*randn(1,Ns+l*(Ns/n)); %calcul du bruit imaginaire
% 
% offset = zeros(1,randi(100)); %offset al�atoire


%D�tection pics

% seuil_max = 0.65;
% seuil_min = 0.3;

%% Emission

x=randi(2,1,Ns)-1; %g�n�ration du signal al�atoire


%% Association_bit_symbole

ss= x*2-1;


%% S/P et IFFT

ssp=SP_IFFT(ss,N,Ns,n,Nsync);

%pr�fixe cyclique

spc=insert_cp(ssp,N,n,l);

%% canal

spc_b = cat(2, offset, spc);

% canal
%%spc_c = conv(spc_b,H,'same');

%Bruit
%spc_c=spc_c.*exp(1i*2*pi*delta*(0:length(spc_c)-1));
%spc_c=awgn(spc_c,SNR);

%% Reception
