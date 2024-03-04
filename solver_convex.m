function [x] = solver_convex(E, G, D, a)

% E -> Energy matrix
% G -> Graph matrix
% D -> Demand vector
% a -> Scalarization factor

S = size(E, 2);  % sources
R = length(D);  % receivers

%cvx_solver sedumi
cvx_begin quiet
    variable x(R, S)
    minimize(a*(sum((sum(E.*x,2)-D).^2)) + (1-a)*(sum(sum(1./exp(x./G)))))  % In G a zero never occurs 
    subject to                                                              % -> Dijkstra returns 1 between direct links
        0 <= x <= 1                                                         % -> otherwise, use 1 + G
        sum(x) <= 1
cvx_end

cost = abs(sum(sum(E.*x,2) - D));
fprintf('Solution cost: %d \n',cost)


% debug
% S = size(E, 2);  % sources
% R = length(D);  % receivers
% 
% D = repmat(D, 1, S);
% 
% a = 0.5;
% c = 0.5;
% 
% %cvx_solver sedumi
% cvx_begin quiet
%     variable x(R, S)
%     minimize( a*(sum((sum(E.*x,2)-D(:,1)).^2)) + c*(sum(sum(1./exp(x./D)))) )
%     subject to                                                              % -> Dijkstra returns 1 between direct links
%         0 <= x <= 1                                                         % -> otherwise, use 1 + G
%         sum(x) <= 1
% cvx_end



end