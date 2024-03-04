
% figure, plot(array_power_demand_BS(:,15), '-*r')
% hold on
% plot(array_BS_HE(:,1),'-sg')
% hold on
% plot(array_BS_HE(:,15),'-xb')
% xlabel('Hour of the day (h)')
% ylabel('Power (W)')
% grid on
% legend('Power consumption', 'Off-grid harvested power', 'On-grid harvested power')
% axis tight;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% graph mean when change N_on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Outage prob
hourly_mean_hun = [0.75 0.589 0.333 0.116 0.000234 0];
hourly_mean_cvx = [0.74 0 0 0 0 0];
hourly_mean_no = [0.7537 0.7021 0.6144 0.4887 0.3965 0.25];

xaxis = [0 1 3 6 9 12];

figure, plot(xaxis, hourly_mean_hun, '-*b')
hold on 
plot(xaxis, hourly_mean_cvx, '-sg')
hold on
plot(xaxis, hourly_mean_no, '-xr')
%title('Daily base station outage probability')
xlabel('|N_{on}|')
ylabel('Outage probability, \eta')
grid on
legend('Hungarian solution', 'Convex solution', 'No energy exchange')
axis tight;


% Battery level
hourly_mean_hun = [7.7938 15.96 29.66 49.697 61.88 75.5];
hourly_mean_cvx = [7.7298 14.63 26.73 46.373 58.84 73.44];
hourly_mean_no = [8.2127 14.25 24.49 40.081 52.97 69.04];

xaxis = [0 1 3 6 9 12];

figure, plot(xaxis, hourly_mean_hun, '-*b')
hold on 
plot(xaxis, hourly_mean_cvx, '-sg')
hold on
plot(xaxis, hourly_mean_no, '-xr')
%title('Daily base station outage probability')
xlabel('|N_{on}|')
ylabel('Battery level (Wh), \it{B}')
grid on
legend('Hungarian solution', 'Convex solution', 'No energy exchange')
axis tight;


% Purchased power from EG
hourly_mean_hun = [442.6852 356.697 226.898 83.4388 7.93 2.3738];
hourly_mean_cvx = [443.4184 371.8676 260.7452 93.3319 7.37 0.0073];
hourly_mean_no = [446.7176 415.2358 365.0824 288.4986 231.41 149.1702];

xaxis = [0 1 3 6 9 12];

figure, plot(xaxis, hourly_mean_hun, '-*b')
hold on 
plot(xaxis, hourly_mean_cvx, '-sg')
hold on
plot(xaxis, hourly_mean_no, '-xr')
%title('Daily base station outage probability')
xlabel('|N_{on}|')
ylabel('Total purchased power (W)')
grid on
legend('Hungarian solution', 'Convex solution', 'No energy exchange')
axis tight;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% graph mean when change traffic load
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Outage prob
hourly_mean_hun = [0.0055 0.2912 0.6021 0.6516];
hourly_mean_cvx = [0 0 0.1004 0.2067];
hourly_mean_no = [0.2414 0.5718 0.7803 0.8035];

xaxis = [100 300 500 700];

figure, plot(xaxis, hourly_mean_hun, '-*b')
hold on 
plot(xaxis, hourly_mean_cvx, '-sg')
hold on
plot(xaxis, hourly_mean_no, '-xr')
%title('Daily base station outage probability')
xlabel('Average number of users per BS')
ylabel('Outage probability, \eta')
grid on
legend('Hungarian solution', 'Convex solution', 'No energy exchange')
axis tight;


% Battery level
hourly_mean_hun = [61.29 33.365 16.4 14.14];
hourly_mean_cvx = [58.93 29.813 15.3 13.29];
hourly_mean_no = [51.1588 26.94 16.985 15.564];

xaxis = [100 300 500 700];

figure, plot(xaxis, hourly_mean_hun, '-*b')
hold on 
plot(xaxis, hourly_mean_cvx, '-sg')
hold on
plot(xaxis, hourly_mean_no, '-xr')
%title('Daily base station outage probability')
xlabel('Average number of users per BS')
ylabel('Battery level (Wh), \it{B}')
grid on
legend('Hungarian solution', 'Convex solution', 'No energy exchange')
axis tight;


% Purchased power from EG
hourly_mean_hun = [44.6730 203.905 362.8673 386.196];
hourly_mean_cvx = [58.2648 241.9858 379.1191 399.748];
hourly_mean_no = [181.0070 345.2037 437.8421 444.8681];

xaxis = [100 300 500 700]; 

figure, plot(xaxis, hourly_mean_hun, '-*b')
hold on 
plot(xaxis, hourly_mean_cvx, '-sg')
hold on
plot(xaxis, hourly_mean_no, '-xr')
%title('Daily base station outage probability')
xlabel('Average number of users per BS')
ylabel('Total purchased power (W)')
grid on
legend('Hungarian solution', 'Convex solution', 'No energy exchange')
axis tight;






