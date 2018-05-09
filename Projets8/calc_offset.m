function [ offset_pratique ] = calc_offset( pos_max_pratique, N, Nsync, n, l )
%CALC_OFFSET calcule l'offset du signal � N trames d'info, Nsync trames de synchro, n
%sous-porteuses et des CP de taille l, en soustrayant les valeurs pratiques(o� l'offset est pr�sent) 
%des positions de d�part des trames(pos_max_pratique)par les valeurs th�oriques(sans offset). 

%   Detailed explanation goes here

sum = 0;
for i = 1 : N+Nsync
    erreur(i) = pos_max_pratique(i) - ((i-1)*(n + l) + 1);
    sum = sum + erreur(i);
    moy(i) = sum/i;
    offset_pratique(i) = erreur(i);
end

end

