function p = bump(L, dx, amplitude, width, position)
%BUMP Isolated bump (half-versine) road profile.
%   P = BUMO(L, DX, AMP, W, X0) returns a struct P with fields x, z, dx,
%   containing a single isolated bump of amplitude AMP (m) and width W (m),
%   starting at position X0 (m) on a road of length L (m) sampled at DX
%   (m). The bump has a half/versine shape:
%
%       z(x) = AMP/2 * (1 - cos(2*pi*(x-x0)/W)) for X0 <= x <= X0+W
%       z(x) = 0                                elsewhere
%
%   The shape is C1 continuous at the edges (no jumps on value or slope),
%   which is physically appropriate for a smooth bump. The bump can extend
%   beyond the road; in that case it is truncated.
%
%   For depressions (potholes), use roadprofile.pothole, which calls this
%   funztion with a negative amplitude.
%
%   See also roadprofile.pothole, roadprfile.sine.

arguments
    L (1,1) {mustBeNumeric, mustBeFinite, mustBePositive}
    dx (1,1) {mustBeNumeric, mustBeFinite, mustBePositive}
    amplitude (1,1) {mustBeNumeric, mustBeFinite, mustBeNonnegative}
    width (1,1) {mustBeNumeric, mustBeFinite, mustBePositive}
    position (1,1) {mustBeNumeric, mustBeFinite}
end

N = round(L / dx);
if N < 2
    error('roadprofile:invalidLength', ...
        'Profile requires at least 2 samples, got %d', N);
end
x = (0:N-1)' * dx;
z = zeros(N, 1);
inWindow = x > position & x <= position + width;
if any(inWindow)
    xi = x(inWindow);
    z(inWindow) = (amplitude / 2) * (1 - cos(2 * pi * (xi - position) / width));
end

p.x = x;
p.z = z;
p.dx = dx;
end