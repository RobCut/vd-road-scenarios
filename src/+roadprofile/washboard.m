function p = washboard(L, dx, amplitude, wavelength, options)
%WASHBOARD Sinusoidal washboard surface.
%   P = WASHBOARD(L, DX, AMP, LAMBDA) returns a sinusoidal road with
%   spatial wavelength LAMBDA (m) and amplitude AMP (m). Physically
%   this models the periodic transverse corrugations found on unpaved
%   roads and on some proving ground strips.
%
%   P = WASHBOARD(..., Phase=PH) sets the phase PH in radians (default 0).
%
%   WASHBOARD is a deterministic pattern. For a stochastic narrow-band
%   surface with similar dominant wavelength, see belgianBlock and
%   cobblestone.
%
%   See also roadprofile.sine, roadprofile.belgianBlock,
%   roadprofile.cobblestone.

arguments
    L (1,1) {mustBeNumeric, mustBeFinite, mustBePositive}
    dx (1,1) {mustBeNumeric, mustBeFinite, mustBePositive}
    amplitude (1,1) {mustBeNumeric, mustBeFinite, mustBeNonnegative}
    wavelength (1,1) {mustBeNumeric, mustBeFinite, mustBePositive}
    options.Phase (1,1) {mustBeNumeric, mustBeFinite} = 0
end

p = roadprofile.sine(L, dx, 1 / wavelength, amplitude, Phase=options.Phase);
end