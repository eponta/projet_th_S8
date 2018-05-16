function [ x, PRBS ] = PRBS_insert( sig_in, Nsync, n, ISR )
%PRBS_insert g�n�re une s�quence binaire pseudo-al�atoire. En effet, cette
%s�quence de n termes est g�n�r�e de fa�on al�atoire, mais elle sera connue
%des algorithmes d'�mission et de r�ception. 

% G�n�ration trame de synchro
PRBS = randi(2,1,n)-1;

% Insertion trames de synchro connues
x = sig_in;
x=[PRBS, x];
for i=2:(Nsync)
    x = [x(1:(i-1)*128*(ISR+1)), PRBS, x((i-1)*128*(ISR+1)+1:end)];
end

end

