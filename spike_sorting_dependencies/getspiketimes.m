function spiketimes = getspiketimes(firingsmda)

id = firingsmda(3,:)';   % pull out spike ids
PCt = firingsmda(2,:)';   % pull out spike timestamps

n = max(id);    % max of id = number of cells

spiketimes = cell(2,n);

for i = 1:n
    spiketimes{2,i} = PCt(id==i);
    spiketimes{1,i} = i.*ones(size(spiketimes{2,i},1),1);
end
spiketimes = spiketimes';
