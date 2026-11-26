function p = multiSine(L, dx, freqs, amps, options)
%MULTISINE Sum of spatial sinusoids at distinct frequencies.
%   P = MULTISINE(L, DX, FREQS, AMPS) returns a profile that is the sum
%   of sinusoids at the spatial frequencies in FREQS (cycles/m), each
%   with the corresponding amplitude in AMPS (m):
%
%       z(x) = sum_k AMPS(k) * sin(2*pi*FREQS(k)*x + PHASES(k))
%
%   P = MULTISINE(..., Phase=PHASES) sets a phase for each frequency
%   (same size as FREQS, default all zeros).
%
%   FREQS and AMPS must be vectors of the same length. All frequencies
%   must be strictly positive and strictly below Nyquist 1/(2*DX);
%   violations raise roadprofile:invalidFrequency.
%
%   See also roadprofile.sine, roadprofile.chirp.

arguments
    L (1,1) {mustBeNumeric, mustBeFinite, mustBePositive}
    dx (1,1) {mustBeNumeric, mustBeFinite, mustBePositive}
    freqs (1,:) {mustBeNumeric, mustBeFinite, mustBePositive}
    amps (1,:) {mustBeNumeric, mustBeFinite, mustBeNonnegative}
    options.Phase double {mustBeFinite} = zeros(size(freqs))
end

if numel(freqs) ~= numel(amps)
    error('roadprofile:invalidParameter', ...
        'freqs and amps must have the same length (got %d and %d)', ...
        numel(freqs), numel(amps));
end
if numel(options.Phase) ~= numel(freqs)
    error('roadprofile:invalidParameter', ...
        'Phase must have the same length as freqs (got %d and %d)', ...
        numel(options.Phase), numel(freqs));
end
N = round(L / dx);
if N < 2
    error('roadprofile:invalidLength', ...
        'Profile requires at least 2 samples, got %d', N);
end
fNyq = 1 / (2 * dx);
if any(freqs >= fNyq)
    error('roadprofile:invalidFrequency', ...
        'Frequencies must be below Nyquist %g (dx = %g m), got max %g', ...
        fNyq, dx, max(freqs));
end
x = (0:N-1)' * dx;
z = zeros(N, 1);
for k = 1:numel(freqs)
    z = z + amps(k) * sin(2 * pi * freqs(k) * x + options.Phase(k));
end

p.x = x;
p.z = z;
p.dx = dx;
end