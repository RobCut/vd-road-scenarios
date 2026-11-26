%SCENARIO_SHOWCASE Build a realistic scenario with compose and save plots.
%   Produces two figures:
%     - results/scenario_showcase.png: full 1000 m scenario, coarse grid
%       (dx = 0.02 m) to keep the plot readable at page width
%     - results/scenario_zoom.png: fine grid (dx = 0.005 m) to
%       show the two events (bump and pothole) clearly

%clear; 
clc; close all;

here = fileparts(mfilename('fullpath'));
repoRoot = fileparts(here);
outDir = fullfile(repoRoot, 'results');
if ~exist(outDir, 'dir'), mkdir(outDir); end

L = 1000;
segs = [
    struct('Start',   0, 'Stop', 250, 'Type', "iso8608",     'Params', {{'B'}})
    struct('Start', 250, 'Stop', 400, 'Type', "belgianBlock", 'Params', {{0.008, 0.20}})
    struct('Start', 400, 'Stop', 450, 'Type', "flat",         'Params', {{}})
    struct('Start', 450, 'Stop', 450.6, 'Type', "bump",       'Params', {{0.10, 0.6, 0}})
    struct('Start', 450.6, 'Stop', 600, 'Type', "flat",       'Params', {{}})
    struct('Start', 600, 'Stop', 650, 'Type', "cobblestone",  'Params', {{0.005, 0.10}})
    struct('Start', 650, 'Stop', 650.6, 'Type', "pothole",    'Params', {{0.06, 0.6, 0}})
    struct('Start', 650.6, 'Stop', 850, 'Type', "iso8608",    'Params', {{'C'}})
    struct('Start', 850, 'Stop', 900, 'Type', "washboard",    'Params', {{0.02, 0.5}})
    struct('Start', 900, 'Stop', 1000, 'Type', "iso8608",     'Params', {{'D'}})
    ];

% --- Overview (coarse grid)
dx = 0.02;
p = roadprofile.compose(L, dx, segs, Seed=42);
fig1 = figure('Color', 'w', 'Position', [100 100 1500 450]);
plot(p.x, p.z, 'LineWidth', 0.6);
grid on;
xlabel('x [m]');
ylabel('z [m]');
title('Composed scenario (overview, dx = 0.02 m)');
exportgraphics(fig1, fullfile(outDir, 'scenario_showcase.png'), 'Resolution', 150);
fprintf('Saved %s\n', fullfile(outDir, 'scenario_showcase.png'));

% --- Zoom on the two events (fine grid)
dxZ = 0.005;
pZ = roadprofile.compose(L, dxZ, segs, Seed=42);
fig2 = figure('Color', 'w', 'Position', [100 100 1200 450]);
tiledlayout(1, 2);
windows = [449 452; 648 653];
names = ["Bump at 450 m", "Pothole at 650 m"];
for i = 1:2
    nexttile;
    plot(pZ.x, pZ.z, 'LineWidth', 1.2); grid on;
    xlim(windows(i, :)); xlabel('x [m]'); ylabel('z [m]');
    title(names(i));
end
exportgraphics(fig2, fullfile(outDir, 'scenario_zoom.png'), 'Resolution', 150);
fprintf('Saved %s\n', fullfile(outDir, 'scenario_zoom.png'));