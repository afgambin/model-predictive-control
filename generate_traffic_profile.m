function [array_power_demand_BS] = generate_traffic_profile(average_daily_traffic, max_UE_per_BS_lowerTh, max_UE_per_BS_upperTh, N, array_PC_activities)

array_BS_averageDailyTraffic = zeros(length(average_daily_traffic), N);   
a = max_UE_per_BS_lowerTh;
b = max_UE_per_BS_upperTh;
array_power_demand_BS = zeros(length(average_daily_traffic), N);

for i=1:N    
    r = a + (b-a).*rand(length(average_daily_traffic),1);  % random number between [a,b]
    array_BS_averageDailyTraffic(:,i) = round(r.*average_daily_traffic');
    
    for j=1:length(average_daily_traffic)
       tasks = randi(length(array_PC_activities), array_BS_averageDailyTraffic(j,i),1);
       array_power_demand_BS(j,i) = sum(array_PC_activities(tasks));
    end
end

%array_power_demand_BS = randi(75, length(average_daily_traffic), N);

end