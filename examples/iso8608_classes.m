%ISO8608_CLASSES Classes A to D with the same seed.

%clear; 
clc; close all;

outDir = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'results');
if ~exist(outDir, 'dir'), mkdir(outDir); end

fig = figure('Color', 'w', 'Position', [100 100 1200 600]);
hold on; grid on;
for c = ["A" "B" "C" "D"]
    p = roadprofile.iso8608Profile(100, 0.05, c, Seed=1);
    plot(p.x, p.z, 'DisplayName', c);
end
xlabel('x [m]'); ylabel('z [m]'); legend('Location', 'best');
title('ISO 8608 profiles, classes A to D (same seed)');
exportgraphics(fig, fullfile(outDir, 'iso8608_classes.png'), 'Resolution', 150);