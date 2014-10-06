% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to read the raw data for a detection of video , 
% convert to pixels coordinates, performs and NMS, and save it
% in same format as anotations (mat file using same structure).
% File is saved in folder 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - Inputs 
% detection_file: location of detection file 
% outdir: output directory for the file
% - Outputs: annotation file
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Gonzalo Vaca-castano
% Date: July 29 2014
% Bosch CR/RTC 3 NorthAmerica
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function detect=GV_detection_NMS(detection_file,outdir)
    load(detection_file);   %load data from a video for a particular object.
    %detections=[frame x1(CNN units), y1(CNN units) dx(CNN units), dy(CNN units) obj_id tscores];
    scale=0:32:800; %for init position of Bounding box
    scalesize=67+scale;
    detections=[detections(:,1) scale(detections(:,2))' scale(detections(:,3))' scale(detections(:,2))'+scalesize(detections(:,4))' scale(detections(:,3))'+scalesize(detections(:,5))' detections(:,6) detections(:,7)];
    frames=unique(detections(:,1));
    startind=1;
%     detect.fr=zeros(size(detections,1),1);
%     detect.bbox=zeros(size(detections,1),4);
%     detect.score=zeros(size(detections,1),1);
%     detect.labelid=zeros(size(detections,1),1);
    detect.fr=detections(:,1);
    detect.bbox=detections(:,2:5);
    detect.score=detections(:,7);
    detect.labelid=detections(:,6);
%     for i=1:length(frames)        
%         boxes=detections(detections(:,1)==frames(i),:);
%         %boxestmp=esvm_nms(boxes(:,2:end), 1);
%         boxestmp=boxes(:,2:end);
%         endind = startind+size(boxestmp,1)-1;
%         detect.fr(startind:endind, 1) = frames(i);
%         detect.bbox(startind:endind, 1:4)  = boxestmp(:,1:4);
%         detect.score(startind:endind, 1) = boxestmp(:,6);
%         %annot.id(k, 1)      = str2num(txt1(1:6));
%         detect.labelid(startind:endind, 1)=boxestmp(:,5);
%         %annot.label{startind:endind, 1}   = txt1(35:end);       
%         startind=endind+1;
%     end
%     detect.fr(startind:end,:)=[];
%     detect.bbox(startind:end,:)=[];
%     detect.score(startind:end,:)=[];
%     detect.labelid(startind:end,:)=[];
    load('allclasses3.mat');
%    detect.label   = {classes{detect.labelid}};
    [path, filename, ext]=fileparts(detection_file);
    if(~exist(outdir,'dir'))
        mkdir(outdir);
    end
    save(sprintf('%s/%sNMS.mat',outdir,filename),'detect');
    
end