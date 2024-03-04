%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Autor: Angel Fernandez Gambin
% Energy Sustainable Mobile Networks via Energy Routing, Learning and Foresighted Optimization
% Simulator Main File
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BS ENERGY COOPERATION - Main Simulator
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc, clear all, close all
addpath('Dijkstra')
addpath('Hungarian')
addpath('/home/afgambin/cvx/functions/vec_')

tic

%%%%%%%%%%%%%%%%%%%%%%%%%
% SIMULATION PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%

N = 18;     % number of BSs
N_on = 6;   % number of ongrid BSs
plotting = 0;   % to plot figures
trading_freq = 60; % [min] -> Each hour, the trading process is computed 
trading = 1;    % equals to 1, trading is performed
hungarian = 0;  % equals to 1, hungarian (instead of convex) is performed
store = 0;  % store data

% Harvesting energy model
shadowing_factor = 2;

% Traffic load model
max_UE_per_BS_upperTh = 400; % total amount of UEs, NOT active users
max_UE_per_BS_lowerTh = 300; 

% Main loop
days_simulation = 1;
hours_simulation = 24;

% Distribution losses
ISD = 100; % [m] ISD -> Inter Base station Distance

% Battery model
battery_max_level = 100;   %[W]
initial_batteryLevel = randi(battery_max_level, N, 1); %[W]
upThreshold = 0.7*battery_max_level;  % [%]
downThreshold = 0.3*battery_max_level; % [%]

% Weighting factors
alpha = 1;    % Scalarization factor for power allocation (convex sol)
alpha_mpc = 0.5;    % mpc factor

% TDMA scheduling
ts_duration = 1; % [min]
max_power_ts = 25; % [W]
N_ts = trading_freq/ts_duration;    % number of time slots

% Topology initialization
A = [
    0 0 0 0 1 1 0 0 0 0 1 0 0 0 0 1 0 0;
    0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0;
    0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0;
    0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0;
    1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
    1 0 0 1 0 0 1 0 0 0 0 0 0 0 0 0 0 0;
    0 0 0 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0;
    0 0 0 0 0 0 1 0 1 1 0 0 0 0 0 0 0 0;
    0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0;
    0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0;
    1 0 0 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0;
    0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0;
    0 0 0 0 0 0 0 0 0 0 1 0 0 1 1 0 0 0;
    0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0;
    0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0;
    1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1;
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0;
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0];

if plotting
    figure, plot(graph(A))
    title('Network topology')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HARVESTED ENERGY PROFILE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load('CH_currentDistributions_v2_panel1_5x5_6sph.mat')  % real sun traces from Chicago city. LA file is from Los Angeles
power_all_years = reshape(current_after_dcdc(:,1,:),size(current_after_dcdc(:,1,:),1), size(current_after_dcdc(:,1,:),3));
years = size(current_after_dcdc(:,1,:),3);

% Power generation per day
samples_per_day = 144;
mean_data_day = zeros(samples_per_day,1);
mean_data_day_array = zeros(samples_per_day, years);

for i=1:years
    data_year = power_all_years(:,i);
    
    for j=1:samples_per_day:length(data_year)
        data_day = data_year(j:(j+samples_per_day-1)); 
        mean_data_day = mean_data_day + data_day;     
    end
    
    mean_data_day = mean_data_day / 365;
    %figure, plot(mean_data_day)
    mean_data_day_array(:,i) = mean_data_day;
    mean_data_day = zeros(samples_per_day,1);
end

selected_HE = mean_data_day_array(:,randi(years));  % random year between available data

samples_per_hour = 6;
mean_data_hour = zeros(samples_per_hour,1);
selected_HE_24_samples = zeros(24,1);
index = 1;

for j=1:samples_per_hour:length(selected_HE)
    data_hour = selected_HE(j:(j+samples_per_hour-1));
    selected_HE_24_samples(index) = mean(data_hour);
    index = index + 1;
end


if plotting
    figure, plot(selected_HE_24_samples)
    title('Harvested Energy Profile from SolarStat')
    ylabel('Harvested power (W)')
    xlabel('Time (hours)')
    grid on
    axis tight
end

%%%%%%%%%%%%%%%%%%%%%%%%
% TRAFFIC LOAD PROFILE
%%%%%%%%%%%%%%%%%%%%%%%%

% Average daily traffic profile -> EARTH proyect. Differente pattern for
% each BS
average_daily_traffic = [0.125 0.1 0.075 0.05 0.03 0.024 0.024 0.027 0.04 0.07 0.085 0.0964 0.1 0.105 0.11 0.115 0.12 0.1225 0.125 0.13 0.14 0.16 0.155 0.15];

% Samsumg Galaxy 3 average system power [W] depending on running tasks (phone call, email, Web, audio) 
% that suppose an interaction with the BS -> Carroll reference
array_PC_activities = [0.854 1.299 1.020 1.08 0.874 0.226];


