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
    detection_dir='/home/gonzalo/WACV2015/outs/'
end
if(~exist('annotation_dir','var'))
    annotation_dir='/home/gonzalo/WACV2015/ADL_annotations/object_annotation/'
end
load('allclasses4.mat');


path0 = '/home/gonzalo/WACV2015/'; %% Dataset path
aps=zeros(20,45)
    for iVideo=1:20
        %load ground truth
        [annot annot_frs] = read_object_annotation(sprintf('%s/object_annot_P_%02d.txt',annotation_dir,iVideo));
        for iClass=1:length(classes)
        %for iClass=[ 5 18 19 24 25 26 27 34 35 44]
            sprintf('iVideo: %02d , iClass: %02d',iVideo,iClass)
           indxclass=ismember(annot.label,classes{iClass});
           gt.fr=annot.fr(indxclass);
           gt.bbox=annot.bbox(indxclass,:);
           
          detection_file=sprintf('%s/P%02d-%02d.mat',detection_dir,iVideo,iClass);
          % detection_file = [path3 classes{iClass} '/' 'P_' sprintf('%0.2d', iVideo) '.mat'];
           if(exist(detection_file,'file'))
               %load(detection_file);
               outdir=detection_dir;
               detect=GV_detection_NMS(sprintf('%s/P%02d-%02d.mat',detection_dir,iVideo,iClass),outdir);

               numdetections=length(detect.score);
               target=zeros(numdetections,1);
               st=1;
               alldata=detect.bbox;
               thescore=detect.score;
               %thescore=cat(1,alldata(:).s);
               %theBB=cat(1,alldata(:).xy);
               FN=0;
               for iGT=1:length(gt.fr)               
                  %framepos=find(gt.fr(iGT)==annot_frs);
                  %framepos=find(annot_frs==gt.fr(iGT))
                  framepostemp=abs(gt.fr(iGT)-annot_frs);
                  [~, framepos]=min(framepostemp);
                 % framepos=min(length(),framepos);
                  
                  if(~isempty(framepos))
                      try
                      thisframe=(detect.fr==framepos);
                      nmsbbox=alldata(thisframe,[2 1 4 3]);              
                      nmsscore=thescore(thisframe);
                      list_overlapped=GV_isGTdetected(nmsbbox,gt.bbox(iGT,:));
                      %list_overlapped=GV_isGTdetected(detect.bbox(detectionsinframeind,:),gt.bbox(iGT,:));
                      [v, Intarget]=max(nmsscore(list_overlapped));
                      indtemp=find(list_overlapped); 
                      catch
                         indtemp=[]; 
                      end
                      if(isempty(indtemp))
                          FN=FN+1;
                      end
%                       if(iGT==71)
%                          pause(1) 
%                       end
                      temp=find(thisframe);
                      if(~isempty(temp))
                          st=temp(1);
                          %thescore(st:st+length(nmsscore)-1)=nmsscore;
                          target(st+indtemp(Intarget)-1)=1;
                          st=st+length(nmsscore);
                      else
                          pause(1)
                      end
                  else
                      FN=FN+1;
                  end

               end
               %thescore(st:end,:)=[];
               %target(st:end,:)=[];
               thescore(end+1:end+FN)=-10;
               target(end+1:end+FN)=1;             
               if (length(gt.fr) > 0)
                    %[prec, tpr, fpr, thresh] = prec_rec2(thescore, target,'plotPR',true);
                    [prec, tpr, fpr, thresh] = prec_rec2(thescore, target);
                    mAP=0;
                    mAP=trapz([tpr(~isnan(prec))],[prec(~isnan(prec))]);
                    aps(iVideo,iClass)=mAP;
                    sprintf('iVideo: %02d Class: %s GT has %d BB, detection has %d ; mAP: %f ',iVideo , classes{iClass},length(gt.fr),FN,mAP)     
               end
           end
        end
    end
    save('RESULTobjectDetection.mat','aps');
end
