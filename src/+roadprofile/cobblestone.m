function p = cobblestone(L, dx, rmsHeight, wavelength, options)
%COBBLESTONE Cobblestone paving (narrow-band stochastic surface).
%   P = COBBLESTONE(L, DX, RMS, LAMBDA) returns a stochastic roughness
%   with RMS height (m) and dominant wavelength LAMBDA (m). The
%   PSD is a Gaussian centered at 1/LAMBDA with relative bandwidth 0.15,
%   narrower than belgianBlock, narrower than belgianBlock, as an illustrative model of cobblestone paving
%   (of order 0.05-0.15 m).
%
%   P = COBBLESTONE(..., Seed=S) uses the integer seed S for
%   deterministic generation.
%
%   See also roadprofile.belgianBlock, roadprofile.washboard.

arguments
    L (1,1) {mustBeNumeric, mustBeFinite, mustBePositive}
    dx (1,1) {mustBeNumeric, mustBeFinite, mustBePositive}
    rmsHeight (1,1) {mustBeNumeric, mustBeFinite, mustBePositive}
    wavelength (1,1) {mustBeNumeric, mustBeFinite, mustBePositive}
    options.Seed {mustBeNumeric, mustBeInteger, mustBeNonnegative, mustBeScalarOrEmpty} = []
end

p = roadprofile.internal.narrowBand( ...
    L, dx, rmsHeight, wavelength, 0.15, options.Seed, 'cobblestone');
end