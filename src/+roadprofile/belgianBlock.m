function p = belgianBlock(L, dx, rmsHeight, wavelength, options)
%BELGIANBLOCK Belgian block paving (narrow-band stochastic surface).
%   P = BELGIANBLOCK(L, DX, RMS, LAMBDA) returns a stochastic roughness
%   with RMS height (m) and dominant wavelength LAMBDA (m). The
%   PSD is a Gaussian centered at 1/LAMBDA with relative bandwidth 0.30,
%   as an illustrative model of Belgian block paving
%   (blocks of order 0.10-0.30 m).
%
%   P = BELGIANBLOCK(..., Seed=S) uses the integer seed S for
%   deterministic generation.
%
%   See also roadprofile.cobblestone, roadprofile.washboard.

arguments
    L (1,1) {mustBeNumeric, mustBeFinite, mustBePositive}
    dx (1,1) {mustBeNumeric, mustBeFinite, mustBePositive}
    rmsHeight (1,1) {mustBeNumeric, mustBeFinite, mustBeNonnegative}
    wavelength (1,1) {mustBeNumeric, mustBeFinite, mustBePositive}
    options.Seed {mustBeNumeric, mustBeInteger, mustBeNonnegative, mustBeScalarOrEmpty} = []
end

p = roadprofile.internal.narrowBand( ...
    L, dx, rmsHeight, wavelength, 0.30, options.Seed, 'belgianBlock');
end