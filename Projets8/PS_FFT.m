function [ B ] = PS_FFT( A, n)
%PS_FFT donne le signal B, résultat de la FFT (normalisée selon les n
%sous-porteuses) du signal A.
%   Detailed explanation goes here

B = ((fft(A.')./sqrt(n)));
B = B(:);
B = B';

end

