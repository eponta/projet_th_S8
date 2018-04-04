clear all
close all
clc


%% Paramètres


%Paramètres globaux

fe=10000; %fréquence d'échantillonnage
Ts=0.001; %temps symbole 
Nfft=512; 
xaxisf=-(fe/2):fe/Nfft:(fe/2)-(fe/Nfft);
n=128; %nombre de sous-porteuses
l=16;%taille du préfixe cyclique
N=20; %nombre de trames
Ns=n*N; %nomre de symboles total
n_moy_offset = 10; %nb de termes pour le calcul de la moy offset


% Bruit

SNR = 10;
sigma2 = 0.01; %carré de la variance du bruit
moyenne = 0; %offset du bruit
bruit_r = moyenne + sqrt(sigma2/2)*randn(1,Ns+l*(Ns/n)); %calcul du bruit réel
bruit_i = moyenne + sqrt(sigma2/2)*randn(1,Ns+l*(Ns/n)); %calcul du bruit imaginaire

offset = zeros(1,randi(100)); %offset aléatoire


%Détection pics

seuil_max = 0.65;
seuil_min = 0.3;

%% Emission

x=randi(2,1,Ns)-1; %génération du signal aléatoire

%% Insertion bits aleatoires connu

% tab_aleatoire=randi(2,1,7)-1;

% for k=1:N
%     for i=1:7
%         x=[x(1:i*16+i-1),tab_aleatoire(i),x(i*16+i:end)];
%     end
% end

% symbole connu

test=0;
for i=1:128
    if(test==0)
        symbole(i)=0;
        test=1;
    else
        symbole(i)=1;
        test=0;
    end
end

x=[symbole,x];
for i=2:N/10
    x=[x(1:(i-1)*128*10),symbole,x((i-1)*128*10+1:end)];
end

%Association_bit_symbole

ss= x*2-1;


%S/P

for k=1:(Ns+(128*N/10))/n
    ssp((k-1)*n+1:(k-1)*n+n)=sqrt(n)*ifft(ss((k-1)*n+1:(k-1)*n+n));
end;



%préfixe cyclique

spc=[ssp(n - l + 1 : n), ssp]; %traitement de la première trame

prefixes = zeros(length(ssp)/n, l); %création tableau de préfixes
prefixes(1, :)=ssp(n - l + 1 : n); %remplissage du tableau pour le 1e préfixe

cpt_indice = 2;
indice_prefixe(1) = 1; %calcul de la position des préfixes à l'émission

for j = 2 : (length(ssp) / n);
    temp = ssp(j*n - l + 1 : j*n);
    spc_temp = [spc(1 : (j - 1)*n + (j - 1)*l), temp];
    spc = [spc_temp , spc((j - 1)*n + (j - 1)*l + 1 : end)]; %spc est le signal à émettre
    prefixes(cpt_indice, :) = temp;
    indice_prefixe(cpt_indice) = (j - 1)*n + (j - 1)*l + 1;
    cpt_indice = cpt_indice+1;
end;



%% calcul vrai indice

for i = 1:N
    vrai_indice_prefixe(i)=1+(n+l)*(i-1) + length(offset); %calcul théorique de la position des indices
end

%P/S : pas besoin sur Matlab



%% Canal


%Bruit


spc_b=awgn(spc,SNR);
% spc_b = spc + bruit_r + 1i*bruit_i;
spc_b = cat(2, offset, spc_b);


%% Réception


%Detection prefixe

A = zeros(length(ssp)/n, n); %matrice de stockage du signal final (parallèle)
cpt_mat = 1;
cpt_max = 1;
test_pic = 0;
cpt_pos_max = 1;


%Corrélation entre deux buffers espacés de n

for i = 1 : length(spc_b)-n-l+1;
    sum = 0;
    buffer = spc_b(i : i+n+l-1);
    test = (buffer(1 : l)*buffer(n+1 :n+l)');
    for k = 0 : l - 1
       sum = sum + abs(buffer(n+k+1))^2;
    end
    epsilon = abs(test)^2/((buffer(1:l)*buffer(1:l)')*(buffer(n+1:n+l)*buffer(n+1:n+l)'));
    eps(i) = epsilon;
   
end;

plot(eps); %Affichage de la corrélation


%Detection des pics 


for i=1:N-1
   buffer=eps(1+(i-1)*(n+l):i*(n+l)); % On detecte les maxs sur des trames de 128+16 elements
   [maxi,indice]=max(buffer);
   pos_max(i)=indice + (i-1)*(n+l);
end

hold all %Affichage des débuts de trame
stem(pos_max,eps(pos_max)); %pratique (détecté)
stem(vrai_indice_prefixe,eps(vrai_indice_prefixe),'x'); %théorique (calculé)
title('Detection pic non corrige');

%Régression linéaire

% figure;
% plot(pos_max);

%Calcul offset 
sum = 0;
for i = 1 : N-1
    erreur(i) = pos_max(i) - (i-1)*(n + l);
    sum = sum + erreur(i);
    moy(i) = sum/i;
    offset_exp = round(moy);
end

% moyennage des offsets

sum = 0;
for i = 1:n_moy_offset - 1 %Il faudra faire la moyenne que sur les dernieres valeurs : adaptation
   sum = sum + offset_exp(i);
   offset_moy(i) = round(sum/i);
   
end

for i = n_moy_offset:N-1 
    sum=0;
    for k=0:n_moy_offset-1
       sum = sum + offset_exp(i-k);
    end
   offset_moy(i) = round(sum/n_moy_offset);
   
end


%correction

pos_max_corrige(1)=offset_moy(1);
for i=1:N-1
   pos_max_corrige(i+1)=offset_moy(i)+i*(l+n);
end

figure;
plot(eps);
hold all %Affichage des débuts de trame
stem(pos_max_corrige,eps(pos_max_corrige)); %pratique (détecté)
stem(vrai_indice_prefixe,eps(vrai_indice_prefixe),'x'); %théorique (calculé)
title('Detection pic corrige');

%Supression des préfixes cycliques (+ S -> P)

for i = 1 : length(pos_max_corrige) 
  
    cpt = 0;
    buffer = spc_b(pos_max_corrige(i)+l:pos_max_corrige(i)+n+l-1);
    A(cpt_mat, :) = buffer;
    cpt_mat = cpt_mat + 1;    
   
    
end



%FFT

B1 = (sqrt(n)./(fft(A.')));


%P -> S

B1=B1(:);
B1=B1';


%Symbole -> bits

B(B1 >= 0) = 1;
B(B1 < 0) = -1;

B=(B+1)/2;
% figure
%stem(B-x)


%TEB

cpt_teb = 0;
cpt_err = 1;
for k = 1:Ns
    if (B(k) ~= x(k))
        cpt_teb = cpt_teb + 1;
        indice_erreur(cpt_err) = k;
        cpt_err = cpt_err + 1;
    end;
end;

TEB = cpt_teb/Ns;

% subplot(211)
% stem(spc);
% subplot(212)
% stem(spc_b);


    