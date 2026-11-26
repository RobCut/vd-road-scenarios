%PSD_COMPARISON Welch estimate of a generated profile vs ISO 8608.

%clear; 
clc; close all;

outDir = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'results');
if ~exist(outDir, 'dir'), mkdir(outDir); end

L = 10000; dx = 0.05; Ls = 200;          % road and segment length [m]
p = roadprofile.iso8608Profile(L, dx, 'B', Seed=1);

M = round(Ls/dx);  w = 0.5 - 0.5*cos(2*pi*(0:M-1)'/M);   % Hann
starts = 1:M/2:numel(p.z)-M+1;
P = zeros(M, 1);
for i = starts
    s = p.z(i:i+M-1);
    P = P + abs(fft((s - mean(s)).*w)).^2;
end
P = 2 * P * dx / (numel(starts) * sum(w.^2));            % one-sided [m^3]
n = (0:M-1)' / (M*dx);

band = n >= 0.03 & n <= 2.5;
G = roadprofile.iso8608PSD('B', n(band));
ratio = P(band) ./ G;
fprintf('Estimate/theory: mean %.3f, min %.3f, max %.3f\n', ...
    mean(ratio), min(ratio), max(ratio));

fig = figure('Color', 'w', 'Position', [100 100 900 700]);
tiledlayout(2, 1);
nexttile;
loglog(n(band), G, 'k', n(band), P(band), '.');
grid on; ylabel('G_d(n) [m^3]');
legend('ISO 8608 class B', sprintf('Welch, %d segments', numel(starts)));
nexttile;
semilogx(n(band), ratio); grid on;
xlabel('n [cycles/m]'); ylabel('estimate / theory'); ylim([0.7 1.3]);
exportgraphics(fig, fullfile(outDir, 'psd_comparison.png'), 'Resolution', 150);