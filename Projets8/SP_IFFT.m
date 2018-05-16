function [ ssp ] = SP_IFFT( ss, N, n, Nsync)
%SP_IFFT fonction de l'étape S/P et IFFT de la chaine de com
%   ss le signal emis
%   N le nombre de symbole ofdm
%   Ns le nombre de symbole total
%   n le nombre de trame ofdm
%   Nsync le nombre de trame de synchro

for k = 1 : N+Nsync
    ssp((k-1)*n+1 : k*n) = sqrt(n)*ifft(ss((k-1)*n+1 : k*n));
end

end

