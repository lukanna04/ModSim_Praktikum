% MODSIM Laborpraktikum, 3. Aufgabe Schrittweitensteuerung
% Prof. K. Janschek, Dr.-Ing. Th. Range, Dr.-Ing. E. Dueblenk
%
% edit: Gruppe 2: Johanna Krüger, Arne Noack, Viktor Strichow, Louise Perrin
%
% Systemtopologie
%
% Zustand x:
% x(1) = Zustand des PT1-Gliedes
%
% Eingang u:
% u(1) = u2
%
% Ausgänge bei flag = 3:
% sys(1) = e        Ausgang der Subtraktionsstelle
% sys(2) = y_h      Ausgang der Hysterese / Systemausgang y
% sys(3) = y_m      Ausgang des PT1-Gliedes

function [sys, x0] = sys_top(t, x, u, flag)

if flag == 0
    % Initialisierung der Module

    [~, x0_pt1] = system_pt1([], [], [], 0);
    system_hys([], [], [], 0);
    system_sub([], [], [], 0);

    x0 = x0_pt1;

    % Ein Zustand, ein Eingang, drei Ausgänge
    sys = [1, 0, 1, 3, 0, 0];

elseif abs(flag) == 1
    % Berechnung der Zustandsableitung

    u2 = u(1);

    % Ausgang PT1-Glied = Rückführgröße
    y_m = system_pt1(t, x, [], 3);

    % Subtraktionsstelle
    e = system_sub(t, [], [u2; y_m], 3);

    % Hysterese
    y_h = system_hys(t, [], e, 3);

    % PT1-Glied wird mit Ausgang der Hysterese gespeist
    sys = system_pt1(t, x, y_h, 1);

elseif flag == 3
    % Berechnung aller Blockausgänge

    u2 = u(1);

    % Ausgang PT1-Glied
    y_m = system_pt1(t, x, [], 3);

    % Ausgang Subtraktionsstelle
    e = system_sub(t, [], [u2; y_m], 3);

    % Ausgang Hysterese / Systemausgang
    y_h = system_hys(t, [], e, 3);

    % Alle Blockausgänge zurückgeben
    sys = [e; y_h; y_m];

elseif flag == 4
    % Hysterese-Gedächtnis sichern
    system_hys([], [], [], 4);
    sys = [];

elseif flag == 5
    % Hysterese-Gedächtnis wiederherstellen
    system_hys([], [], [], 5);
    sys = [];

elseif flag == 6
    % Hysterese zurücksetzen
    system_hys([], [], [], 6);
    sys = [];

else
    sys = [];

end