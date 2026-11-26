function p = edge(L, dx, height, startPos, stopPos)
%EDGE Rectangular plateau (C0, not C1).
%   P = EDGE(L, DX, H, S, E) returns a profile that is 0 outside [S, E) and
%   H inside. The two boundaries are true steps (discontinuous slope). This
%   is a robustness pattern: real roads do not have perfect plateaus.
%   Requires 0 <= S < E <= N*DX and at least one sample in [S, E).
%
%   See also roadprofile.step, roadprofile.flat.

arguments
    L (1,1) {mustBeNumeric, mustBeFinite, mustBePositive}
    dx (1,1) {mustBeNumeric, mustBeFinite, mustBePositive}
    height (1,1) {mustBeNumeric, mustBeFinite}
    startPos (1,1) {mustBeNumeric, mustBeFinite}
    stopPos (1,1) {mustBeNumeric, mustBeFinite}
end

[x, N] = roadprofile.internal.sampleGrid(L, dx, 2);
Leff = N * dx;
if startPos < 0 || stopPos > Leff + 1e-9*dx || startPos >= stopPos
    error('roadprofile:invalidPosition', ...
        'edge window [%g, %g) invalid for road [0, %g]', ...
        startPos, stopPos, Leff);
end
inside = x >= startPos & x < stopPos;
if ~any(inside)
    error('roadprofile:invalidPosition', ...
        'edge window [%g, %g) contains no sample (dx = %g)', ...
        startPos, stopPos, dx);
end
z = height * inside;

p.x = x;
p.z = z;
p.dx = dx;
end