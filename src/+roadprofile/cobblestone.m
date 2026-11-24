function p = cobblestone(L, dx, amplitude, wavelength, options)
%COBBLESTONE Cobblestone paving (narrow-band stochastic surface).
%   P = COBBLESTONE(L, DX, AMP, LAMBDA) returns a stochastic roughness
%   with RMS amplitude AMP (m) and dominant wavelength LAMBDA (m). The
%   PSD is a Gaussian centered at 1/LAMBDA with relative bandwidth 0.15,
%   narrower than belgianBlock, which reproduces the more regular
%   spectrum of rounded cobblestones (of order 0.05-0.15 m).
%
%   P = COBBLESTONE(..., Seed=S) uses the integer seed S for
%   deterministic generation.
%
%   See also roadprofile.belgianBlock, roadprofile.washboard.

arguments
    L (1,1) {mustBeNumeric, mustBeFinite, mustBePositive}
    dx (1,1) {mustBeNumeric, mustBeFinite, mustBePositive}
    amplitude (1,1) {mustBeNumeric, mustBeFinite, mustBePositive}
    wavelength (1,1) {mustBeNumeric, mustBeFinite, mustBePositive}
    options.Seed {mustBeNumeric, mustBeInteger, mustBeNonnegative, mustBeScalarOrEmpty} = []
end

p = roadprofile.internal.narrowBand( ...
    L, dx, amplitude, wavelength, 0.15, options.Seed, 'cobblestone');
end