function [route] = first_disjoint_route(visited_nodes_routes)

% Check best combination of disjoint routes
indexes = 1:size(visited_nodes_routes,1);
first_solution_found = 0;

for i= size(visited_nodes_routes,1):-1:2
    indexes_matrix = nchoosek(indexes, i);
    
    for j=1:size(indexes_matrix,1)
       current_indexes = indexes_matrix(j,:);
       possible_pairs = nchoosek(current_indexes, 2);
       
       counter = 0;
       for k=1:size(possible_pairs,1)
           pair_routes = visited_nodes_routes(possible_pairs(k,:),:);
           check = sum(sum(pair_routes) > 1);
           
           if check > 1
              break; 
           else
              counter = counter + 1; 
           end
       end
       
       if counter == size(possible_pairs,1)
           first_solution_found = 1;
%            g = sprintf('%d ',  current_indexes);
%            fprintf('Valid routes: %s \n', g)  % valid route indexes
           break;
       end
       
    end
    
    if first_solution_found == 1
       break; 
    end  
    
end

route = current_indexes;

end