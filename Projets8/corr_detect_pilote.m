function [ eps2, pos_max_pilote ] = corr_detect_pilote( A, N, Nsync, PRBS, ISR )
%DETECT_PILOTE détecte les trames pilotes du signal A [de dimension
%(N+Nsync) x n] à N trames d'info,Nsync trames de synchro et n 
%sous-porteuses. Ces trames pilotes sont%connues : PRBS. Cette fonction 
%retourne les indices de départ des traces pilotes
%   Detailed explanation goes here

for i = 1 : N+Nsync %calcul de la corrélation
    buffer = A(i, :);
    test = (buffer*ifft(PRBS)');
    epsilon = abs(test)^2/((buffer*buffer')*(ifft(PRBS)*ifft(PRBS)'));
    eps2(i) = epsilon;
   
end

if Nsync > 0
    for i=1:Nsync - 1 %detection des pics
        buffer = eps2((i-1)*ISR+1 : i*ISR);
        [maxi, indice] = max(buffer);
        pos_max_pilote(i) = indice + (i-1)*ISR;
    end
    buffer = eps2((Nsync-1)*ISR + 1 : end);
    [maxi, indice] = max(buffer);
    pos_max_pilote(Nsync) = indice + (Nsync-1)*ISR;
else
    pos_max_pilote = [];
end

end

