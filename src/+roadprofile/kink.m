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

N = round(L / dx);
if N < 2
    error('roadprofile:invalidLength', ...
        'Profile requires at least 2 samples, got %d', N);
end
x = (0:N-1)' * dx;
z = zeros(N, 1);
before = x < position;
z(before) = slopeBefore * x(before);
z(~before) = slopeBefore * position + slopeAfter * (x(~before) - position);

p.x = x;
p.z = z;
p.dx = dx;
end