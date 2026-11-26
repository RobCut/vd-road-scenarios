function p = step(L, dx, height, position, options)
%STEP Step transition with optional smoothing width.
%   P = STEP(L, DX, H, X0) returns a profile that is 0 for x < X0 and H for
%   x >= X0. The transition is sharp (one sample) by default.
%
%   P = STEP(L, DX, H, X0, Width=W) replaces the sharp step with a smooth
%   sigmoid transition of approximate width W (m). With W > 0 the
%   transition spans roughly [X0 - W/2, X0 + W/2].
%
%   This pattern is intended for robustness testing. Real roads do not have
%   perfect steps; for physical scenarios use edge, bump or flat.
%
%   See also roadprofile.edge, roadprofile.flat.

arguments
    L (1,1) {mustBeNumeric, mustBeFinite, mustBePositive}
    dx (1,1) {mustBeNumeric, mustBeFinite, mustBePositive}
    height (1,1) {mustBeNumeric, mustBeFinite}
    position (1,1) {mustBeNumeric, mustBeFinite}
    options.Width (1,1) {mustBeNumeric, mustBeFinite, mustBeNonnegative} = 0
end

[x, N] = roadprofile.internal.sampleGrid(L, dx, 2);
if options.Width == 0
    z = height * (x >= position);
else
    w = options.Width;
    z = height ./ (1 + exp(-(x - position) / (w/8)));
end

p.x = x;
p.z = z;
p.dx = dx;
end