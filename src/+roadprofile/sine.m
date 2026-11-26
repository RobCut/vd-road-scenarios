function p = sine(L, dx, freq, amplitude, options)
%SINE Spatial sinusoidal road profile.
%   P = SINE(L, DX, FREQ, AMP) returns a struct P with fields x, z, dx,
%   containing a sinusoidal road profile of length L (in metres) sampled
%   at spatial resolution DX (in metres), with spatial frequency FREQ
%   (in cycles/m) and amplitude AMP (in metres):
%
%       z(x) = AMP * sin(2*pi*FREQ*x + PHASE)
%
%   P = SINE(..., Phase=PH) sets the phase PH in radians (default 0).
%
%   FREQ must be strictly less than the Nyquist frequency 1/(2*DX),
%   otherwise the sinusoid aliases silently. FREQ at or above Nyquist
%   raises roadprofile:invalidFrequency.
%
%   Unlike roadprofile.iso8608Profile, the sinusoidal profile is NOT
%   mean-centered: its mean is zero only when the number of periods in
%   the profile is an integer.
%
%   See also roadprofile.iso8608Profile, roadprofile.bump.

arguments
    L (1,1) {mustBeNumeric, mustBeFinite, mustBePositive}
    dx (1,1) {mustBeNumeric, mustBeFinite, mustBePositive}
    freq (1,1) {mustBeNumeric, mustBeFinite, mustBePositive}
    amplitude (1,1) {mustBeNumeric, mustBeFinite, mustBeNonnegative}
    options.Phase (1,1) {mustBeNumeric ,mustBeFinite} = 0
end

[x, N] = roadprofile.internal.sampleGrid(L, dx, 2);
fNyq = 1 / (2 * dx);
if freq >= fNyq
    error('roadprofile:invalidFrequency', ...
        'Frequency %g cycles/m exceeds or equals Nyquist %g cycles/m (dx = %g m)', ...
        freq, fNyq, dx);
end
z = amplitude * sin(2 * pi * freq * x + options.Phase);

p.x = x;
p.z = z;
p.dx = dx;
end