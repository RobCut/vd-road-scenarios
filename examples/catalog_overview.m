%CATALOG_OVERVIEW Plot every pattern in the catalog on a common grid.
%   Produces results/catalog_overview.png, the main figure for the README.

clear; clc; close all;

L = 20; dx = 0.01;

patterns = {
    'sine',           @() roadprofile.sine(L, dx, 2.0, 0.02)
    'iso8608 class B', @() roadprofile.iso8608Profile(L, dx, 'B', Seed=1)
    'washboard',      @() roadprofile.washboard(L, dx, 0.02, 0.5)
    'belgianBlock',   @() roadprofile.belgianBlock(L, dx, 0.03, 0.2, Seed=1)
    'cobblestone',    @() roadprofile.cobblestone(L, dx, 0.02, 0.1, Seed=1)
    'bump',           @() roadprofile.bump(L, dx, 0.10, 0.6, 10)
    'pothole',        @() roadprofile.pothole(L, dx, 0.05, 0.6, 10)
    'crest',          @() roadprofile.crest(L, dx, 0.05, 0.6, 10)
    'valley',         @() roadprofile.valley(L, dx, 0.05, 0.6, 10)
    'edge',           @() roadprofile.edge(L, dx, 0.05, 8, 12)
    'step',           @() roadprofile.step(L, dx, 0.05, 10)
    'kink',           @() roadprofile.kink(L, dx, 10, 0.01, -0.01)
    'chirp',          @() roadprofile.chirp(L, dx, 0.5, 5.0, 0.01)
    'multiSine',      @() roadprofile.multiSine(L, dx, [1, 2.5, 4], [0.01, 0.005, 0.002])
    'flat',           @() roadprofile.flat(L, dx)
    };

n = size(patterns, 1);
nCols = 3;
nRows = ceil(n / nCols);

fig = figure('Color', 'w', 'Position', [100 100 1400 1000]);
for k = 1:n
    subplot(nRows, nCols, k);
    p = patterns{k, 2}();
    plot(p.x, p.z, 'LineWidth', 1);
    grid on;
    title(patterns{k, 1}, 'Interpreter', 'none');
    ylabel('z [m]');
    if k > (nRows - 1) * nCols
        xlabel('x [m]');
    end
    ylim([-0.12, 0.12]);
end

here = fileparts(mfilename('fullpath'));
repoRoot = fileparts(here);
outDir = fullfile(repoRoot, 'results');
if ~exist(outDir, 'dir'), mkdir(outDir); end
exportgraphics(fig, fullfile(outDir, 'catalog_overview.png'), 'Resolution', 150);
fprintf('Saved %s\n', fullfile(outDir, 'catalog_overview.png'));