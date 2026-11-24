function p = smooth(L, dx)
%SMOOTH Flat (zero) road profile.
%   P = SMOOTH(L, DX) returns a struct P with fields x, z, dx, containing a
%   flat road profile of length L (m) sampled at DX (m). z is identically
%   zero. This pattern is used to represent gaps between event-based in a
%   composed scenario.
%
%   See also roadprofile.bump, roadprofile.iso8608Profile.

arguments
    L (1,1) {mustBeNumeric, mustBeFinite, mustBePositive}
    dx (1,1) {mustBeNumeric, mustBeFinite, mustBePositive}
end

N = round(L / dx);
if N < 2
    error('roadprofile:invalidLength', ...
        'Profile requires at least 2 samples, got %d', N);
end
x = (0:N-1)' * dx;
z = zeros(N, 1);

p.x = x;
p.z = z;
p.dx = dx;
end