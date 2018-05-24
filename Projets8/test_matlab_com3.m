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
N=1; %nombre de trames
Nsync=N/10;
Ns=n*N; %nomre de symboles total
n_moy_offset = 10; %nb de termes pour le calcul de la moy offset*
delta=0; %decalage de phase dans le canal
H=[0.407, 0.815, 0.407]; %canal

% Bruit

SNR = 1000;
sigma2 = 0.01; %carré de la variance du bruit
moyenne = 0; %offset du bruit
bruit_r = moyenne + sqrt(sigma2/2)*randn(1,Ns+l*(Ns/n)); %calcul du bruit réel
bruit_i = moyenne + sqrt(sigma2/2)*randn(1,Ns+l*(Ns/n)); %calcul du bruit imaginaire

offset = zeros(1,randi(100)); %offset aléatoire


%Détection pics

seuil_max = 0.65;
seuil_min = 0.3;

%% Emission

message='helloworld!!!!!!';
i_message=uint8(message);
mat_bit_message=de2bi(i_message,8);
x=reshape(mat_bit_message',1,[]);
%x=randi(2,1,Ns)-1; %génération du signal aléatoire

%% Insertion bits aleatoires connu

% tab_aleatoire=randi(2,1,7)-1;

% for k=1:N
%     for i=1:7
%         x=[x(1:i*16+i-1),tab_aleatoire(i),x(i*16+i:end)];
%     end
% end

% symbole connu

PRBS = randi(2,1,n)-1;

x=[PRBS,x];
for i=2:(N/10)
    x=[x(1:(i-1)*128*11),PRBS,x((i-1)*128*10+1:end)];
end

%% Association_bit_symbole

ss= x*2-1;
symbole_trames_pilote=PRBS*2-1;

%S/P

% for k=1:(Ns+(128*N/10))/n
%     ssp((k-1)*n+1:(k-1)*n+n)=sqrt(n)*ifft(ss((k-1)*n+1:(k-1)*n+n));
% end;

ssp=SP_IFFT(ss,N,Ns,n,Nsync);


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

for i = 1:N+(N/10)
    vrai_indice_prefixe(i)=1+(n+l)*(i-1) + length(offset); %calcul théorique de la position des indices
end

%P/S : pas besoin sur Matlab



%% Canal



spc_b = cat(2, offset, spc);

% canal
% for i = 1 : N + N/10
%     spc_c(i*(n-1)+1 : i*n) = conv(spc_c(i*(n-1)+1 : i*n), H, 'same');
% end
spc_c = conv(spc_b,H,'same');

%Bruit
spc_c=spc_c.*exp(1i*2*pi*delta*(0:length(spc_c)-1));
spc_c=awgn(spc_c,SNR);



%% Réception


%Detection prefixe

A = zeros(length(ssp)/n, n); %matrice de stockage du signal final (parallèle)
cpt_mat = 1;
cpt_max = 1;
test_pic = 0;
cpt_pos_max = 1;


%Corrélation entre deux buffers espacés de n

for i = 1 : length(spc_c)-n-l+1;
    %     sum = 0;
    buffer = spc_c(i : i+n+l-1);
    test = (buffer(1 : l)*buffer(n+1 :n+l)');
    %     for k = 0 : l - 1
    %        sum = sum + abs(buffer(n+k+1))^2;
    %     end
    epsilon = abs(test)^2/((buffer(1:l)*buffer(1:l)')*(buffer(n+1:n+l)*buffer(n+1:n+l)'));
    eps(i) = epsilon;
    
end;

plot(eps); %Affichage de la corrélation


%Detection des pics


for i=1:N+(N/10)-1
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
for i = 1 : N+(N/10)-1
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

for i = n_moy_offset:N+(N/10)-1
    sum=0;
    for k=0:n_moy_offset-1
        sum = sum + offset_exp(i-k);
    end
    offset_moy(i) = round(sum/n_moy_offset);
    
end


%correction

pos_max_corrige(1)=offset_moy(1);
for i=1:N+(N/10)-1
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
    buffer = spc_c(pos_max_corrige(i)+l:pos_max_corrige(i)+n+l-1);
    A(cpt_mat, :) = buffer;
    cpt_mat = cpt_mat + 1;
    
    
end

%% detection des trames pilotes

for i = 1 : N+(N/10);
    buffer = A(i,:);
    test = (buffer*ifft(PRBS)');
    epsilon = abs(test)^2/((buffer*buffer')*(ifft(PRBS)*ifft(PRBS)'));
    eps2(i) = epsilon;
    
end;

figure;
plot(eps2);

for i=1:(N/10)%detection des pics de eps2
    buffer=eps2((i-1)*10+1:i*10);
    [maxi,indice]=max(buffer);
    pos_max_pilote(i)=indice+(i-1)*10;
end

hold all %Affichage des débuts de trame
stem(pos_max_pilote,eps2(pos_max_pilote)); %pratique (détecté)
title('Detection pic non corrige');

%% prelevement des trames pilotes

for i=1:(N/10)
    trames_pilote(i,:)=A(pos_max_pilote(i),:);
end

%% FFT

B1 = (sqrt(n)./(fft(A.')));
trames_pilote_bin = (fft(trames_pilote.'))./sqrt(n);


%P -> S

B1=B1(:);
B1=B1';
trames_pilote_bin=trames_pilote_bin.';


%% Coeff canal
% for i=1:n
%     sum=0;
%     for j=1:(N/10)
%         coef_canal = trames_pilote_bin(j,:)./symbole_trames_pilote;
%         sum=sum+coef_canal(j,i);
%     end
%     moy_coef_canal(i)=sum/(N/10);
% end

coef_canal=zeros(1,n);
for j=1:(N/10)
    coef_canal = coef_canal + trames_pilote_bin(j,:)./symbole_trames_pilote;
end
moy_coef_canal=coef_canal/(N/10);


%% Symbole -> bits

B(B1 >= 0) = 1;
B(B1 < 0) = -1;

% trames_pilote_bin(trames_pilote_bin >= 0) = 1;
% trames_pilote_bin(trames_pilote_bin < 0) = -1;



B=(B+1)/2;
% trames_pilote_bin=(trames_pilote_bin+1)/2;

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
%%
figure
plot(abs(fft(H,n)));
hold all
plot(abs(moy_coef_canal));


