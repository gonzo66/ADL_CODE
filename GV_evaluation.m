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
function GV_evaluation(detection_dir,annotation_dir)
if(~exist('detection_dir','var'))
    detection_dir='/home/gonzalo/WACV2015/ADL_code/outs/'
end
if(~exist('annotation_dir','var'))
    annotation_dir='/home/gonzalo/WACV2015/ADL_annotations/object_annotation/'
end
load('allclasses4.mat');

    for iVideo=1:20
        %load ground truth
        [annot annot_frs] = read_object_annotation(sprintf('%s/object_annot_P_%02d.txt',annotation_dir,iVideo))
        for iClass=1:length(classes)
        %for iClass=[ 5 18 19 24 25 26 27 34 35 44]
           indxclass=ismember(annot.label,classes{iClass});
           gt.fr=annot.fr(indxclass);
           gt.bbox=annot.bbox(indxclass,:);
           sprintf('iVideo: %02d , iClass: %02d',iVideo,iClass)
           
         %  gt.id=annot.id(indxclass);
         %  gt.label=annot.label(indxclass);
           
           %load detection
           %detection_file=sprintf('%s/P%02d-%02dNMS.mat',detection_dir,iVideo,iClass);
           detection_file=sprintf('%s/P%02d-%02d.mat',detection_dir,iVideo,iClass);
          % if(exist(detection_file,'file'))
          %      load(detection_file);
          % else
               outdir=detection_dir;
               detect=GV_detection_NMS(sprintf('%s/P%02d-%02d.mat',detection_dir,iVideo,iClass),outdir);
          % end
           target=zeros(length(detect.fr),1);
           st=1;
           thescore=zeros(length(detect.fr),1);
           for iGT=1:length(gt.fr)               
              framepos=find(gt.fr(iGT)==annot_frs);
              detectionsinframeind=(detect.fr==framepos(1));
              valindx=find(detectionsinframeind);
              nmsbbox=detect.bbox(detectionsinframeind,:);
              nmsscore=detect.score(detectionsinframeind,:);
              [nmsbbox, boxesindx]=esvm_nms(detect.bbox(detectionsinframeind,:) ,1);
             
              %nmsbbox=nmsbbox(boxesindx,:);              
              nmsscore=nmsscore(boxesindx,:);              
              list_overlapped=GV_isGTdetected(nmsbbox,gt.bbox(iGT,[2 1 4 3]));
              %list_overlapped=GV_isGTdetected(detect.bbox(detectionsinframeind,:),gt.bbox(iGT,:));
              [v, Intarget]=max(nmsscore(list_overlapped));
              indtemp=find(list_overlapped);    
              thescore(st:st+length(nmsscore)-1)=nmsscore;
              target(st+indtemp(Intarget)-1)=1;
              st=st+length(nmsscore);
              
           end
           thescore(st:end,:)=[];
           target(st:end,:)=[];
           if (length(gt.fr) > 0)
                [prec, tpr, fpr, thresh] = prec_rec(thescore, target);
                
                mAP=trapz([tpr(~isnan(prec))],[prec(~isnan(prec))])
                sprintf('Class: %s GT has %d BB, detection has %d ',classes{iClass},length(gt.fr),sum(target))
                prec_rec(thescore, target);
           end
        end
    end
end
