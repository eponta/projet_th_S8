function [ prefixes, indices_cp ] = cp_calc( ssp, N, Nsync, n, l, offset)
%CP_CALC retourne un tableau des pr�fixes ainsi que la position de leur
%premier �l�ment
%   A partir du signal ssp (vecteur avec offset sans pr�fixes cycliques) de taille : N trames, Nsync trames de synchro et n
%   sous-porteuses, retourne les pr�fixes cycliques de taille l et leur
%   position.

prefixes = zeros(N, l);
for j = 1 : N;                                   %traitement des trames suivantes
    temp = ssp(j*n - l + 1 : j*n);
    prefixes(j, :) = temp;
end
for i = 1 : N + Nsync
    indices_cp(i)=1+(n+l)*(i-1) + length(offset); %calcul th�orique de la position des indices
end
end

