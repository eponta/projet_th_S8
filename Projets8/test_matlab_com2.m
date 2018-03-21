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
N=10; %nombre de trames
Ns=n*N; %nomre de symboles total


% Bruit

sigma2 = 0.01; %carr� de la variance du bruit
moyenne = 0; %offset du bruit
bruit_r = moyenne + sqrt(sigma2/2)*randn(1,Ns+l*(Ns/n)); %calcul du bruit r�el
bruit_i = moyenne + sqrt(sigma2/2)*randn(1,Ns+l*(Ns/n)); %calcul du bruit imaginaire

offset = zeros(1,randi(100)); %offset al�atoire


%D�tection pics

seuil_max = 0.65;
seuil_min = 0.3;

%% Emission

x=randi(2,1,Ns)-1; %g�n�ration du signal al�atoire


%Association_bit_symbole

ss= x*2-1;


%S/P

for k=1:(Ns/n)
    ssp((k-1)*n+1:(k-1)*n+n)=sqrt(n)*ifft(ss((k-1)*n+1:(k-1)*n+n));
end;


%pr�fixe cyclique

spc=[ssp(n - l + 1 : n), ssp]; %traitement de la premi�re trame

prefixes = zeros(length(ssp)/n, l); %cr�ation tableau de pr�fixes
prefixes(1, :)=ssp(n - l + 1 : n); %remplissage du tableau pour le 1e pr�fixe

cpt_indice = 2;
indice_prefixe(1) = 1; %calcul de la position des pr�fixes � l'�mission

for j = 2 : (length(ssp) / n);
    temp = ssp(j*n - l + 1 : j*n);
    spc_temp = [spc(1 : (j - 1)*n + (j - 1)*l), temp];
    spc = [spc_temp , spc((j - 1)*n + (j - 1)*l + 1 : end)]; %spc est le signal � �mettre
    prefixes(cpt_indice, :) = temp;
    indice_prefixe(cpt_indice) = (j - 1)*n + (j - 1)*l + 1;
    cpt_indice = cpt_indice+1;
end;



%% calcul vrai indice

for i = 1:N
    vrai_indice_prefixe(i)=1+(n+l)*(i-1) + length(offset); %calcul th�orique de la position des indices
end

%P/S : pas besoin sur Matlab



%% Canal


%Bruit

spc_b = spc + bruit_r + 1i*bruit_i;
spc_b = cat(2, offset, spc_b);


%% R�ception


%Detection prefixe

A = zeros(length(ssp)/n, n); %matrice de stockage du signal final (parall�le)
cpt_mat = 1;
cpt_max = 1;
test_pic = 0;
cpt_pos_max = 1;


%Corr�lation entre deux buffers espac�s de n

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

plot(eps); %Affichage de la corr�lation


%Detection des pics 


for i=1:N-1
   buffer=eps(1+(i-1)*(n+l):i*(n+l)); % On detecte les maxs sur des trames de 128+16 elements
   [maxi,indice]=max(buffer);
   pos_max(i)=indice + (i-1)*(n+l);
end

hold all %Affichage des d�buts de trame
stem(pos_max,eps(pos_max)); %pratique (d�tect�)
stem(vrai_indice_prefixe,eps(vrai_indice_prefixe),'x'); %th�orique (calcul�)


%R�gression lin�aire

figure;
plot(pos_max);

%� commenter
sum = 0;
for i = 1 : N-1
    erreur(i) = pos_max(i) - (i-1)*(n + l);
    sum = sum + erreur(i);
    moy(i) = sum/i;
    c = moy;
end


%Supression des pr�fixes cycliques (+ S -> P)

for i = 1 : length(pos_max) 
  
    cpt = 0;
    buffer = spc_b(pos_max(i)+l:pos_max(i)+n+l-1);
    
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


    