% Generating harvested energy and traffic profiles for each simulated day
if exist('dataProfiles.mat', 'file') % If the file exists, it is loaded
    fprintf('Loading pre-saved data profiles...\n');
    load('dataProfiles');
else
    fprintf('Creating new data profiles...\n');
    % Harvested and traffic profiles per each simulation day
    for day=1:days_simulation
        
        % Different renewable energy pattern for each BS and each day
        array_BS_HE = generate_harvested_profile(N, shadowing_factor, selected_HE_24_samples, N_on, upThreshold);
        harvestedEnergy.(['day' num2str(day)]) = array_BS_HE;
        
        % Different traffic profile for each BS and each day
        array_power_demand_BS = generate_traffic_profile(average_daily_traffic, max_UE_per_BS_lowerTh, max_UE_per_BS_upperTh, N, array_PC_activities);
        trafficProfile.(['day' num2str(day)]) = array_power_demand_BS;
        
        if plotting
            figure, plot(array_power_demand_BS(:,16), '-*r')
            hold on
            plot(array_BS_HE(:,1),'-+k')
            hold on
            plot(array_BS_HE(:,18),'-xb')
            xlabel('Hour of the day (h)')
            ylabel('Power (W)')
            grid on
            legend('Power consumption', 'Off-grid harvested power', 'On-grid harvested power')
            axis tight;
        end
        
    end
    
    save('dataProfiles','harvestedEnergy','trafficProfile','initial_batteryLevel');
    
end

%%%%%%%%%%%%%
% MAIN LOOP
%%%%%%%%%%%%%

array_batteryLevel_BS = initial_batteryLevel';

% Stats
array_outage_prob = zeros(days_simulation,hours_simulation);
array_average_batteryLevel = zeros(days_simulation,hours_simulation);
array_energyLevel_Off = zeros(days_simulation,hours_simulation);
trading_hours = zeros(days_simulation,hours_simulation);
outage_cont = 0;
array_power_bought = zeros(days_simulation,hours_simulation);
acum_transfer_eff = 0;
acum_matching_eff = 0;
samples_eff = 0;

deb = 0;

on_purchased_acum = 0;

