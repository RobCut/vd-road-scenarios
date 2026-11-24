function p = flat(L, dx, height)
%FLAT Constant-height road profile.
%   P = FLAT(L, DX) returns a struct P with fields x, z, dx, containing
%   a flat road profile of length L (m) sampled at DX (m). z is
%   identically zero.
%
%   P = FLAT(L, DX, H) returns a profile with constant elevation H (m)
%   over the entire length. H can be positive (raised surface) or
%   negative (trench). The default is 0.
%
%   FLAT(L, DX) is the standard gap filler in a composed scenario.
%   FLAT(L, DX, H) with H ~= 0 produces a discontinuity at the
%   boundaries if adjacent segments are at different elevations. This
%   is a deliberate property of the pattern: flat does not smooth
%   transitions. If a composition needs continuity at a boundary, the
%   user is responsible for matching elevations (or accepting the
%   discontinuity as a test input).
%
%   See also roadprofile.compose, roadprofile.bump.

arguments
    L (1,1) {mustBeNumeric, mustBeFinite, mustBePositive}
    dx (1,1) {mustBeNumeric, mustBeFinite, mustBePositive}
    height (1,1) {mustBeNumeric, mustBeFinite} = 0
end

N = round(L / dx);
if N < 2
    error('roadprofile:invalidLength', ...
        'Profile requires at least 2 samples, got %d', N);
end
x = (0:N-1)' * dx;
z = height * ones(N, 1);

p.x = x;
p.z = z;
p.dx = dx;
end