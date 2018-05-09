function [ pos_max_corrige ] = correct_offset( offset_moy, N, Nsync, n, l )
%CORRECT_OFFSET calcule la position (corrigée selon la moyenne) des débuts de trames (indice premier
%élément du CP de taille l) du signal à N trames d'info, Nsync trames de synchro, n sous-porteuses.
%   Detailed explanation goes here

for i = 1 : N + Nsync
   pos_max_corrige(i) = offset_moy(i) + (i-1)*(l+n) + 1;
end

end

