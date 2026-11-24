function p = edge(L, dx, height, startPos, stopPos)
%EDGE Rectangular plateau (C0, not C1).
%   P = EDGE(L, DX, H, S, E) returns a profile that is 0 outside [S, E) and
%   H inside. The two boundaries are true steps (discontinuous slope). This
%   is a robustness pattern: real roads do not have perfect plateaus.
%
%   See also roadprofile.step, roadprofile.flat.

arguments
    L (1,1) {mustBeNumeric, mustBeFinite, mustBePositive}
    dx (1,1) {mustBeNumeric, mustBeFinite, mustBePositive}
    height (1,1) {mustBeNumeric, mustBeFinite}
    startPos (1,1) {mustBeNumeric, mustBeFinite}
    stopPos (1,1) {mustBeNumeric, mustBeFinite}
end

N = round(L / dx);
if N < 2
    error('roadprofile:invalidLength', ...
        'Profile requires at least 2 samples, got %d', N);
end
if startPos < 0 || stopPos > (N-1)*dx || startPos >= stopPos
    error('roadprofile:invalidSegment', ...
        'edge window [%g, %g] invalid for road [0, %g]', ...
        startPos, stopPos, (N-1)*dx);
end
x = (0:N-1)' * dx;
z = height * (x >= startPos & x < stopPos);

p.x = x;
p.z = z;
p.dx = dx;
end