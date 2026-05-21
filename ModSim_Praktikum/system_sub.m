% MODSIM Laborpraktikum
%
% system_sub.m
% Modul: Subtraktionsstelle
%
% MODSIM Laborpraktikum, 3. Aufgabe Schrittweitensteuerung
% Prof. K. Janschek, Dr.-Ing. Th. Range, Dr.-Ing. E. Dueblenk
%
% edit: Gruppe 2: Johanna Krüger, Arne Noack, Viktor Strichow, Louise Perrin
%
% Berechnet:
% e = u2 - y_m

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