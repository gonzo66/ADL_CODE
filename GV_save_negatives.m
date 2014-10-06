% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Auxiliar function to  save the descriptors of the negatives for different
% sizes in memory
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
% Date: Aug 25 2014
% Bosch CR/RTC 3 NorthAmerica
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [models, sizes]=GV_save_negatives(negative_folder,outfolder,cnn_sizes)
    subfold='P_01';
if (~exist('cnn_sizes','var'))
    %cnn_sizes=[3,3;3,4;3,5;3,11;3,2;4,3;4,4;4,5;4,6;4,7;4,14;4,2;5,4;5,5;5,6;5,7;5,8;5,9;5,17;6,3;6,4;6,5;6,6;6,7;6,8;6,10;6,11;6,21;7,5;7,6;7,7;7,8;7,9;7,10;7,12;7,13;7,24;8,4;8,7;8,8;8,9;8,10;8,11;8,13;8,14;8,28;9,5;9,7;9,8;9,9;9,10;9,11;9,12;9,13;9,15;9,16;9,30;10,5;10,7;10,8;10,9;10,10;10,11;10,13;10,14;10,17;10,18;11,6;11,8;11,10;11,11;11,12;11,13;11,14;11,15;11,16;11,18;11,19;11,20;12,6;12,10;12,11;12,12;12,13;12,14;12,15;12,16;12,17;12,20;13,7;13,9;13,11;13,12;13,13;13,14;13,15;13,16;13,17;13,18;13,22;13,23;14,7;14,10;14,11;14,12;14,13;14,14;14,15;14,16;14,19;14,20;14,23;14,24;14,25;15,8;15,12;15,13;15,14;15,15;15,16;15,17;15,19;15,20;15,25;15,26;15,27;16,8;16,11;16,14;16,15;16,16;16,17;16,18;16,20;16,21;16,22;16,23;16,27;16,29;17,9;17,12;17,15;17,16;17,17;17,18;17,19;17,20;17,21;17,23;17,24;17,28;17,29;18,9;18,13;18,14;18,15;18,16;18,17;18,18;18,19;18,20;18,21;18,22;18,24;18,26;18,30;19,10;19,15;19,16;19,17;19,18;19,19;19,20;19,21;19,22;19,24;19,25;19,26;19,27;1,4;1,1;1,2;20,10;20,14;20,16;20,17;20,18;20,19;20,20;20,21;20,22;20,23;20,25;21,11;21,15;21,18;21,19;21,21;21,22;21,23;21,24;21,26;21,28;21,29;21,30;2,3;2,4;2,7;2,1;2,2;];
    load('allsizeslist.mat')
end
if (~exist('outfolder','var'))
    outfolder=['/home/gonzalo/WACV2015/negatives/' subfold '/'];
    mkdir(outfolder);
end
if (~exist('negative_folder','var'))

    negative_folder='/home/gonzalo/WACV2015/new_results/';
    negative_folder=[negative_folder subfold '/'];
end

fname_annot = [ '/home/gonzalo/WACV2015/ADL_annotations/object_annotation/'  'object_annot_' subfold '.txt'];
[annot annot_frs] = read_object_annotation(fname_annot);

%% Find negatives
% Negatives images are assumed to be longer that 995 which is the biggest
% available model. in our case negatives are 768*1024
sizedesc=14*19*256*4;
%negatives=cell(length(sizes),1);

negfilelist=dir([negative_folder '*.bin']);
for iSizes=1:size(cnn_sizes2,1)
    negatives=[];
    %for iNeg=1:length(negfilelist)
    iNeg=0;
    for fr = annot_frs
        neg_fname=sprintf('%s%06d.bin', negative_folder,fr+1);
        fid = fopen(neg_fname);
        if(fid <0)
           continue; 
        end
        tempdescs = fread(fid,[1 sizedesc] , 'single');
        fclose(fid);


        f1 = find(annot.fr == fr);
        step=2;
        if(min(cnn_sizes2(iSizes,:))< 10)
           step=3; 
        end
        
        if isempty(f1)
            outdesc= GV_getsubfeature(single(tempdescs),[14 19], cnn_sizes2(iSizes,:),step);
        else
            mask=ones(14,19);
            bbox = annot.bbox(f1, :);
            bbox=bbox/32;
            bbox(:,1:2)=max(ceil(bbox(:,1:2)),1);
            bbox(:,3:4)=max(floor(bbox(:,3:4)),bbox(:,1:2));
            for iTemp=1:size(bbox,1)
                mask(bbox(iTemp,2):bbox(iTemp,4),bbox(iTemp,1):bbox(iTemp,3))=0;
            end
            outdesc= GV_getsubfeature2(single(tempdescs),[14 19], cnn_sizes2(iSizes,:),step,mask);
        end
        iNeg=iNeg+1;
        if (iNeg==1)
            negatives=outdesc;
        else
            negatives =[negatives ; outdesc];
        end
    end
    save(sprintf('%sneg-%03d',outfolder,iSizes) ,'negatives','-v7.3');
end

end