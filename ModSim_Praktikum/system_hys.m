% MODSIM Laborpraktikum, 3. Aufgabe Schrittweitensteuerung
% Prof. K. Janschek, Dr.-Ing. Th. Range, Dr.-Ing. E. Dueblenk
%
% edit: Gruppe 2: Johanna Krüger, Arne Noack, Viktor Strichow, Louise Perrin
%
% Hysterese
%
% Schaltverhalten:
%
% Ausgang y_h = +1, wenn e >= h_a
% Ausgang y_h = -1, wenn e <= -h_e
%
% Dazwischen bleibt der vorherige Ausgangswert erhalten.
%
% Globale Variablen:
% h_e             positive Schwelle für Umschalten nach -1
% h_a             positive Schwelle für Umschalten nach +1
% hys_akt       aktueller Zustand der Hysterese
% hys_save  gespeicherter Zustand vor einem Integrationsschritt
%
% Spezielle flags:
% flag = 4   Speicher sichern
% flag = 5   Speicher wiederherstellen
% flag = 6  Hysterese zurücksetzen

function [sys, x0] = system_hys(t, x, u, flag)

global h_e h_a
global hys_akt hys_save

if flag == 0
    % Initialisierung
    x0 = [];

    if isempty(hys_akt)
        hys_akt = -1;
    end

    hys_save = hys_akt;

    % Keine Zustände, ein Eingang, ein Ausgang
    sys = [0, 0, 1, 1, 0, 0];

elseif flag == 3
    % Ausgang der Hysterese berechnen
    if isempty(hys_akt)
        hys_akt = -1;
    end

    e = u(1);

    % Hysterese-Schaltlogik
    if e >= h_e
        hys_akt = 1;

    elseif e <= -h_e
        hys_akt = -1;

    elseif e > -h_a && e < h_a
        hys_akt = 0;
    end

    sys = hys_akt;

elseif flag == 4
    % Zustand vor einem Integrationsschritt sichern
    hys_save = hys_akt;
    sys = [];

elseif flag == 5
    % Zustand nach verworfenem Integrationsschritt wiederherstellen
    hys_akt = hys_save;
    sys = [];

elseif flag == 6
    % Hysterese gezielt zurücksetzen
    hys_akt = -1;
    hys_save = hys_akt;
    sys = [];

else
    sys = [];

end