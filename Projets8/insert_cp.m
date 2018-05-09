function [ spc ] = insert_cp( ssp, N, n, l)
%INSERTION PREFIXE CYCLIQUE
%   A partir du signal ssp (vecteur) à n sous-porteuses, insertion de N préfixes de taille l pour obtenir le nouveau signal spc. 

spc=[ssp(n - l + 1 : n), ssp];                               %traitement de la première trame
for j = 2 : (length(ssp) / n);                               %traitement des trames suivantes
    temp = ssp(j*n - l + 1 : j*n);
    spc_temp = [spc(1 : (j - 1)*n + (j - 1)*l), temp];
    spc = [spc_temp , spc((j - 1)*n + (j - 1)*l + 1 : end)]; %spc est le signal à émettre
end
end

