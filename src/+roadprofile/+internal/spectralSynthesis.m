function z = spectralSynthesis(N, k, amp)
%SPECTRALSYNTHESIS Mean-zero real signal from one-sided amplitudes.
%   K are the harmonic numbers (1 <= K < N/2), AMP the values of |X(K)|.
phi = 2 * pi * rand(size(amp));
X = zeros(N, 1);
X(k + 1) = amp .* exp(1i * phi);
X(N - k + 1) = conj(X(k + 1));
z = real(ifft(X)) * N;
z = z - mean(z);
end