function output = interpS2(S2,x,q)
% This function interpolates S2_mean to give a similar number of spikes as
% to ms

[a b] = size(S2);
x = linspace(1,q,x);
q = 1:q;

output = cell(a,b);

for i = 1:a
    for j = 1:b
        output{i,j} = interp1(x,S2{i,j},q,'spline');
    end
end