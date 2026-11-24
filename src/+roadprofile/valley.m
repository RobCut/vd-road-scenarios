function p = valley(L, dx, depth, width, position)
%VALLEY Triangular depression (C0, not C1).
%   P = VALLEY(L, DX, D, W, X0) is the negation of crest(L, DX, D, W, X0).
%   D must be non-negative; the sign is captured by the function name.
%
%   See also roadprofile.crest.

arguments
    L (1,1) {mustBeNumeric, mustBeFinite, mustBePositive}
    dx (1,1) {mustBeNumeric, mustBeFinite, mustBePositive}
    depth (1,1) {mustBeNumeric, mustBeFinite, mustBeNonnegative}
    width (1,1) {mustBeNumeric, mustBeFinite, mustBePositive}
    position (1,1) {mustBeNumeric, mustBeFinite}
end

p = roadprofile.crest(L, dx, depth, width, position);

p.z = -p.z;
end