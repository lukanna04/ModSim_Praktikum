% MODSIM Laborpraktikum
%
% main_modulator.m
%
% Simulation des modularen Systems:
% Subtraktionsstelle -> Hysterese -> PT1-Glied Rückführung
%
% VPG-Verfahren mit Schrittweitensteuerung
% und Vergleich mit VPG bei fester Schrittweite

clear all;
close all;
clc;

%% Globale Parameter der Hysterese
global h_e h_a
global hys_akt hys_save

% >>> Falls in deiner Aufgabenstellung andere Werte stehen, hier ändern!
h_e = 0.085;
h_a = 0.065;

%% Simulationsparameter

Tm = 10;                 % Zeitkonstante des PT1-Gliedes, muss zu system_pt1 passen

t0 = 0;
tf = 20;

% Startschrittweite für variable Schrittweite
h_start = 0.1;

% Grenzen der Schrittweite
h_max = 20.0;
h_min = 60*10^(-6);

% Fehlertoleranz lokaler Diskretisierungsfehler
e_LDF = 5*10^(-6);

% Feste Schrittweite für Vergleich
h_fest = 0.01;

% Eingangswerte aus der Aufgabe
u2_werte = [0.17, -0.25, 0.45];

%% Hauptschleife über alle Experimente

for exp = 1:length(u2_werte)

    u2 = u2_werte(exp);

    fprintf('\n');
    fprintf('=============================================\n');
    fprintf('Experiment %d: u2 = %+g\n', exp, u2);
    fprintf('=============================================\n');

    %% Simulation mit VPG und Schrittweitensteuerung

    result_var = sim_vpg_variabel(u2, t0, tf, h_start, h_min, h_max, e_LDF);

    %% Simulation mit VPG und fester Schrittweite

    result_fest = sim_vpg_fest(u2, t0, tf, h_fest);

    %% Theoretische Impulsbreite und Periode

    [tau_e_theo, tau_P_theo] = berechne_theorie(u2, Tm, h_e, h_a);

    %% Impulsbreite und Periode aus Simulation schätzen

    [tau_e_var, tau_P_var] = schaetze_impulse(result_var.t, result_var.y);
    [tau_e_fest, tau_P_fest] = schaetze_impulse(result_fest.t, result_fest.y);

    fprintf('\nTheorie:\n');
    fprintf('tau_e = %.6f s\n', tau_e_theo);
    fprintf('tau_P = %.6f s\n', tau_P_theo);

    fprintf('\nVPG mit Schrittweitensteuerung:\n');
    fprintf('tau_e_sim = %.6f s\n', tau_e_var);
    fprintf('tau_P_sim = %.6f s\n', tau_P_var);

    fprintf('\nVPG mit fester Schrittweite:\n');
    fprintf('tau_e_sim = %.6f s\n', tau_e_fest);
    fprintf('tau_P_sim = %.6f s\n', tau_P_fest);

    %% Plot: variable Schrittweite

    figure('Name', sprintf('Experiment %d, u2 = %+g, variable Schrittweite', exp, u2));

    subplot(5,1,1); plot(result_var.t, result_var.u2); grid on; zoom on;
    ylabel('u_2'); title(sprintf('VPG mit Schrittweitensteuerung, u_2 = %+g', u2));

    subplot(5,1,2); plot(result_var.t, result_var.e); grid on; zoom on;
    ylabel('e'); title('Ausgang Subtraktionsstelle');

    subplot(5,1,3); plot(result_var.t, result_var.y); grid on; zoom on;
    ylabel('y'); title('Ausgang Hysterese');

    subplot(5,1,4); plot(result_var.t, result_var.ym); grid on; zoom on;
    ylabel('y_m'); title('Ausgang PT1-Glied');

    subplot(5,1,5); plot(result_var.t, result_var.d, '.-'); grid on; zoom on;
    ylabel('LDF'); xlabel('Zeit t / s');
    title(sprintf('geschätzter lokaler Diskretisierungsfehler, max = %.3e', max(abs(result_var.d))));

    %% Plot: Schrittweite variable Simulation

    figure('Name', sprintf('Experiment %d, Schrittweite, u2 = %+g', exp, u2));

    plot(result_var.t, result_var.h, '.-'); grid on; zoom on;
    xlabel('Zeit t / s'); ylabel('h / s');
    title(sprintf('Schrittweitenverlauf, u_2 = %+g', u2));

    %% Plot: Vergleich variable/feste Schrittweite

    figure('Name', sprintf('Experiment %d, Vergleich, u2 = %+g', exp, u2));

    subplot(3,1,1); plot(result_var.t, result_var.y);
    hold on; plot(result_fest.t, result_fest.y, '--');
    grid on; zoom on;
    ylabel('y'); legend('variabel', 'fest');
    title(sprintf('Vergleich Hystereseausgang, u_2 = %+g', u2));

    subplot(3,1,2);plot(result_var.t, result_var.ym);
    hold on; plot(result_fest.t, result_fest.ym, '--');
    grid on; zoom on;
    ylabel('y_m'); legend('variabel', 'fest');
    title('Vergleich PT1-Ausgang');

    subplot(3,1,3); plot(result_var.t, result_var.e);
    hold on; plot(result_fest.t, result_fest.e, '--');
    grid on; zoom on;
    ylabel('e'); xlabel('Zeit t / s');
    legend('variabel', 'fest');title('Vergleich Subtraktionsstelle');

