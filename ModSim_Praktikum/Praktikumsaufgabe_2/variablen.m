clear; clc;

% Leistungsstufe
K_L = 1;
i_vmax = 1;

% Servoventil
K_sv = 0.796;
Ksv  = K_sv;      % Alias

F_N = 63000;
FN  = F_N;        % Alias

% Prüfzylinder
b1  = 2.39e6;

c_o  = 36.5e6;
c_oe = c_o;       % Alias

% Massen
m_k = 8.7;
mk  = m_k;        % Alias

m_p = 260;
mp  = m_p;        % Alias

m_g = m_k + m_p;
mg  = m_g;        % Alias

% Prüfling
c_p = 75e6;
cp  = c_p;        % Alias

% Parameter der linearen Übertragungsfunktion
fprintf('Berechnete Werte \n');
K_F = K_L * K_sv * b1;
fprintf('K_F = %g\n', K_F);

a1 = b1/c_p + b1/c_o;
fprintf('a1 = %g\n', a1);

a2 = m_g/c_p;
fprintf('a2 = %g\n', a2);

a3 = m_g*b1/(c_p*c_o);
fprintf('a3 = %g\n', a3);

fprintf('\n');

fprintf('Normierte Werte \n');

K_F_nom = K_F / a3; % Normierung, sodass a3 = 1 ist, wie in MATLAB-Ausgabe
fprintf('K_F_nom = %g\n', K_F_nom);

a0_nom = 1/a3;
fprintf('a0_nom = %g\n', a0_nom);

a1_nom = a1/a3;
fprintf('a1_nom = %g\n', a1_nom);

a2_nom = a2/a3;
fprintf('a2_nom = %g\n', a2_nom);

a3_nom = a3/a3;
fprintf('a3_nom = %g\n', a3_nom);

% Verifikation
modell = 'Signalflussplan';
load_system(modell);

% Arbeitspunkt x = [0; 0], u = 0
x0 = [0; 0; 0];
u0 = 0;

[A, B, C, D] = linmod(modell, x0, u0);

[b, a] = ss2tf(A, B, C, D);

fprintf('\n');

fprintf('Simulierte Werte \n');

fprintf('b = %s\n', mat2str(b, 6));
fprintf('a = %s\n', mat2str(a, 6));

fprintf('\n');

fprintf('Simulierte Parameter \n');

fprintf('K_F = %g\n', b(4));
fprintf('a3 = %g\n', a(1));
fprintf('a2 = %g\n', a(2));
fprintf('a1 = %g\n', a(3));
fprintf('a0 = %g\n', a(4));