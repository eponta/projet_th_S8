function [ B ] = PS_FFT( A, n)
%PS_FFT donne le signal B, r�sultat de la FFT (normalis�e selon les n
%sous-porteuses) du signal A.
%   Detailed explanation goes here

B = ((fft(A.')./sqrt(n)));
B = B(:);
B = B';

end

