function p = narrowBand(L, dx, rmsHeight, wavelength, bw, seed, name)
%NARROWBAND Narrow-band stochastic surface for proving-ground patterns.
%   Called by belgianBlock and cobblestone. Not part of the public API.
%
%   Generates a Gaussian PSD centered at 1/wavelength with relative
%   bandwidth BW (fraction of the center frequency). The profile is
%   normalized so that its variance equals RMSHEIGHT^2.
%   The road must be at least wavelength/BW long.

[x, N] = roadprofile.internal.sampleGrid(L, dx, 4);
Leff = N * dx;
dn = 1 / Leff;
n0 = 1 / wavelength;
sigmaN = bw * n0;
if 1/Leff > sigmaN
    error('roadprofile:invalidLength', ...
        '%s: length %g m is shorter than wavelength/bw = %g m', ...
        name, Leff, 1/sigmaN);
end
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
k = (1:ceil(N/2)-1)';
envelope = exp(-0.5 * ((k*dn - n0) / sigmaN).^2);
G = rmsHeight^2 / (dn * sum(envelope)) * envelope;
z = roadprofile.internal.spectralSynthesis(N, k, sqrt(G * dn / 2));

p.x = x;
p.z = z;
p.dx = dx;
end