clear all
close all
clc


%% Paramètres


fe=10000;
Ts=0.001;
Nfft=512;
xaxisf=-(fe/2):fe/Nfft:(fe/2)-(fe/Nfft);
n=128; %nombre de sous porteuses
l=16;%taille du préfixe cyclique
N=10;
Ns=n*N;

% Bruit
sigma2 = 0.00001;
moyenne = 0;
bruit_r = moyenne + sqrt(sigma2/2)*randn(1,Ns+l*(Ns/n));
bruit_i = moyenne + sqrt(sigma2/2)*randn(1,Ns+l*(Ns/n));
Err = 9;


%% Emission

%association_bit_symbole

x=randi(2,1,Ns)-1;
ss= x*2-1;

%S/P


for k=1:(Ns/n)
    ssp((k-1)*n+1:(k-1)*n+n)=sqrt(n)*ifft(ss((k-1)*n+1:(k-1)*n+n));
end;

%prefixe cyclique

spc=[ssp(n-l+1:n),ssp];
cpt=2;
prefixes = zeros(length(ssp)/n, l);
prefixes(1,:)=ssp(n-l+1:n);
cpt_indice=2;
indice_prefixe(1)=1;
for j = 2:(length(ssp)/n);
    temp = ssp(j*n-l+1:j*n);
    spc_temp = [spc(1:(j-1)*n+(j-1)*l), temp];
    spc = [spc_temp , spc((j-1)*n+(j-1)*l+1:end)];
    prefixes(cpt,:)=temp;
    indice_prefixe(cpt_indice)=(j-1)*n+(j-1)*l+1;
    cpt=cpt+1;
    cpt_indice = cpt_indice+1;
end;

%% calcul vrai indice
for i = 1:N
    vrai_indice_prefixe(i)=1+(n+l)*(i-1);
end
%P/S : pas besoin sur Matlab


%% Canal

%Bruit

spc_b = spc + bruit_r + 1i*bruit_i;

%% Réception

%Detection prefixe
A = zeros(length(ssp)/n, n);
cpt_mat = 1;
cpt_max=1;
test_pic=0;
cpt_pos_max=1;

%prefixes_detect =zeros(length(ssp)/n, l);
for i = 1:length(spc_b)-n-l+1;
    sum=0;
    buffer = spc_b(i:i+n+l-1);
    test = (buffer(1:l)*buffer(n+1:n+l)');
    for k=0:l-1
       sum=sum+ abs(buffer(n+k+1))^2;
    end
    epsilon = abs(test)^2/sum;%(l*var(buffer,1))^2;
    eps(i) = epsilon;
   
end;

eps(length(spc_b)-n+1)=0;
 for j = 1:length(eps) % Detection des pics 
        if eps(j) > Err
            test_pic=1;
            buff_max(cpt_max)=eps(j);
            buff_indice(cpt_max)=j;
            cpt_max=cpt_max+1;
        elseif eps(j) < 0.35 && test_pic==1
            test_pic=0;
            cpt_max=1;
            M = max(buff_max);
            for k=1:length(buff_max)
                if buff_max(k)==M
                    pos_max(cpt_pos_max)=buff_indice(k);
                    cpt_pos_max=cpt_pos_max+1;
                end
            end
            buff_max=[];
            buff_indice=[];
        end
 end
 
 
plot(eps)

for i = 1:length(pos_max) 
  
    cpt = 0;
    buffer = spc_b(pos_max(i)+l:pos_max(i)+n+l-1);
    
    A(cpt_mat, :) = buffer;
    cpt_mat = cpt_mat + 1;
    
end

hold all
stem(pos_max,eps(pos_max));
stem(indice_prefixe,eps(indice_prefixe),'x');

%FFT

B1 = (sqrt(n)./(fft(A.')));


%P -> S

B1=B1(:);
B1=B1';


%Symbole -> bits

B(B1 >= 0) = 1;
B(B1 < 0) = -1;

B=(B+1)/2;
figure
%stem(B-x)

%TEB

cpt_teb =0;
cpt_err=1;
for k=1:Ns
    if (B(k)~=x(k))
        cpt_teb=cpt_teb+1;
        indice_erreur(cpt_err)=k;
        cpt_err=cpt_err+1;
    end;
end;

TEB = cpt_teb/Ns;

% subplot(211)
% stem(spc);
% subplot(212)
% stem(spc_b);


    