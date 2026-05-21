% MODSIM Laborpraktikum, 3. Aufgabe Schrittweitensteuerung
% Prof. K. Janschek, Dr.-Ing. Th. Range, Dr.-Ing. E. Dueblenk
%
% edit: Gruppe 2: Johanna Krüger, Arne Noack, Viktor Strichow, Louise Perrin

clear all % Lösche Arbeitsspeicher

Tm = 10; % Konstante des PT1, s

h = 0.1; % Schrittweite, s 
h_max = 1.567;
h_min = 12*10^(-6);
e_LDF = 1 * 10^(-6);
t0 = 0; % Integrationsbeginn, s
tf = 20; % Integrationsende, s

t = []; % Zeitwerte für Plot, s
d = []; % Fehler-Schätzwerte
u = []; % Stellwerte u(t)
y = []; % Ausgangswerte y(t)
ys = []; % Soll-Ausgangswerte y_soll(t)
h_v = []; % Schrittweitenwerte für Verifikation / Plot
e_v = [];
ym_v = [];

global h_e h_a
global hys_akt hys_save

h_e = 0.085;
h_a = 0.065;

u2_werte = [0.17, -0.25, 0.45];
% u2 = -0.25;

for exp = 1:length(u2_werte)

    u2 = u2_werte(exp);

    % Initialisierung
    [dum,x(1)] = sys_top([],[],[],0);
    d(1) = 0;
    
    % Integration nach VPG-Methode
    ti = t0;
    i = 1;

    % Hysterese zurücksetzen
    sys_top([], [], [], 6);
    
    while ti <= tf
    
        % Anfangswert holen
        %[~, x0] = sys_top([], [], [], 0);
        %x = x0;
    
        % Blockausgänge
        speicher = sys_top( ti , x(i) , u2 , 3);
        e = speicher(1);
        y_s = speicher(2);
        y_m = speicher(3);
    
        % Plot Größen
        e_v(i) = e;
        ym_v(i) = y_m;
        y(i) = y_s; % oder y_v(i)
        t(i) = ti;
        h_v(i) = h;
    
        % Zustand sichern
        sys_top([], [], [], 4);
    
        % Berechnung der Koeffizienten für VPG-Methode
        k1 = sys_top( ti , x(i) , u2 , 1); %die Parameter einsetzen
        k2 = sys_top( ti + h/2, x(i) + h/2 * k1, u2 , 1); %die Parameter einsetzen
        k3 = sys_top( ti + h , x(i) - h*k1 + 2*h*k2 , u2 , 1); %die Parameter einsetzen
    
        % Wichtiger Hinweis: Die Parameter bei den Aufrufen von system_pt1(...) müssen unter Beachtung von jeweiligen Zeitpunkten bestimmt werden!
        
        % Berechnung des Zustands-Schätzwertes x(ti+h)
        x(i+1) = x(i) + h*k2;
        % Berechnung der LDF Fehlerabschätzung d(ti+h)
        d(i+1) = h/6*(k1-2*k2+k3); 
        
    
        %Schrittweitensteuerung
        
        d_dach = max(abs(d(i+1)));
        h_neu = h*(e_LDF/d_dach)^(1/3);
        %ERKLÄRUNG: h wird an der Sprungstelle klein, was nur dadurch erklärt
        %werden kann, dass d an der Stelle groß wird, was durch die Schätzung
        %nicht sichtbar ist.
        %Algorithmus 
        if h_neu > 2*h && h_neu < h_max
            ti = ti + h; % Zeitvariable um einen Schritt erhöhen
            h = h_neu;
            i = i + 1; % Index inkrementieren
        elseif h_neu <= h && h_neu > h_min
            sys_top([],[],[],5);
            h = 0.75*h_neu;
        else
            ti = ti + h; % Zeitvariable um einen Schritt erhöhen
            i = i + 1; % Index inkrementieren
        end
        
    end
    
    d = d(1:end-1);
    result = [t;d];
    
    % Anzeige der Ergebnisse
    
    figure('Name', sprintf('Experiment %d, u2 = %+g', exp, u2));
    % subplot(2,1,1); plot(t,u2); title('Eingang');zoom on;grid on;
    subplot(2,1,1); plot(t,y); title('Hysterese');zoom on;grid on;
    subplot(2,1,2); plot(t,e_v); title('Ausgang Subtraktionsstelle');zoom on;grid on;

    xlabel('Zeit, s');
    
    figure('Name', sprintf('Experiment %d, u2 = %+g', exp, u2));
    subplot(2,1,1); plot(t,ym_v,'.-'); title('Ausgang PT1');zoom on;grid on;
    tit=sprintf('LDF geschätzt: max. Betrag = %g',max(abs(d)));
    subplot(2,1,2); plot(t,d,'.-'); title(tit);zoom on;grid on;
    xlabel('Zeit, s');
    
    figure('Name', sprintf('Experiment %d, u2 = %+g', exp, u2));
    subplot(2,1,1); plot(t,h_v); title('Schrittweite h');zoom on;grid on;
    xlabel('Zeit, s');

    tau_e = -Tm * log(1 - (h_e - h_a) / (1 + h_e - abs(u2)));

    tau_P = Tm * ( log((1 - (h_a / abs(u2))) / (1 - (h_e / abs(u2)))) - log(1 - (h_e - h_a) / (1 + h_e - abs(u2))));

    fprintf('exp: %i \n', exp);
    fprintf('tau_e = %.6f s\n', tau_e);
    fprintf('tau_P = %.6f s\n', tau_P);
   
end 