function [current_action] = solver_mpc(L, E_max, E0, alpha, array_BS_HE, array_power_demand_BS, hour)

% L -> number of users
% E_max -> battery_max_level
% E0 -> battery Level array of L
% alpha -> weighting factor
% array_BS_HE -> harvested energy for L
% array_power_demand_BS -> traffic load for L
% hour -> current time slot

% debug
% L = 18;  
% E0 = randi(100,L,1); % Initial state
% E_max = 100; 
% alpha = 0.5;
% load('mpc_test')
% hour = 1;
%%%%

N = 24; % horizon
safety_th = 0.1*E_max;

% Constraints
E_min = 0; % E min
E_ref = E_max/2;
u_max_0 = E_max - E0;
u_min_0 = E_min - E0 + safety_th;

u_min_0(u_min_0 > 0) = 0;

u_max = [u_max_0 E_max*ones(L,N-1)]; % max Power
u_min = [u_min_0 -E_max*ones(L,N-1)]; % min Power

aux = array_BS_HE' - array_power_demand_BS';    % disturbance considering daily profile (from hour 1)
disturbance = [aux(:, hour:end) aux(:, 1:(hour-1))];    % disturbance starting from current time slot

% Weighting factors
a = 1;
b = 1;
c = 1;

%cvx_solver gurobi
cvx_begin

    variables u(L,N) E(L,N)
    
    minimize( alpha*sum(sum(u.^2)) + (1-alpha)*sum(sum((E - E_ref).^2)) )
    
    subject to   
    
        E(:, 1:end) == a*[E0 E(:, 1:end-1)] + b * u(:,1:end) + c * disturbance(:,1:end);

        % Energy buffer constraints:
        E_min <= E <= E_max;
        
        % Actuator limits
        u_min <= u <= u_max;
               
cvx_end

% graphs
% for i=[1 3 18]
%     figure, plot(u(i,:), '-*b')
%     hold on 
%     plot(E(i,:), '-xr')
%     xlabel('Time (hours)')
%     grid on
%     legend('Energy to trade', 'Energy buffer level')
%     axis tight;
% end

current_action = u(:,1); % MPC strategy performs the first control decision every step

end




