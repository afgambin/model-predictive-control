function [batteryLevel] = updateBattery(arrayBatteries, batteryMax)
    
    N = length(arrayBatteries);
    
    % Random processes per harvesting and demand
    harvestingPower = randi(20,N,1);            % find accurate approaches for this, every BS has to be different load and weather
    demandPower = randi(35, N, 1);
    
    batteryLevel = arrayBatteries - demandPower + harvestingPower;
    batteryLevel(batteryLevel > batteryMax) = batteryMax;
    batteryLevel(batteryLevel < 0) = 0;

end