%[2 4 5 6 11 12 13 14 18 19 22 24 27 28 31 34 35 42 45
val1=5;
colors={'r','g','b','y','c','m','k','b'}
scenenames={'Studio/Room', 'Kitchen', 'Corridor','Bathroom','others/blur','Living Room','Outdoor','Laundry'};
iCount=0;

load('betas_objects_in_scenes_test_ALL.mat');
betasT=betas;
thescore3T=thescore3;
target3T=target3;

load('betas_objects_in_scenes_ALL.mat');

load('allclasses4.mat');

for val1=[ 24];
    %for val1=[2 4 5 6 11 12 13 14 18 19 22 24 27 28 31 34 35 42 45];
    ivalid=0;
    legends={};
    iCount=iCount+1;
    figure(iCount);
    for i=1:8
        % close(i);
        subplot(1,2,1);
        val2=i;
        beta=betas{val1,val2};
        ivalid
        if(size(beta,1)==1)
            ivalid=ivalid+1;
            %xs = linspace(min(thescore3{val1,val2}),max(thescore3{val1,val2}),1000);
            xs = linspace(-2,2,1000);
            fx = @(x)(1./(1+exp(-beta(1)*(x-beta(2)))));
            %plot(xs,fx(xs),colors{i},'LineWidth',2)
           
            legends{ivalid}=(scenenames{i} );
            hold on
%             shift=0;
%             if(i==1)
%                shift=-1.2
%             end
            plot(thescore3{val1,val2},target3{val1,val2},[colors{i} '.'],'MarkerSize',14)
            xlim([-2 2])
            ylim([0 0.9])
        end
    end    
    legend(legends{:})
    title(classes{val1})
    ylabel('Groundtruth matching');
    xlabel('Detector Score');
    
%TESTING part    
    ivalid=0;
    legends={};
    for i=1:8
        subplot(1,2,2);
        val2=i;
        beta=betasT{val1,val2};
        score4=thescore3T{val1,val2};
        target4=target3T{val1,val2};
        
        ivalid
        if(size(beta,1)==1)
            ivalid=ivalid+1;
            %xs = linspace(min(thescore3{val1,val2}),max(thescore3{val1,val2}),1000);
            xs = linspace(-2,2,1000);
            fx = @(x)(1./(1+exp(-beta(1)*(x-beta(2)))));
            %plot(xs,fx(xs),colors{i},'LineWidth',2)
            %text(-0.5,fx(-0.5),['\leftarrow ' scenenames{i} ],'HorizontalAlignment','left')
            legends{ivalid}=(scenenames{i} );
            hold on
            plot(score4,target4,[colors{i} '.'],'MarkerSize',14)
        end
    end
    legend(legends{:})
    title(classes{val1})
end