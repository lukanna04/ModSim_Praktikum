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
K_F = K_L * K_sv * b1 / c_p;

a1 = b1/c_p + b1/c_o;
a2 = m_g/c_p;
a3 = m_g*b1/(c_p*c_o);

