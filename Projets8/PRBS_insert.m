function [ x, PRBS ] = PRBS_insert( sig_in, Nsync, n, ISR )
%PRBS_insert génère une séquence binaire pseudo-aléatoire. En effet, cette
%séquence de n termes est générée de façon aléatoire, mais elle sera connue
%des algorithmes d'émission et de réception. 

% Génération trame de synchro
PRBS = randi(2,1,n)-1;

% Insertion trames de synchro connues
x = sig_in;
x=[PRBS, x];
for i=2:(Nsync)
    x = [x(1:(i-1)*128*(ISR+1)), PRBS, x((i-1)*128*(ISR+1)+1:end)];
end

end