end


%% ========================================================================
% Lokale Funktionen
% ========================================================================

function result = sim_vpg_variabel(u2, t0, tf, h_start, h_min, h_max, e_LDF)

    % Hysterese zurücksetzen
    sys_top([], [], [], 6);

    % Anfangswert holen
    [~, x0] = sys_top([], [], [], 0);

    ti = t0;
    h = h_start;
    x = x0;

    i = 1;

    t_v = [];
    u2_v = [];
    e_v = [];
    y_v = [];
    ym_v = [];
    d_v = [];
    h_v = [];
    x_v = [];

    while ti <= tf

        % Sicherstellen, dass das Intervall nicht überschritten wird
        if ti + h > tf
            h = tf - ti;
        end

        if h <= 0
            break;
        end

        % Aktuelle Blockausgänge bestimmen
        block_out = sys_top(ti, x, u2, 3);

        e = block_out(1);
        y = block_out(2);
        ym = block_out(3);

        % Aktuelle Werte speichern
        t_v(i) = ti;
        u2_v(i) = u2;
        e_v(i) = e;
        y_v(i) = y;
        ym_v(i) = ym;
        h_v(i) = h;
        x_v(i) = x;

        % Zustand der Hysterese vor Integrationsversuch sichern
        sys_top([], [], [], 4);

        % VPG-Koeffizienten berechnen
        k1 = sys_top(ti,       x,                         u2, 1);
        k2 = sys_top(ti + h/2, x + h/2 * k1,              u2, 1);
        k3 = sys_top(ti + h,   x - h * k1 + 2 * h * k2,   u2, 1);

        % Zustands-Schätzwert
        x_neu = x + h * k2;

        % Geschätzter lokaler Diskretisierungsfehler
        d = h / 6 * (k1 - 2 * k2 + k3);
        d_abs = max(abs(d));

        d_v(i) = d_abs;

        % Neue Schrittweite berechnen
        if d_abs == 0
            h_neu = 2 * h;
        else
            h_neu = h * (e_LDF / d_abs)^(1/3);
        end

        % Schrittweitenbegrenzung
        h_neu = min(h_neu, h_max);
        h_neu = max(h_neu, h_min);

        % Entscheidung: Schritt akzeptieren oder wiederholen
        if d_abs <= e_LDF || h <= h_min

            % Schritt akzeptieren
            x = x_neu;
            ti = ti + h;
            i = i + 1;

            % Schrittweite nicht zu schnell erhöhen
            if h_neu > 2 * h
                h = 2 * h;
            else
                h = h_neu;
            end

        else

            % Schritt verwerfen:
            % Hysterese-Gedächtnis auf Zustand vor dem Schritt zurücksetzen
            sys_top([], [], [], 5);

            % Schrittweite reduzieren und Schritt wiederholen
            h = 0.75 * h_neu;

            if h < h_min
                h = h_min;
            end

        end

    end

    result.t = t_v;
    result.u2 = u2_v;
    result.e = e_v;
    result.y = y_v;
    result.ym = ym_v;
    result.d = d_v;
    result.h = h_v;
    result.x = x_v;

