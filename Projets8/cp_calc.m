function [ prefixes, indices_cp ] = cp_calc( ssp, N, n, l, offset)
%CP_CALC retourne un tableau des préfixes ainsi que la position de leur
%premier élément
%   A partir du signal ssp (vecteur avec offset) de taille : N trames et n
%   sous-porteuses, retourne les préfixes cycliques de taille l et leur
%   position.

prefixes = zeros(length(ssp)/n, l);
prefixes(1, :)=ssp(n - l + 1 : n);               %remplissage du tableau pour le 1e préfixe
for j = 2 : (length(ssp) / n);                   %traitement des trames suivantes
    temp = ssp(j*n - l + 1 : j*n);
    prefixes(j, :) = temp;
end
for i = 1:N+(N/10)
    indices_cp(i)=1+(n+l)*(i-1) + length(offset); %calcul théorique de la position des indices
end
end

