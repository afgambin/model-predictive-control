function [E] = distribution_model(G, E_before_distribution_losses, ISD)

matrix_losses = G*ISD;  % wire length of each path

% Considering a normal distribution European line -> 230 V
%system_voltage = 230; % [V]
b = 2;      % lenght cable factor, b=2 for single phase wiring (230V in Europe), b=1 for three-phased wiring
rho = 0.023; % copper resistivity  (ambient temperature = 25°C) [ohm*mm²/m]
%L = 100; % wire length [m]
S = 10; % cross section [mm2]
R = b*rho*matrix_losses/S;
I = 1;  % [A]

losses = R*(I^2);   % [W]
E = E_before_distribution_losses-losses;

E(E < 0) = 0; % losses can be higher than available power

% losses_percentage = losses/system_voltage

end