for day=1:days_simulation
    
    fprintf('Simulation day: %d \n', day);
    
    % Different renewable energy pattern for each BS and each day
    array_BS_HE = harvestedEnergy.(['day' num2str(day)]);
    
    % Different traffic profile for each BS and each day
    array_power_demand_BS = trafficProfile.(['day' num2str(day)]);
   
   % Trading is computed each hour 
   for hour=1:hours_simulation
       
       % Battery level update
       array_batteryLevel_BS = array_batteryLevel_BS - array_power_demand_BS(hour,:) + array_BS_HE(hour,:);
       array_batteryLevel_BS(array_batteryLevel_BS > battery_max_level) = battery_max_level;
       array_batteryLevel_BS(array_batteryLevel_BS < 0) = 0;   
       batteryLevel = array_batteryLevel_BS'; 
       
       if trading == 1
           
           % Definiton of energy rol per BS - Here MPC comes into action..
           current_control = solver_mpc(N, battery_max_level, batteryLevel, alpha_mpc, array_BS_HE, array_power_demand_BS, hour);
           
           sources = find(current_control < 0);
           receivers = find(current_control > 0);
           S = length(sources);
           R = length(receivers);
           
           if S ~= 0 && R ~= 0  % if there are buyers/sellers the trading can be performed
               
               fprintf('Computing solver... \n');
               
               % Definition of energy matrix, demand matrix
               %energySupplies = batteryLevel(sources) - upThreshold;
               energySupplies = abs(current_control(sources));
               E_before_distribution_losses = repmat(energySupplies', R, 1);  % Energy matrix
               %D = abs(batteryLevel(receivers) - downThreshold);   % Demand vector
               D = current_control(receivers);
               
               % Computation of Dijkstra and creation of graph matrix
               G = zeros(length(receivers), length(sources));
               
               for j = 1: length(receivers)
                   for i = 1:length(sources)
                       [cost, ~] = dijkstra(A,sources(i),receivers(j));
                       G(j,i) = cost;
                   end
               end
               
               % Applying distribution losses
               E = distribution_model(G, E_before_distribution_losses, ISD);
               
               if hungarian == 1
                   % Hungarian method solution
                   x_solution = solver_hungarian(E,G,D,alpha);
               else
                   % Optimization problem solution
                   x_solution = solver_convex(E,G,D,alpha);                 
               end
               
               % TDMA scheduling - you do not needed it
               [allocated_receivers, allocated_receivers_indexes] = tdma_algorithm(A, sources, receivers, x_solution, E, ts_duration, max_power_ts, trading_freq);
                                          
               % Battery level update after trading
               array_batteryLevel_BS(sources) = array_batteryLevel_BS(sources) - sum(x_solution.*E_before_distribution_losses,1);
               array_batteryLevel_BS(receivers) = array_batteryLevel_BS(receivers) + sum(x_solution.*E,2)';
               trading_hours(day, hour) = 1;
               
               % Purchased energy from On-grid BS
               on_purchased_acum = on_purchased_acum + sum(upThreshold - array_batteryLevel_BS((N-N_on+1):end));
               
               % Acquiring data (transfer eff and matching eff) - only when
               % trading is performed
               acum_transfer_eff = acum_transfer_eff + sum(sum(x_solution.*E,1)) / sum(sum(x_solution.*E_before_distribution_losses,1));
               matching = round(sum(sum(x_solution.*E,2))) / sum(D);
               if matching > 1
                   matching = 1;
                   deb = deb + 1;
               end
               acum_matching_eff = acum_matching_eff + matching;
               samples_eff = samples_eff + 1;
               
               
           end
           
       end   
       
       % Acquiring data
       need_power_BS_indexes = array_batteryLevel_BS < downThreshold;
       array_power_bought(day, hour) = sum(abs(array_batteryLevel_BS(need_power_BS_indexes) - downThreshold));
       
       array_average_batteryLevel(day,hour) = mean(array_batteryLevel_BS);
       
       % mean battery level of Off-grid BS
       array_energyLevel_Off(day,hour) = mean(array_batteryLevel_BS(1:(N-N_on)));
              
       outage_prog = array_batteryLevel_BS;
       outage_prog(outage_prog > 0) = 1;    
       array_outage_prob(day,hour) = 1-(sum(outage_prog)/N);
       outage_cont = outage_cont + sum(array_batteryLevel_BS == 0);
                  
   end
end

%%%%%%%%%%%%%%
% STATISTICS
%%%%%%%%%%%%%%

% Renewable outage probability
if(days_simulation == 1)
    daily_average_outage_prob = array_outage_prob;
else
    daily_average_outage_prob = mean(array_outage_prob);
end

figure, plot(daily_average_outage_prob)
title('Daily base station outage probability')
xlabel('Time (hours)')
ylabel('Outage Probability')
grid on
axis tight;

% Battery level
if(days_simulation == 1)
    daily_average_batteryLevel = array_average_batteryLevel;
else
    daily_average_batteryLevel = mean(array_average_batteryLevel);
end

figure, plot(daily_average_batteryLevel)
title('Daily base station battery level')
xlabel('Time (hours)')
ylabel('Battery level (Wh)')
grid on
axis tight;

% Battery level Off-grid BS
if(days_simulation == 1)
    daily_average_batteryLevelOFF = array_energyLevel_Off;
else
    daily_average_batteryLevelOFF = mean(array_energyLevel_Off);
end

figure, plot(daily_average_batteryLevelOFF)
title('Daily Off-grid BS battery level')
xlabel('Time (hours)')
ylabel('Battery level (Wh)')
grid on
axis tight;

% Trading profile
if trading == 1
    if(days_simulation == 1)
        daily_trading_hours = trading_hours;
    else
        daily_trading_hours = mean(trading_hours);
    end
    
%     figure, plot(daily_trading_hours)
%     title('Daily trading process')
%     xlabel('Time (hours)')
%     grid on
%     axis tight;
end

% Power bought from the electrical grid
if(days_simulation == 1)
    daily_average_powerBought = array_power_bought;
else
    daily_average_powerBought = mean(array_power_bought);
end

figure, plot(daily_average_powerBought)
title('Daily average power bought from the electrical grid')
xlabel('Time (hours)')
ylabel('Power (W)')
grid on
axis tight;

% Transfer and Matching efficiencies
average_matching_eff = acum_matching_eff / samples_eff;
average_transfer_eff = acum_transfer_eff / samples_eff;

% Storing data
if store == 1
    pathFolder = [pwd '/results/alpha/1'];
    if trading == 1
        if hungarian == 1         
            outage_hun = daily_average_outage_prob;
            battery_hun = daily_average_batteryLevel;
            trading_hun = daily_trading_hours;
            power_bought_hun = daily_average_powerBought;
            match_eff_hun = average_matching_eff;
            transfer_eff_hun = average_transfer_eff;
            save([pathFolder '/hungarian'],'outage_hun','battery_hun','trading_hun', 'power_bought_hun', 'match_eff_hun', 'transfer_eff_hun');
            
        else
            outage_cvx = daily_average_outage_prob;
            battery_cvx = daily_average_batteryLevel;
            trading_cvx = daily_trading_hours;
            power_bought_cvx = daily_average_powerBought;
            match_eff_cvx = average_matching_eff;
            transfer_eff_cvx = average_transfer_eff;
            save([pathFolder '/cvx'],'outage_cvx','battery_cvx','trading_cvx', 'power_bought_cvx', 'match_eff_cvx', 'transfer_eff_cvx');
        end
        
    else
        outage_no = daily_average_outage_prob;
        battery_no = daily_average_batteryLevel;
        power_bought_no = daily_average_powerBought;
        save([pathFolder '/notrading'],'outage_no','battery_no', 'power_bought_no');        
    end
    
    fprintf('Data stored. \n');
end


toc
