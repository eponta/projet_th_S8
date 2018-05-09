function [ pos_max_corrige ] = correct_offset( offset_moy, N, Nsync, n, l )
%CORRECT_OFFSET calcule la position (corrig�e selon la moyenne) des d�buts de trames (indice premier
%�l�ment du CP de taille l) du signal � N trames d'info, Nsync trames de synchro, n sous-porteuses.
%   Detailed explanation goes here

for i = 1 : N + Nsync
   pos_max_corrige(i) = offset_moy(i) + (i-1)*(l+n) + 1;
end

end

