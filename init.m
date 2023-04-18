clear; close all; clc;

fprintf('                   -------------------------------\n\n');
%% Initialize constants, settings =========================================
settings = initSettings
fprintf('Probing data (%s)...\n', settings.fileName)
probeData(settings);



