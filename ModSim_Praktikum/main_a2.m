% MODSIM Laborpraktikum, 2. Aufgabe Schrittweitensteuerung
% Prof. K. Janschek, Dr.-Ing. Th. Range, Dr.-Ing. E. Dueblenk
%
% edit: Gruppe 2: Johanna Krüger, Arne Noack, Viktor Strichow; Louise Perrin

clear all % Lösche Arbeitsspeicher

Tm = 10; % Konstante des PT1, s

h = 0.1; % Schrittweite, s 
h_max = 20;
h_min = 60*10^(-6);
t0 = 0; % Integrationsbeginn, s
tf = 300; % Integrationsende, s

t = []; % Zeitwerte für Plot, s
d = []; % Fehler-Schätzwerte
u = []; % Stellwerte u(t)
y = []; % Ausgangswerte y(t)
ys = []; % Soll-Ausgangswerte y_soll(t)
h_v = []; % Schrittweitenwerte für Verifikation / Plot

% Initialisierung
[dum,x(1)] = system_pt1([],[],[],0);
d(1) = 0;

% Integration nach VPG-Methode
ti = t0;
i = 1;

while ti <= tf
    % Berechnung des Soll-Ausgangswertes
    if ti < 1
        ys(i) = 0;
    elseif ti >= 1
        ys(i) = 5 * (1 - exp(-1/Tm * (ti-1)));
    end

    % Berechnung des Stellwertes
    if ti < 1
        u(i) = 0;
    elseif ti >= 1
        u(i) = 5;
    end

    if ti + h/2 < 1
        u_h2 = 0;
    else
        u_h2 = 5;
    end

    if ti + h < 1
        u_h = 0;
    else
        u_h = 5;
    end
 

    % Berechnung des Ausgangswertes
    y(i) = system_pt1( ti , x(i) , u(i) , 3); %die Parameter einsetzen

    % Berechnung der Koeffizienten für VPG-Methode
    k1 = system_pt1( ti , x(i) , u(i) , 1); %die Parameter einsetzen
    k2 = system_pt1( ti + h/2, x(i) + h/2 * k1, u_h2 , 1); %die Parameter einsetzen
    k3 = system_pt1( ti + h , x(i) - h*k1 + 2*h*k2 , u_h , 1); %die Parameter einsetzen

    % Wichtiger Hinweis: Die Parameter bei den Aufrufen von system_pt1(...) müssen unter Beachtung von jeweiligen Zeitpunkten bestimmt werden!
    
    % Berechnung des Zustands-Schätzwertes x(ti+h)
    x(i+1) = x(i) + h*k2;
    % Berechnung der LDF Fehlerabschätzung d(ti+h)
    d(i+1) = h/6*(k1-2*k2+k3); 
    t(i) = ti; % Zeitwert für Plot speichern
    
    %Berechnung des Verlaufs der Schrittweite
    h_v(i) = h;

    %Schrittweitensteuerung
    
    d_dach = max(abs(d(i+1)));
    h_neu = h*(5*10^(-6)/d_dach)^(1/3);
    %ERKLÄRUNG: h wird an der Sprungstelle klein, was nur dadurch erklärt
    %werden kann, dass d an der Stelle groß wird, was durch die Schätzung
    %nicht sichtbar ist.
    %Algorithmus 
    if h_neu > 2*h && h_neu < h_max
        ti = ti + h; % Zeitvariable um einen Schritt erhöhen
        h = h_neu;
        i = i + 1; % Index inkrementieren
    elseif h_neu <= h && h_neu > h_min
        h = 0.75*h_neu;
    else
        ti = ti + h; % Zeitvariable um einen Schritt erhöhen
        i = i + 1; % Index inkrementieren
    end
    
end

d = d(1:end-1);
result = [t;d];

% Anzeige der Ergebnisse

figure(1);
subplot(2,1,1); plot(t,u); title('Eingang PT1-Glied');zoom on;grid on;
subplot(2,1,2); plot(t,y); title('Ausgang PT1-Glied');zoom on;grid on;
xlabel('Zeit, s');

figure(2);
subplot(2,1,1); plot(t,y-ys,'.-'); title('GDF berechnet');zoom on;grid on;
tit=sprintf('LDF geschätzt: max. Betrag = %g',max(abs(d)));
subplot(2,1,2); plot(t,d,'.-'); title(tit);zoom on;grid on;
xlabel('Zeit, s');

figure(3);
subplot(2,1,1); plot(t,h_v); title('Schrittweite h');zoom on;grid on;
xlabel('Zeit, s');