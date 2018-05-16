function [ A ] = supp_CP( spc_c, pos_max_corrige, N, Nsync, n, l )
%SUPP_CP extrait du signal spc_c à N trames d'info, Nsync trames de
%synchro, n sous-porteuses et des CP de taille l, un signal A sans CP.
%pos_max_corrige sont les positions des premiers symboles de chaque CP à
%supprimer.
%   supp_CP extrait le signal A en paralèlle depuis le signal spc_c en
%   série.

cpt = 1;
for i = 1 : N + Nsync  
    A(cpt, :) = spc_c(pos_max_corrige(i)+l:pos_max_corrige(i)+n+l-1);
    cpt = cpt + 1;        
end

end

