% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to determine which bounding boxes fits the pascal criteria 
% for detection (area intersection/area union) > 0.5
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - Inputs 
% detectedBB = BB detection 
% gtBB: annotation for the searched BB
% overlap : criteria for selection (default:0.5)
% - Outputs: annotation file
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Gonzalo Vaca-castano
% Date: July 29 2014
% Bosch CR/RTC 3 NorthAmerica
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [listvalid,scores2]=GV_isGTdetected(detectedBB,gtBB,overlap)
    if(~exist('overlap','var'))
       overlap=0.5; 
    end
    Pax= max(detectedBB(:,1),gtBB(1));
    Pay= max(detectedBB(:,2),gtBB(2));
    Pcx= min(detectedBB(:,3),gtBB(3));
    Pcy= min(detectedBB(:,4),gtBB(4));
    intersection=(Pcy-Pay).*(Pcx-Pax);
    
    areagt=(gtBB(4)-gtBB(2))*(gtBB(3)-gtBB(1));
    areasBB=(detectedBB(:,4) - detectedBB(:,2)).*(detectedBB(:,3) - detectedBB(:,1));
    areas=areasBB+areagt-intersection;    
    scores2=(intersection./areas);
    scores2((Pcy-Pay)<0 | (Pcx-Pax)<0)=0;
    listvalid = ((intersection./areas) > overlap);   
    listvalid=listvalid & (Pcy-Pay)>0 & (Pcx-Pax)>0;
end