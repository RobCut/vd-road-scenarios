function p = narrowBand(L, dx, amplitude, wavelength, bw, seed, name)
%NARROWBAND Narrow-band stochastic surface for proving-ground patterns.
%   Called by belgianBlock and cobblestone. Not part of the public API.
%
%   Generates a Gaussian PSD centered at 1/wavelength with relative
%   bandwidth BW (fraction of the center frequency). The profile is
%   normalized so that its variance equals AMPLITUDE^2.

N = round(L / dx);
if N < 4
    error('roadprofile:invalidLength', ...
        '%s requires at least 4 samples, got %d', name, N);
end
Leff = N * dx;
dn = 1 / Leff;
n0 = 1 / wavelength;
sigmaN = bw * n0;
nNyq = 1 / (2 * dx);
if n0 + 3 * sigmaN > nNyq
    error('roadprofile:invalidFrequency', ...
        '%s: wavelength %g m (center %g cycles/m, sigma %g) exceeds Nyquist %g cycles/m', ...
        name, wavelength, n0, sigmaN, nNyq);
end
if ~isempty(seed)
    previousState = rng;
    rng(seed, 'twister');
    cleanup = onCleanup(@() rng(previousState)); %#ok<NASGU>
end
if mod(N, 2) == 0
    nPos = (1:(N/2 - 1))' * dn;
    idxPos = (2:N/2)';
else
    nPos = (1:floor(N/2))' * dn;
    idxPos = (2:floor(N/2)+1)';
end
envelope = exp(-0.5 * ((nPos - n0) / sigmaN).^2);
C = amplitude^2 / (dn * sum(envelope));
GPos = C * envelope;
amp = sqrt(GPos * dn / 2);
phi = 2 * pi * rand(size(amp));
X = zeros(N, 1);
X(idxPos) = amp .* exp(1i * phi);
X(N - idxPos + 2) = conj(X(idxPos));
z = real(ifft(X)) * N;
z = z - mean(z);

p.x = (0:N-1)' * dx;
p.z = z;
p.dx = dx;
end