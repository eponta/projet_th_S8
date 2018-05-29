clear all
close all
clc


%% Paramètres


%PARAMETRES GLOBAUX

fe = 10000; %fréquence d'échantillonnage
Ts = 0.001; %temps symbole 
Nfft = 512; 
xaxisf = -(fe/2) : fe/Nfft : (fe/2)-(fe/Nfft);
n = 128; %nombre de sous-porteuses
l = 16;%taille du préfixe cyclique
N = 1; %nombre de trames
ISR = 10; %info/synchro ratio : 1 trame de synchro pour 10 trames d'info
Nsync = 0%floor(N/ISR); %nombre de trames de synchro
Ns = n*N; %nomre de symboles total
n_moy_offset = 10; %nb de termes pour le calcul de la moy offset
delta = 20; %decalage de phase dans le canal

SNR = 10;

offset = zeros(1,randi(100)); %offset aléatoire
silence = zeros(1, 1+n+l); %silence à ajouter au signal pour pouvoir le traiter en entier (pb dernière trame)

%% Emission

message='hello world ! :)';
i_message=uint8(message);
mat_bit_message=de2bi(i_message,8);
sig_in=reshape(mat_bit_message',1,[]);
%sig_in = randi(2,1,Ns)-1; %génération du signal aléatoire

%GENERATION ET INSERTION DES TRAMES DE SYNCHRO

[x, PRBS] = PRBS_insert( sig_in, Nsync, n, ISR );

for i = 1 : Nsync
    test(i, :) = x((i-1)*n*(ISR+1) +1 : (i-1)*n*(ISR+1)+n) - PRBS;
end

% ASSOCIATION BITS -> SYMBOLES

ss = x*2-1;

% S -> P + IFFT

ssp = SP_IFFT( ss, N, n, Nsync);

% INSERTION DES PREFIXES CYCLIQUES

spc = insert_cp(ssp, N, n, l); 

% CREATION TABLEAU DE PREFIXES ET CALCUL DES INDICES

[prefixes, vrai_indice_prefixe] = cp_calc(ssp, N, Nsync, n, l, offset);

%P/S : pas besoin sur Matlab

%% Canal

% AJOUT OFFSET/SILENCE
spc_b = cat(2, offset, spc); %ajout offset
spc_b = cat(2, spc_b, silence); %ajout silence

% AJOUT DECALAGE FREQUENTIEL
spc_c = spc_b.*exp(1i*2*pi*delta*(0:length(spc_b)-1)); %décalage fréquentiel

% AJOUT DE BRUIT
spc_c = awgn(spc_c,SNR); %ajout de bruit

% % AJOUT CONVOLUTION CANAL : "Yk = conv(Hk, Xk) + Zk;"
% Hk = [0.407, 0.815, 0.407];
% for i = 1 : N + N/10
%     spc_c(i*(n-1)+1 : i*n) = conv(spc_c(i*(n-1)+1 : i*n), Hk, 'same');
% end

%% Réception

% CALCUL DE LA CORRELATION ET DETECTION DES PICS
[eps, pos_max_pratique] = corr_detect_max(spc_c, N, Nsync, n, l);
 
% CALCUL DE L'OFFSET PUIS MOYENNAGE PUIS CORRECTION
offset_pratique = calc_offset( pos_max_pratique, N, Nsync, n, l );
offset_moy = moyenne_offset( offset_pratique, N, Nsync, n_moy_offset );
pos_max_corrige = correct_offset( offset_moy, N, Nsync, n, l );
 
% AFFICHAGE DES PICS DETECTES SANS CORRECTION
figure, subplot(211);
plot(eps); %Affichage de la corrélation
hold all %Affichage des débuts de trame
stem(pos_max_pratique,eps(pos_max_pratique)); %pics pratiques (détecté)
stem(vrai_indice_prefixe,eps(vrai_indice_prefixe),'x'); %débuts trames théoriques (calculé)
title('Detection pics non corrigés(o)/Indices théoriques des CP(x) (trames)');

% AFFICHAGE DES PICS DETECTES AVEC CORRECTION

subplot(212);
plot(eps);
hold all %Affichage des débuts de trame
stem(pos_max_corrige,eps(pos_max_corrige)); %pratique (détecté)
stem(vrai_indice_prefixe,eps(vrai_indice_prefixe),'x'); %théorique (calculé)
title('Detection pic corrige (trames)');

% SUPPRESSION PREFIXES CYCLIQUES (+ S -> P)
A = supp_CP( spc_c, pos_max_corrige, N, Nsync, n, l );

% FFT + P -> S
B = PS_FFT( A, n );
sig_out = decision( B );
