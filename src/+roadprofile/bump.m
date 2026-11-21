function p = bump(L, dx, amplitude, width, position)
%BUMP Isolated versine (raised-cosine) road profile.
%   P = BUMP(L, DX, AMP, W, X0) returns a struct P with fields x, z, dx,
%   containing a single isolated bump of peak height AMP (m) and base
%   width W (m), starting at position X0 (m) on a road of length L (m)
%   sampled at DX (m). The bump has a versine (raised cosine) shape:
%
%       z(x) = AMP/2 * (1 - cos(2*pi*(x-X0)/W))   for X0 <= x <= X0+W
%       z(x) = 0                                   elsewhere
%
%   AMP is the peak elevation, reached at the midpoint X0 + W/2. The
%   shape is C1 continuous at the edges (no jumps in value or slope).
%   Some road regulations use a half-sine with non-zero end slopes;
%   this implementation deliberately uses the versine for C1
%   continuity, which is more benign for numerical solvers.
%
%   The bump window must overlap the road [0, (N-1)*dx], and its width
%   must be at least 4*DX, otherwise the peak would not be resolved.
%   Violations raise roadprofile:invalidPosition (no overlap) and
%   roadprofile:invalidWidth (width < 4*DX).
%
%   For depressions (potholes), use roadprofile.pothole, which returns
%   the negation of bump with the same parameters.
%
%   See also roadprofile.pothole, roadprofile.sine.

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
xEnd = (N - 1) * dx;
if width < 4 * dx
    throw(MException('roadprofile:invalidWidth', ...
        'Bump width %g m is less than 4*dx = %g m', width, 4*dx));
end
if position + width <= 0 || position >= xEnd
    throw(MException('roadprofile:invalidPosition', ...
        'Bump window [%g, %g] does not overlap road [0, %g]', ...
        position, position + width, xEnd));
end
x = (0:N-1)' * dx;
z = zeros(N, 1);
inWindow = x > position & x <= position + width;
xi = x(inWindow);
z(inWindow) = (amplitude / 2) * (1 - cos(2 * pi * (xi - position) / width));

p.x = x;
p.z = z;
p.dx = dx;
end