function [x, N] = sampleGrid(L, dx, minN)
%SAMPLEGRID Common spatial grid: N = round(L/dx), x = (0:N-1)'*dx.
N = round(L / dx);
if N < minN
    error('roadprofile:invalidLength', ...
        'Profile requires at least %d samples, got %d', minN, N);
end
x = (0:N-1)' * dx;
end