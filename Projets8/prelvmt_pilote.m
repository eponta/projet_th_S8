function [ A, trames_pilote ] = prelvmt_pilote( A_pilote, N, n, Nsync, ISR, pos_max_pilote )
%PRELVMT_PILOTE enlève et stocke dans trames_pilotes les trames de synchro
%détectées dans le signal A_pilote à N trames d'info, n sous-porteuses,
%Nsync trames de synchro, un rapport info sur synchro de ISR et dont les
%indices de début des trames pilotes sont pos_max_pilotes
%   Detailed explanation goes here

if Nsync > 0
    for i = 1 : Nsync
        trames_pilote(i, :) = A_pilote(pos_max_pilote(i), :); 
    end
else
    trames_pilote = [];
end
    
tmp = A_pilote';
tmp = tmp(:)';

if Nsync > 1
    A = tmp(pos_max_pilote(1)*n + 1 : (pos_max_pilote(2)-1)*n);
    for i = 2 : Nsync-1
        A = [A tmp(pos_max_pilote(i)*n + 1 : (pos_max_pilote(i+1)-1)*n)];
    end
    A = [A tmp(pos_max_pilote(Nsync)*n + 1 : end)];
    l = length(A);
    A = reshape(A, [ceil(length(A)/n) n]);
elseif Nsync == 1
    A = tmp(pos_max_pilote*n + 1 : end);
    A = reshape(A, [ceil(length(A)/n) n]);
else
    A = A_pilote;
end

end

