function [ prefixes, indices_cp ] = cp_calc( ssp, N, n, l, offset)
%CP_CALC retourne un tableau des pr�fixes ainsi que la position de leur
%premier �l�ment
%   A partir du signal ssp (vecteur avec offset) de taille : N trames et n
%   sous-porteuses, retourne les pr�fixes cycliques de taille l et leur
%   position.

prefixes = zeros(length(ssp)/n, l);
prefixes(1, :)=ssp(n - l + 1 : n);               %remplissage du tableau pour le 1e pr�fixe
for j = 2 : (length(ssp) / n);                   %traitement des trames suivantes
    temp = ssp(j*n - l + 1 : j*n);
    prefixes(j, :) = temp;
end
for i = 1:N+(N/10)
    indices_cp(i)=1+(n+l)*(i-1) + length(offset); %calcul th�orique de la position des indices
end
end

