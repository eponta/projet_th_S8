clear all
close all
clc


%% Param�tres


%Param�tres globaux

fe=10000; %fr�quence d'�chantillonnage
Ts=0.001; %temps symbole 
Nfft=512; 
xaxisf=-(fe/2):fe/Nfft:(fe/2)-(fe/Nfft);
n=128; %nombre de sous-porteuses
l=16;%taille du pr�fixe cyclique
N=30; %nombre de trames
Nsync = 0; %floor(N/10); %nombre de trames de synchro
Ns=n*N; %nomre de symboles total
n_moy_offset = 15; %nb de termes pour le calcul de la moy offset
delta=0; %decalage de phase dans le canal


% Bruit

SNR = 10;
sigma2 = 0.01; %carr� de la variance du bruit
moyenne = 0; %offset du bruit
bruit_r = moyenne + sqrt(sigma2/2)*randn(1,Ns+l*(Ns/n)); %calcul du bruit r�el
bruit_i = moyenne + sqrt(sigma2/2)*randn(1,Ns+l*(Ns/n)); %calcul du bruit imaginaire

offset = zeros(1,randi(100)); %offset al�atoire
silence = zeros(1, 1+n+l); %silence � ajouter au signal pour pouvoir le traiter en entier (pb derni�re trame)


%D�tection pics

seuil_max = 0.65;
seuil_min = 0.3;

%% Emission

x=randi(2,1,Ns)-1; %g�n�ration du signal al�atoire

% Association_bit_symbole

ss= x*2-1;

%S/P

ssp = SP_IFFT( ss, N, Ns, n,Nsync)

% Insertion des pr�fixes cycliques

spc = insert_cp(ssp, N, n, l); 

% Cr�ation tableau de pr�fixes et calcul des indices

[prefixes, vrai_indice_prefixe] = cp_calc(ssp, N, Nsync, n, l, offset);

%P/S : pas besoin sur Matlab

%% Canal

%Bruit

spc_b = cat(2, offset, spc); %ajout offset
spc_b = cat(2, spc_b, silence); %ajout silence
%spc_c=spc_b.*exp(1i*2*pi*delta*(0:length(spc_b)-1)); %d�calage fr�quentiel
spc_c=awgn(spc_b,SNR); %ajout de bruit
%spc_b = spc + bruit_r + 1i*bruit_i;

% ajouter une convolution de canal : "Yk = conv(Hk, Xk) + Zk;"
% Hk = [0.407, 0.815, 0.407];
% for i = 1 : N + N/10
%     spc_c(i*(n-1)+1 : i*n) = conv(spc_c(i*(n-1)+1 : i*n), Hk, 'same');
% end

%% R�ception

% A = zeros(length(ssp)/n, n); %matrice de stockage du signal final (parall�le)
% cpt_mat = 1;
% cpt_max = 1;
% test_pic = 0;
% cpt_pos_max = 1;

% CALCUL DE LA CORRELATION ET DETECTION DES PICS
[eps, pos_max_pratique] = corr_detect_max(spc_c, N, Nsync, n, l);
 
% CALCUL DE L'OFFSET PUIS MOYENNAGE PUIS CORRECTION
offset_pratique = calc_offset( pos_max_pratique, N, Nsync, n, l );
offset_moy = moyenne_offset( offset_pratique, N, Nsync, n_moy_offset );
pos_max_corrige = correct_offset( offset_moy, N, Nsync, n, l );
 
% AFFICHAGE DES PICS DETECTES SANS CORRECTION
figure, subplot(211);
plot(eps); %Affichage de la corr�lation
hold all %Affichage des d�buts de trame
stem(pos_max_pratique,eps(pos_max_pratique)); %pics pratiques (d�tect�)
stem(vrai_indice_prefixe,eps(vrai_indice_prefixe),'x'); %d�buts trames th�oriques (calcul�)
title('Detection pics non corrig�s(o)/Indices th�oriques des CP(x) (trames)');

% AFFICHAGE DES PICS DETECTES AVEC CORRECTION

subplot(212);
plot(eps);
hold all %Affichage des d�buts de trame
stem(pos_max_corrige,eps(pos_max_corrige)); %pratique (d�tect�)
stem(vrai_indice_prefixe,eps(vrai_indice_prefixe),'x'); %th�orique (calcul�)
title('Detection pic corrige (trames)');