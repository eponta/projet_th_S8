function [ eps, pos_max_pratique ] = corr_detect_max( spc_c, N, Nsync, n, l )
%CORR_DETECT_MAX calcule la corrélation entre deux buffers espacés de n qui
%balaient le signal spc_c à N trames d'info, Nsync trames de synchro, n
%sous-porteuses et des CP de taille l
%   Detailed explanation goes here

for i = 1 : length(spc_c)-n-l+1;
    buffer = spc_c(i : i+n+l-1);
    test = (buffer(1 : l)*buffer(n+1 :n+l)');
    epsilon = abs(test)^2/((buffer(1:l)*buffer(1:l)')*(buffer(n+1:n+l)*buffer(n+1:n+l)'));
    eps(i) = epsilon;
end

for i=1:N+Nsync
   buffer=eps(1+(i-1)*(n+l):i*(n+l)); % On detecte les maxs sur des trames de 128+16 elements
   [maxi,indice]=max(buffer);
   pos_max_pratique(i)=indice + (i-1)*(n+l);
end

end

