function [allocated_receivers, allocated_rec_indexes] = tdma_algorithm(topology, sources, receivers, x, E, ts_duration, max_power_ts, trading_freq)

addpath('Dijkstra')

%%%%%%%%%%%%%%%%%%% START DEBUG PARAMS
% close all, clear all, clc
% topology = [
%     0 0 0 0 1 1 0 0 0 0 1 0 0 0 0 1 0 0;
%     0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0;
%     0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0;
%     0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0;
%     1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
%     1 0 0 1 0 0 1 0 0 0 0 0 0 0 0 0 0 0;
%     0 0 0 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0;
%     0 0 0 0 0 0 1 0 1 1 0 0 0 0 0 0 0 0;
%     0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0;
%     0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0;
%     1 0 0 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0;
%     0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0;
%     0 0 0 0 0 0 0 0 0 0 1 0 0 1 1 0 0 0;
%     0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0;
%     0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0;
%     1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1;
%     0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0;
%     0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0];
% 
% % figure, plot(graph(topology))
% % title('Network topology')
% 
% sources = [1 5 8 15];
% %sources = [3 4 12];
% %receivers = 1;
% receivers = [3 7 18];
% 
% load('x.mat')
% %x = [1 1 1];
% %E = [8.52 3.32 15.13];
% 
% S = length(sources);  % sources
% R = length(receivers); % receivers
% 
% E = repmat(randi(50,1,4),R, 1);
% max_power_ts = 25;
% trading_freq = 60;
%ts_duration = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%% END DEBUG PARAMS

N = length(topology);

accurate_th = 1000;
x_rounded = round(x*accurate_th);
visited_nodes_routes = zeros(sum(sum(x_rounded ~= 0)),N);
weights_routes = zeros(size(visited_nodes_routes,1),1); 
receiver_routes = zeros(size(visited_nodes_routes,1),1);
index_cont = 1;

for i = 1:length(sources)
    
    destinations = receivers(x_rounded(:,i) ~= 0);
    weight_indexes = find(x_rounded(:,i) ~= 0);
    
    for j = 1:length(destinations)
        [~, route] = dijkstra(topology,sources(i),destinations(j));        
        visited_nodes_routes(index_cont, route) = 1; 
        
        weights_routes(index_cont) = E(1,i)*x(weight_indexes(j),i);
        receiver_routes(index_cont) = weight_indexes(j); 
        
        index_cont = index_cont + 1;
    end
end

% Number of time slots (ts) per route
ts_routes = ceil(weights_routes/max_power_ts);
N_ts = trading_freq/ts_duration;
ts_routes_counter = ts_routes;


% TS scheduling
current_indexes = 1:size(visited_nodes_routes,1);
current_routes_table = visited_nodes_routes(current_indexes,:);
receivers_ts = zeros(length(receivers),N_ts);

if size(current_routes_table,1) > 1
    
    for ts=1:N_ts
        
        valid_routes_current = first_disjoint_route(current_routes_table);
        valid_routes = current_indexes(valid_routes_current);
        
        % Printing valid routes for this ts
        g = sprintf('%d ',  valid_routes);
        fprintf('Valid routes: %s \n', g)  % valid route indexes
        
        ts_routes_counter(valid_routes) = ts_routes_counter(valid_routes) - 1;
        current_indexes = find(ts_routes_counter > 0);
        current_routes_table = visited_nodes_routes(current_indexes,:);
        
        receivers_ts(receiver_routes(valid_routes), ts) = 1;
        
        if(length(current_indexes) < 2)
            
            if (length(current_indexes) < 1)
                break;
            end
            
            valid_route = current_indexes;
            % Printing valid routes for this ts
            g = sprintf('%d ',  valid_route);
            fprintf('Valid routes: %s \n', g)  % valid route indexes
            receivers_ts(receiver_routes(valid_route), ts+1) = 1;
            break;          
        end
        
        
        
    end
    
end

allocated_rec_indexes = sum(x_rounded ~= 0,2) ~= 0;

allocated_receivers = zeros(length(receivers),1);
for r=1:size(receivers_ts,1)
    allocated_ts = find(receivers_ts(r,:) == 1,1);
    
    if ~isempty(allocated_ts)
        allocated_receivers(r) = find(receivers_ts(r,:) == 1,1);
    end
end



end
