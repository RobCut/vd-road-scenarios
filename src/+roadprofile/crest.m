function p = crest(L, dx, height, width, position)
%CREST Triangular peak (C0, not C1).
%   P = CREST(L, DX, H, W, X0) returns a triangular peak that is 0 outside
%   [X0, X0+W], rises linearly to H at X0 + W/2, and descends
%   symmetrically. Unlike bump, the slope is discontinuous at the peak.
%   H must be non-negative (use valley for depressions); W >= 4*DX.
%
%   See also roadprofile.valley, roadprofile.bump.

arguments
    L (1,1) {mustBeNumeric, mustBeFinite, mustBePositive}
    dx (1,1) {mustBeNumeric, mustBeFinite, mustBePositive}
    height (1,1) {mustBeNumeric, mustBeFinite, mustBeNonnegative}
    width (1,1) {mustBeNumeric, mustBeFinite, mustBePositive}
    position (1,1) {mustBeNumeric, mustBeFinite}
end

[x, N] = roadprofile.internal.sampleGrid(L, dx, 2);
if width < 4 * dx
    error('roadprofile:invalidWidth', ...
        'Crest width %g m is less than 2*dx = %g m', width, 2*dx);
end
xEnd = (N-1)*dx;
if position + width <= 0 || position >= xEnd
    error('roadprofile:invalidPosition', ...
        'Crest window [%g, %g] does not overlap road [0, %g]', ...
        position, position + width, xEnd);
end
z = zeros(N, 1);
inWindow = x > position & x < position + width;
xi = x(inWindow);
mid = position + width/2;
z(inWindow) = height * (1 - abs((xi - mid) / (width/2)));

p.x = x;
p.z = z;
p.dx = dx;
end