function p = pothole(L, dx, depth, width, position)
%POTHOLE Isolated pothole (negative raised-cosine) road profile.
%   P = POTHOLE(L, DX, DEPTH, W, X0) returns a struct P with fields
%   x, z, dx, containing a single isolated depression of depth DEPTH (m)
%   and base width W (m), starting at position X0 (m) on a road of
%   length L (m) sampled at DX (m). The shape is the negation of
%   roadprofile.bump with the same parameters:
%
%       z(x) = -DEPTH/2 * (1 - cos(2*pi*(x-X0)/W))  for X0 <= x <= X0+W
%       z(x) = 0                                    elsewhere
%
%   DEPTH is the peak depression (positive scalar). The shape is C1
%   continuous at the edges. The same width and overlap constraints of
%   roadprofile.bump apply: W >= 4*DX, and the window [X0, X0+W] must
%   overlap the road with non-zero length.
%
%   See also roadprofile.bump.

p = roadprofile.bump(L, dx, depth, width, position);
p.z = -p.z;
end