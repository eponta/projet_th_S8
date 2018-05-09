function [ eps ] = correl_cp( spc_c, n, l )
%CORREL_CP calcul corr�lation entre le pr�fixe cyclique (l premiers
%�chantillons) et les l derniers �chantillons d'une fen�tre de n �chantillons. 
%   La boucle for balaye le signal spc_c avec une fen�tre de n
%   �chantillons.

for i = 1 : length(spc_c)-n-l+1;
%     sum = 0;
    buffer = spc_c(i : i+n+l-1);
    test = (buffer(1 : l)*buffer(n+1 :n+l)');
%     for k = 0 : l - 1
%        sum = sum + abs(buffer(n+k+1))^2;
%     end
    epsilon = abs(test)^2/((buffer(1:l)*buffer(1:l)')*(buffer(n+1:n+l)*buffer(n+1:n+l)'));
    eps(i) = epsilon;
   
end;
end

