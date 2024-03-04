function [x] = solver_hungarian(E, G, D, alpha)

% E -> Energy matrix
% G -> Graph matrix
% D -> Demand vector
% a -> Scalarization factor

S = size(E, 2);  % sources
R = length(D);  % receivers

cost_matrix = zeros(S,R);

for i=1:S
    cost_matrix(i,:) = alpha*((E(:,i)-D).^2) + (1-alpha)*(1./exp(1./G(:,i)));
end

[assignment,cost] = munkres(cost_matrix);   % Hungarian algorithm

x_hungarian = zeros(S,R);

for j=1:S
    if (assignment(j) == 0)
        continue;
    else
        x_hungarian(j,assignment(j)) = 1;
    end
end

disp(['assignment:', num2str(assignment)]); 
disp(['cost: ', num2str(cost)]);

x = x_hungarian';

end