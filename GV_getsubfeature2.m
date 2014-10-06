% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Auxiliar function to give the descriptor of an image subser 
% given a full size descriptor and the offset.
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - Inputs 
% desc: raw descriptor full image
% imsize: [height width ] of the descriptor . 256 channels are assumed
% sizes: [ heightNew widthNew] contains sizes of the bounding box descriptors
% start: Nx2 matrix where each row [ startX startY] contains start coordinates of the bounding box 
% - Outputs
% outdesc: N x descsize descriptors of the required BB
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Gonzalo Vaca-castano
% Date: July 29 2014
% Bosch CR/RTC 3 NorthAmerica
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [outdesc ,start]= GV_getsubfeature2(desc,imsize,sizes,start,mask)
    %Convert the descriptor in a cube
    desc=reshape(desc,[imsize(2) imsize(1) 256]);   %now is a cube 
    %desc=permute(desc,[2 1 3]); %now it is permuted
    if(~exist('start','var'))  % offset is 1
       start=1; 
    end
    if(size(start,1)==1 && size(start,2)==1)  % it is an offset not start coordinates
        startH=1:start:(imsize(1)-sizes(1)+1);
        startW=1:start:(imsize(2)-sizes(2)+1);
        Hlen=length(startH);
        startH=repmat(startH,length(startW),1);
        startH=startH(:);
        startW=repmat(startW,1,Hlen);
        startW=startW(:);
        start=[startH,startW];
    end
    N=size(start,1);
    outdesc=single(zeros(N,prod(sizes)*256));
    valids=0;
    for iBB=1:N
        %iBB
       overlap=sum(sum(mask(start(iBB,1):(start(iBB,1)+sizes(1)-1),start(iBB,2):(start(iBB,2)+sizes(2)-1)))); 
       if(overlap>(prod(sizes)*0.6))
            tempdesc=desc(start(iBB,2):(start(iBB,2)+sizes(2)-1),start(iBB,1):(start(iBB,1)+sizes(1)-1),:);
     %  tempdesc=permute(tempdesc,[2 1 3]); %now it is permuted
            valids=valids+1;
            outdesc(valids,:)=tempdesc(:);            
       end
    end
    if(valids==0)
        outdesc=[];
    else
        outdesc=outdesc(1:valids,:);
    end
end