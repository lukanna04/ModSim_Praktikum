% MODSIM Laborpraktikum
%
% system_sub.m
% Modul: Subtraktionsstelle
%
% Berechnet:
% e = u2 - y_m
%
% Eingang u:
% u(1) = u2     konstante Eingangsgröße
% u(2) = y_m    Rückführsignal vom PT1-Glied
%
% Ausgang:
% sys = e

function [sys, x0] = system_sub(t, x, u, flag)

if flag == 0
    % Keine Zustände
    x0 = [];
    sys = [0, 0, 2, 1, 0, 0];

elseif flag == 3
    % Ausgang der Subtraktionsstelle
    % e = u2 - y_m
    sys = u(1) - u(2);

else
    sys = [];

end