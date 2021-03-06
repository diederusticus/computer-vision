function [ dpdy, dqdx ] = check_integrability( p, q )
%CHECK_INTEGRABILITY check the surface gradient is acceptable
%   p : measured value of df / dx
%   q : measured value of df / dy
%   dpdy : second derivative dp / dy
%   dqdx : second derviative dq / dx

dpdy = zeros(size(p, 1), size(p, 2));
dqdx = zeros(size(q, 1), size(q, 2));

% TODO: Your code goes here
% approximate derivate by neighbor difference

[temp1 , dpdy] = gradient(p) ; % we only want derivative of p w.r.t y
[dqdx,temp2] = gradient(q);    % we only want derivative of q w.r.t x


end

