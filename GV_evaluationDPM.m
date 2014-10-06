% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to evaluate the detections using precision-recall curves
% for our results
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - Inputs 
% detection_dir = detections after doing NMS 
% annotation_dir: annotations for the objects and videos
% - Outputs: annotation file
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Gonzalo Vaca-castano
% Date: July 29 2014
% Bosch CR/RTC 3 NorthAmerica
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function aps=GV_evaluationDPM(detection_dir,annotation_dir)
if(~exist('detection_dir','var'))
    detection_dir='/home/gonzalo/WACV2015/ADL_code/outs/'
end
if(~exist('annotation_dir','var'))
    annotation_dir='/home/gonzalo/WACV2015/ADL_annotations/object_annotation/'
end
load('allclasses4.mat');
bEval=1;

path0 = '/home/gonzalo/WACV2015/'; %% Dataset path
iCount2=0;
superscore=cell(length(classes),1);
supertarget=cell(length(classes),1);
%for iFix=-0.5:0.5:0.5
for iFix=0
aps=zeros(20,45);
iCount2=iCount2+1;
    for iVideo=7:20
        %load ground truth
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
           if bEval
          path3='/home/gonzalo/WACV2015/ADL_detected_objects/improved/';
          path3=[path3 num2str(iFix) '/']
           end
           detection_file = [path3 classes{iClass} '/' 'P_' sprintf('%0.2d', iVideo) '.mat'];
           if(exist(detection_file,'file'))
               load(detection_file);
              %     outdir=detection_dir;
              %     detect=GV_detection_NMS(sprintf('%s/P%02d-%02d.mat',detection_dir,iVideo,iClass),outdir);
              if bEval
              boxes=newboxes;
              end
              
               numdetections=length([boxes{:}]);
               target=zeros(numdetections,1);
               st=1;
               alldata=[boxes{:}];
               thescore=cat(1,alldata(:).s);
               target2=zeros(length(thescore),1);
               target3=[];
               thescore3=[];
               
               %theBB=cat(1,alldata(:).xy);
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

                          %list_overlapped=GV_isGTdetected(detect.bbox(detectionsinframeind,:),gt.bbox(iGT,:));
                          [v, Intarget]=max(nmsscore(list_overlapped));
                          indtemp=find(list_overlapped); 
                      catch
                         indtemp=[]; 
                      end
                      if(isempty(indtemp))
                          FN=FN+1;
                      end                     
                      st=length([boxes{1:framepos-1}])+1;
                      %target2(st:st+length(nmsscore)-1)=tmpscores2;
                      target3=[target3;tmpscores2];
                      thescore3=[thescore3; nmsscore];
                      
                      %thescore(st:st+length(nmsscore)-1)=nmsscore;
                      target(st+indtemp(Intarget)-1)=1;
                      st=st+length(nmsscore);
                  else
                      FN=FN+1;
                  end
               end
               %thescore(st:end,:)=[];
               %target(st:end,:)=[];
               scores{iVideo}{iClass}=thescore3;
               targets{iVideo}{iClass}=target3;
               
               thescore(end+1:end+FN)=-10;
               target(end+1:end+FN)=1;             
               if (length(gt.fr) > 0)
                    %[prec, tpr, fpr, thresh] = prec_rec2(thescore, target,'plotPR',true);
                    [prec, tpr, fpr, thresh] = prec_rec2(thescore, target);
                    superscore{iClass}=cat(1,superscore{iClass},thescore);
                    supertarget{iClass}=cat(1,supertarget{iClass},target);
                    mAP=0;
                    mAP=trapz([tpr(~isnan(prec))],[prec(~isnan(prec))]);
                    aps(iVideo,iClass)=mAP;
                    sprintf('iVideo: %02d Class: %s GT has %d BB, detection has %d ; mAP: %f ',iVideo , classes{iClass},length(gt.fr),FN,mAP)     
               end
           end
        end
    end
    
    for iclass=[2 4 5 6 11 12 13 14 18 19 22 24 28 31 34 35 42 45]
            [prec, tpr, fpr, thresh] = prec_rec2(superscore{iclass}, supertarget{iclass});
            mAP(iclass)=0;
            mAP(iclass)=trapz([tpr(~isnan(prec))],[prec(~isnan(prec))]);
   end
    if(bEval)
        
    save(['improveswithsceneAP' num2str(iFix) '.mat'],'aps','scores','targets','mAP');
    else
       save('groundtruthAP.mat','aps','scores','targets'); 
    end
    figure(iCount2);
    bar(mean(aps(7:20,[2 4 5 6 11 12 13 14 18 19 22 24 27 28 31 34 35 42 45])));
    title(num2str(iFix));
end
end
