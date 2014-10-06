
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to perform calibration of scene classification (obtain
% probabilities of belong to some type of scene), and filtering based on
% temporal constraint.
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - Inputs 
% classification_results = scores of the SVM for scene identification 
%
% - Outputs: filtered probability of scene for each frame
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Gonzalo Vaca-castano
% Date: Sep 16 2014
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%load('scene_detections_CNN5-3.mat');
%load('scene_simplemodel3.mat');

load('scene_detections_BoW.mat');
load('scene_BoWmodel.mat');

alllabel=cat(1,labeldata{:});
thescores=cat(1,c{:});
scenenames={'Studio/Room', 'Kitchen', 'Corridor','Bathroom','others/blur','Living Room','Outdoor','Laundry'};
%loop over all the labels to perform calibration
bPlot=1;
for iLabel=1:length(model.Label)
 
 
 allscores=thescores(:,iLabel);
% %%%%% Attempt 1.%%%%%%%%%%%
% get randomly 50 positives and 200 negatives
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 positives=find(alllabel==model.Label(iLabel));
 negatives=find(alllabel~=model.Label(iLabel));
 
 if length(positives)>20
    positives=positives(randi(length(positives),[20,1])); 
 end
 if length(negatives)>20
    negatives=negatives(randi(length(negatives),[20,1])); 
 end
 
scores=[allscores(positives); allscores(negatives)]; 
values=[ones(length(positives),1) ; zeros(length(negatives),1) ];
 
% % ATTEMPT 2 %%%%%%%%%%%%%%%
% pick randomly answers and see how many get in the positives and negatives
%%%%%%%%%%%%%%%%%%%%%%%%
% choose=randi(length(alllabel),[2000,1]);
% positives= find(alllabel(choose)==model.Label(iLabel));
% negatives= find(alllabel(choose)~=model.Label(iLabel));
% scores=[1 ; allscores(positives); allscores(negatives)]; 
% values=[1 ; ones(length(positives),1) ; zeros(length(negatives),1) ];

 beta = esvm_learn_sigmoid(scores, values);
 betas{iLabel} = beta;
 % [b]=rand(100,1);
% [a]=b*3.*(1-rand(100,1))-1;
% beta = esvm_learn_sigmoid(a, b);
 if bPlot
    subplot(2,4,iLabel);
    xs = linspace(min(scores),max(scores),1000);
    fx = @(x)(1./(1+exp(-beta(1)*(x-beta(2)))));
    plot(xs,fx(xs),'b','LineWidth',2)
    hold on
    plot(scores,values,'r.','MarkerSize',14)
    axis([min(xs) max(xs) 0 1])
    title(scenenames(iLabel))
 end
% xlabel('SVM score');
end
betamax=mean(cat(1,betas{:}))

for iVideos=1:length(c)
   score=c{iVideos};
   % Attempt 1 & 2
   %probs{iVideos}=[1./(1+exp(-betas{1}(1).*(score(:,1)-betas{1}(2)))), 1./(1+exp(-betas{2}(1).*(score(:,2)-betas{2}(2)))) ,  1./(1+exp(-betas{3}(1).*(score(:,3)-betas{3}(2))))  , 1./(1+exp(-betas{4}(1).*(score(:,4)-betas{4}(2)))) , 1./(1+exp(-betas{5}(1).*(score(:,5)-betas{5}(2)))) , 1./(1+exp(-betas{6}(1).*(score(:,6)-betas{6}(2)))) ,  1./(1+exp(-betas{7}(1).*(score(:,7)-betas{7}(2)))) , 1./(1+exp(-betas{8}(1).*(score(:,8)-betas{8}(2)))) ] ;
   
   %#attempt 3
   probs{iVideos}=[1./(1+exp(-betamax(1).*(score(:,1)-betamax(2)))), 1./(1+exp(-betamax(1).*(score(:,2)-betamax(2)))) ,  1./(1+exp(-betamax(1).*(score(:,3)-betamax(2))))  , 1./(1+exp(-betamax(1).*(score(:,4)-betamax(2)))) , 1./(1+exp(-betamax(1).*(score(:,5)-betamax(2)))) , 1./(1+exp(-betamax(1).*(score(:,6)-betamax(2)))) ,  1./(1+exp(-betamax(1).*(score(:,7)-betamax(2)))) , 1./(1+exp(-betamax(1).*(score(:,8)-betamax(2)))) ] ;
   
   probs{iVideos}=probs{iVideos}./repmat(sum(probs{iVideos},2),1,length(model.Label));
   %end 
end



% evaluation
for i=1:length(probs)
   theprob=probs{i};
   prob2=theprob;
   for iClass=1:length(model.Label)
        prob2(:,iClass)=conv(theprob(:,iClass),[0.125 0.125 0.125 0.125 0.125 0.125 0.125 0.125 ],'same');
   end
   probs2{i}=prob2;
   [d,dd]=max(prob2');
    
   %[d,dd]=max(probs{i}'); %attemp 1, 2   
  % [d,dd]=max(c{i}');  
   myprediction=model.Label(dd);
   
   myacc(i)=sum(myprediction==labeldata{6+i})/length(myprediction)
   
end
save('results_sceneBoW_time.mat','probs','probs2','-v7.3');


