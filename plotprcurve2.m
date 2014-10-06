function datapoints=plotprcurve2(score,target,num_of_instances,color,shape)
datapoints=zeros(size(score,1),2);


for i=1:size(target,1)
    datapoints(i,:)=[sum(target(1:i,1))/i (sum(target(1:i))/num_of_instances)];
end

prec = datapoints(:,1);
rec = datapoints(:,2);
plot(rec, prec, '-');
hold on;

 for ind=1:size(datapoints,1)
 plot(datapoints(ind,2),max(datapoints(ind:end,1)),shape,'MarkerSize',10,'color',color);hold on;
 end
    