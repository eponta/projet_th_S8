function [ offset_moy ] = moyenne_offset( offset_pratique, N, Nsync, n_moy_offset )
%MOYENNE_OFFSET moyenne (sur les n_moy_offset dernier résultats) les valeurs des offsets trouvés en 
%pratique(offset_pratique pour obtenir l'offset final (avec adaptation dans
%le temps) d'un signal signal à N trames d'info, Nsync trames de synchro, n
%sous-porteuses et des CP de taille l
%   Detailed explanation goes here

sum = 0;
for i = 1:n_moy_offset %adaptation temporelle de la moyenne
   sum = sum + offset_pratique(i);
   offset_moy(i) = round(sum/i);
   
end

for i = n_moy_offset:N+Nsync 
    sum=0;
    for k=0:n_moy_offset-1
       sum = sum + offset_pratique(i-k);
    end
   offset_moy(i) = round(sum/n_moy_offset);
   
end

end

