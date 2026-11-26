function p = chirp(L, dx, f0, f1, amplitude, options)
%CHIRP Linear frequency sweep (chirp) road profile.
%   P = CHIRP(L, DX, F0, F1, AMP) returns a sinusoidal profile whose
%   spatial frequency sweeps linearly from F0 at x = 0 to F1 at x = L,
%   with amplitude AMP (m):
%
%       phase(x) / (2*pi) = F0*x + (F1 - F0) * x^2 / (2*L)
%       z(x) = AMP * sin(2*pi * phase(x) + PHASE)
%
%   P = CHIRP(..., Phase=PH) sets the initial phase PH in radians
%   (default 0).
%
%   Both F0 and F1 must be strictly positive and strictly below the
%   Nyquist frequency 1/(2*DX), otherwise the chirp aliases at one end
%   of the sweep. Violations raise roadprofile:invalidFrequency.
%
%   CHIRP is useful for system identification and for exciting a
%   vehicle across a range of spatial wavelengths in a single run.
%
%   See also roadprofile.sine, roadprofile.multiSine.

arguments
    L (1,1) {mustBeNumeric, mustBeFinite, mustBePositive}
    dx (1,1) {mustBeNumeric, mustBeFinite, mustBePositive}
    f0 (1,1) {mustBeNumeric, mustBeFinite, mustBePositive}
    f1 (1,1) {mustBeNumeric, mustBeFinite, mustBePositive}
    amplitude (1,1) {mustBeNumeric, mustBeFinite, mustBeNonnegative}
    options.Phase (1,1) {mustBeNumeric, mustBeFinite} = 0
end

[x, N] = roadprofile.internal.sampleGrid(L, dx, 2);
fNyq = 1 / (2 * dx);
if max(f0, f1) >= fNyq
    error('roadprofile:invalidFrequency', ...
        'Chirp frequencies [%g, %g] must be below Nyquist %g (dx = %g m)', ...
        f0, f1, fNyq, dx);
end
phaseCycles = f0 * x + (f1 - f0) * x.^2 / (2 * L);
z = amplitude * sin(2 * pi * phaseCycles + options.Phase);

p.x = x;
p.z = z;
p.dx = dx;
end