end


function result = sim_vpg_fest(u2, t0, tf, h)

    % Hysterese zurücksetzen
    sys_top([], [], [], 6);

    % Anfangswert holen
    [~, x0] = sys_top([], [], [], 0);

    ti = t0;
    x = x0;

    i = 1;

    t_v = [];
    u2_v = [];
    e_v = [];
    y_v = [];
    ym_v = [];
    d_v = [];
    h_v = [];
    x_v = [];

    while ti <= tf

        if ti + h > tf
            h = tf - ti;
        end

        if h <= 0
            break;
        end

        % Aktuelle Blockausgänge
        block_out = sys_top(ti, x, u2, 3);

        e = block_out(1);
        y = block_out(2);
        ym = block_out(3);

        t_v(i) = ti;
        u2_v(i) = u2;
        e_v(i) = e;
        y_v(i) = y;
        ym_v(i) = ym;
        h_v(i) = h;
        x_v(i) = x;

        % VPG-Koeffizienten
        k1 = sys_top(ti,       x,                         u2, 1);
        k2 = sys_top(ti + h/2, x + h/2 * k1,              u2, 1);
        k3 = sys_top(ti + h,   x - h * k1 + 2 * h * k2,   u2, 1);

        % Zustand aktualisieren
        x_neu = x + h * k2;

        % LDF-Schätzung nur zur Anzeige
        d = h / 6 * (k1 - 2 * k2 + k3);
        d_v(i) = max(abs(d));

        x = x_neu;
        ti = ti + h;
        i = i + 1;

    end

    result.t = t_v;
    result.u2 = u2_v;
    result.e = e_v;
    result.y = y_v;
    result.ym = ym_v;
    result.d = d_v;
    result.h = h_v;
    result.x = x_v;

end


function [tau_e, tau_P] = berechne_theorie(u2, Tm, h_e, h_a)

    % Herleitung:
    %
    % Während y = +1 steigt das PT1-Signal von
    % y_m = u2 - h_e
    % nach
    % y_m = u2 - h_a.
    %
    % Während y = -1 fällt das PT1-Signal von
    % y_m = u2 - h_a
    % nach
    % y_m = u2 - h_e.

    tau_e = -Tm * log(1 - (h_e - h_a) / (1 + h_e - u2));

    tau_a = -Tm * log(1 - (h_e - h_a) / (1 - h_a + u2));

    tau_P = tau_e + tau_a;

end


function [tau_e_sim, tau_P_sim] = schaetze_impulse(t, y)

    % Einschwingzeit abschneiden
    % Nur die zweite Hälfte der Simulation zur Auswertung verwenden
    t_grenze = t(1) + 0.5 * (t(end) - t(1));

    idx_bereich = find(t >= t_grenze);

    t2 = t(idx_bereich);
    y2 = y(idx_bereich);

    % Schaltflanken finden
    rising_idx = find(diff(y2) > 1);    % -1 -> +1
    falling_idx = find(diff(y2) < -1);  % +1 -> -1

    t_rise = t2(rising_idx + 1);
    t_fall = t2(falling_idx + 1);

    % Periode aus Abstand zweier steigender Flanken
    if length(t_rise) >= 2
        tau_P_sim = mean(diff(t_rise));
    else
        tau_P_sim = NaN;
    end

    % Impulsbreite: Zeit von steigender zu folgender fallender Flanke
    tau_liste = [];

    for k = 1:length(t_rise)

        idx_fall_after = find(t_fall > t_rise(k), 1, 'first');

        if ~isempty(idx_fall_after)
            tau_liste(end + 1) = t_fall(idx_fall_after) - t_rise(k);
        end

    end

    if ~isempty(tau_liste)
        tau_e_sim = mean(tau_liste);
    else
        tau_e_sim = NaN;
    end

end