function p = kink(L, dx, position, slopeBefore, slopeAfter)
%KINK Slope discontinuity (C0, not C1).
%   P = KINK(L, DX, X0, M1, M2) returns a profile that grows with slope M1
%   from x = 0 until x = X0, then continues with slope M2. The value at x =
%   0 is zero, and the profile is continuous at X0.
%
%   See also roadprofile.crest, roadprofile.valley.

arguments
    L (1,1) {mustBeNumeric, mustBeFinite, mustBePositive}
    dx (1,1) {mustBeNumeric, mustBeFinite, mustBePositive}
    position (1,1) {mustBeNumeric, mustBeFinite, mustBeNonnegative}
    slopeBefore (1,1) {mustBeNumeric, mustBeFinite}
    slopeAfter (1,1) {mustBeNumeric, mustBeFinite}
end

[x, N] = roadprofile.internal.sampleGrid(L, dx, 2);
z = zeros(N, 1);
before = x < position;
z(before) = slopeBefore * x(before);
z(~before) = slopeBefore * position + slopeAfter * (x(~before) - position);

p.x = x;
p.z = z;
p.dx = dx;
end