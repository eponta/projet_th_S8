function [ sig_out ] = decision( B )
%decision sur le signal B pour obtenir sig_out (BPSK)
%   Detailed explanation goes here

sig_out(B >= 0) = 1;
sig_out(B < 0) = -1;

end

