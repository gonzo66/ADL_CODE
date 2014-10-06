
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to perform calibration of objet detection (each object) in each
% type of scene.
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - Inputs 
% classification_results = ground truth with the scene
%
% - Outputs: filtered probability of scene for each frame
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Gonzalo Vaca-castano
% Date: Sep 16 2014
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('groundtruthAP.mat');
if(~exist('annotation_dir','var'))
    annotation_dir='/home/gonzalo/WACV2015/ADL_annotations/object_annotation/'
end
load('allclasses4.mat');
load('sceneannotations3.mat');

target3=cell(45,8);
thescore3=cell(45,8);
path0 = '/home/gonzalo/WACV2015/'; %% Dataset path

scene_labels =[ 2 1 8 3 -1 4 0 5];
for iVideo=1:6
[annot annot_frs] = read_object_annotation(sprintf('%s/object_annot_P_%02d.txt',annotation_dir,iVideo));
        for iClass=1:length(classes) 
        %for iClass=[ 5 18 19 24 25 26 27 34 35 44]
           sprintf('iVideo: %02d , iClass: %02d',iVideo,iClass)
           indxclass=ismember(annot.label,classes{iClass});
           gt.fr=annot.fr(indxclass);
           gt.bbox=annot.bbox(indxclass,:);
           
           %load detection
           if iVideo<7
             path2 = [path0 'ADL_detected_objects/trainset/active/'];   %% detected active objects
             path3 = [path0 'ADL_detected_objects/trainset/passive/'];  %% detected passive objects    
          else
             path2 = [path0 'ADL_detected_objects/testset/active/'];   %% detected active objects
             path3 = [path0 'ADL_detected_objects/testset/passive/'];  %% detected passive objects
          end
           detection_file = [path3 classes{iClass} '/' 'P_' sprintf('%0.2d', iVideo) '.mat'];
           if(exist(detection_file,'file'))
               load(detection_file);          
               numdetections=length([boxes{:}]);
               target=zeros(numdetections,1);
               st=1;
               alldata=[boxes{:}];
               thescore=cat(1,alldata(:).s);          
               
               FN=0;
               for iGT=1:length(gt.fr)               
                  %framepos=find(gt.fr(iGT)==annot_frs);
                  framepostemp=abs(gt.fr(iGT)-frs);
                  [~, framepos]=min(framepostemp);
                  framepos=min(length(boxes),framepos);
                  
                  if(~isempty(framepos))
                      try
                          nmsbbox=cat(1,boxes{framepos}.xy);              
                          nmsscore=cat(1,boxes{framepos}.s);
                          [list_overlapped,tmpscores2]=GV_isGTdetected(nmsbbox/2,gt.bbox(iGT,:));                      
                          
                          if(length(nmsscore)~=length(tmpscores2))
                             pause(1) 
                          end

                          %list_overlapped=GV_isGTdetected(detect.bbox(detectionsinframeind,:),gt.bbox(iGT,:));
                          [v, Intarget]=max(nmsscore(list_overlapped));
                          indtemp=find(list_overlapped); 
                      catch
                         indtemp=[]; 
                         FN=FN+1;
                         continue;
                      end
                      if(isempty(indtemp))
                          FN=FN+1;
                      end                     
                      st=length([boxes{1:framepos-1}])+1;
                     
                      iScene2=P{iVideo}(P{iVideo}(:,1)<=framepos &  P{iVideo}(:,2)>=framepos,3);
                      if(isempty(iScene2))
                          iScene2=-1;
                      end
                      iScene=find(scene_labels==iScene2);
                      target3{iClass,iScene}=[target3{iClass,iScene};tmpscores2];
                      thescore3{iClass,iScene}=[thescore3{iClass,iScene}; nmsscore];
                      
                      %thescore(st:st+length(nmsscore)-1)=nmsscore;
                      target(st+indtemp(Intarget)-1)=1;
                      st=st+length(nmsscore);
                  else
                      FN=FN+1;
                  end
               end
           end
        end
    end



for iScene=1:8
     for iClass=1:length(classes)
         if(~isempty(thescore3{iClass,iScene}))
            betas{iClass,iScene} = esvm_learn_sigmoid( thescore3{iClass,iScene} , target3{iClass,iScene});        
         end
     end
end
save('betas_objects_in_scenes_test.mat','betas','thescore3','target3');

maxshift=0.6;
%Calculate shiftings for each scene-class
for iClass=1:45    
    targetnum=length(cat(1,target3{iClass,:}));
    if(targetnum)
        for iScene=1:8
            percentage{iClass,iScene}=length(target3{iClass,iScene})/targetnum ;
            shifts{iClass,iScene}= maxshift*(percentage{iClass,iScene}-(1/8));
            
        end
    end
end
save('betas_objects_in_scenes_test.mat','betas','thescore3','target3','shifts');


