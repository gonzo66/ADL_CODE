% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to test the improvement in object detection
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - Inputs 
% models for calibration of detectors according to the scene
% results for scene identification
% object detection
%
% - Outputs: object detectio results with different scores
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Gonzalo Vaca-castano
% Date: Sep 17 2014
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('results_scene_time.mat'); %probs2
load('betas_objects_in_scenes_test.mat');

if(~exist('annotation_dir','var'))
    annotation_dir='/home/gonzalo/WACV2015/ADL_annotations/object_annotation/'
end
load('allclasses4.mat');
load('sceneannotations3.mat');


outdir2='/home/gonzalo/WACV2015/ADL_detected_objects/improved/';
if(~exist(outdir2,'dir'))
   mkdir(outdir2); 
end


path0 = '/home/gonzalo/WACV2015/'; %% Dataset path
scene_labels =[ 2 1 8 3 -1 4 0 5];

load('results_scene_time.mat')


shifts=[0	0	0	0	0	0	0	0	0	0	0	-1	0	0	0	0	0	-0.5	-1	0	0	0	0	-0.5	0	0	0	-1.2	0	0	-0.8	0	0	-1	-1	0	0	0	0	0	0	-1	0	0	0
0	-1	0	-0.5	0	-0.6	0	0	0	0	-0.3	-1	-0.2	0	0	0	0	0	0	0	0	-0.8	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	-1	0	0	-1
0	-0.6	0	-0.5	-0.4	-0.5	0	0	0	0	0	-1	-0.5	0	0	0	0	-0.5	-0.5	0	0	-1	0	-0.8	0	0	0	-1	0	0	-1	0	0	-1	-1	0	0	0	0	0	0	-1	0	0	-1
0	-0.5	0	-0.5	0	0	0	0	0	0	0	-1	-1.3	0	0	0	0	-1	-1	0	0	-1.2	0	-1	0	0	0	0	0	0	-1	0	0	0	0	0	0	0	0	0	0	-1	0	0	-1.5
0	-0.3	0	-0.5	0	0	0	0	0	0	0	0	-1.2	-0.2	0	0	0	-1	-0.6	0	0	0	0	0	0	0	0	-1	0	0	-1	0	0	-1	-1	0	0	0	0	0	0	-1	0	0	0
0	-0.5	0	-0.3	0	0	0	0	0	0	-0.3	-1	-1.8	-0.5	0	0	0	-0.8	-0.8	0	0	-0.5	0	-1.5	0	0	0	-1	0	0	-1	0	0	-1	-1.5	0	0	0	0	0	0	0	0	0	0
0	-0.5	0	-0.8	-0.6	-0.4	0	0	0	0	-0.3	0	-1.2	0	0	0	0	-1	-0.8	0	0	-1	0	-1.5	0	0	0	-1	0	0	-1	0	0	-1	-1.5	0	0	0	0	0	0	-1	0	0	-1
0	-0.8	0	-0.8	-1.2	-0.4	0	0	0	0	0	0	-1.5	0	0	0	0	-1	-1	0	0	-1	0	-1.2	0	0	0	-1	0	0	-1	0	0	-1	-1.5	0	0	0	0	0	0	-1	0	0	-1.5
];




for iFix=0
outdir=[outdir2 num2str(iFix) '/' ];
if(~exist(outdir,'dir'))
   mkdir(outdir); 
end
for iVideo=7:20
   for iClass=1:length(classes)   
       sprintf('iVideo: %02d , iClass: %02d',iVideo,iClass)
       if(~exist([outdir classes{iClass} '/'],'dir'))
           mkdir([outdir classes{iClass} '/']);
       end
       %load detection
       if iVideo<7
         path2 = [path0 'ADL_detected_objects/trainset/active/'];   %% detected active objects
         path3 = [path0 'ADL_detected_objects/trainset/passive/'];  %% detected passive objects    
      else
         path2 = [path0 'ADL_detected_objects/testset/active/'];   %% detected active objects
         path3 = [path0 'ADL_detected_objects/testset/passive/'];  %% detected passive objects
      end
       detection_file = [path3 classes{iClass} '/' 'P_' sprintf('%0.2d', iVideo) '.mat'];      
       outdetection_file = [outdir classes{iClass} '/' 'P_' sprintf('%0.2d', iVideo) '.mat'];
       if(exist(detection_file,'file'))
           load(detection_file);         
           newboxes=boxes;
           for iBox=1:length(boxes)
               %% With ground truth of scene
               iScene2=P{iVideo}(P{iVideo}(:,1)<=iBox &  P{iVideo}(:,2)>=iBox,3);
               if(isempty(iScene2))
                 iScene2=-1;
               end
               iScene=find(scene_labels==iScene2);
                shift=shifts(iScene,iClass);
               
                %% With results from scene detector
%                sceneprobs=probs2{iVideo-6}(iBox,:);
%                sceneprobs=sceneprobs/(sum(sceneprobs));
%               % sceneprobs(sceneprobs<0.15)=0;
%               % sceneprobs=sceneprobs/(sum(sceneprobs));
%           %     [val,sce]=max(sceneprobs);               
%                shift=sceneprobs*(shifts(:,iClass));
%              
               
               %iBox
%                beta=betas{iClass,iScene};
%                if(isempty(beta))
%                    avgbeta=cat(1,betas{iClass,:});
%                    if(size(avgbeta,1)>1)
%                    beta=mean(avgbeta);
%                    else
%                        beta=avgbeta;
%                    end
%                    
%                end
               
               for iBB=1:length(boxes{iBox})
                  % newboxes{iBox}(iBB).s=(1./(1+exp(-beta(1)*(boxes{iBox}(iBB).s +  shifts{iClass,iScene} -beta(2)))));
                  %newboxes{iBox}(iBB).s=boxes{iBox}(iBB).s + shifts(iScene,iClass);
                  newboxes{iBox}(iBB).s=boxes{iBox}(iBB).s + shift;
               end
           end
           save(outdetection_file,'newboxes','frs','active_or_not');
       end
   end
end
end
