% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script read the object annotation 
% and create a folder with models for objects from 
% first 6 videos
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear
path0 = '/home/gonzalo/WACV2015/'; %% Dataset path

person_ids = [1:6];
%person_ids = [7:20];
vis_annotation = 1; %% set to 1 if you want to visualize the annottaions on the top of frames

path_video = [path0 'ADL_videos/'];
path_frames0 = [path0 'ADL_frames/'];
path_models = [path0 'ADL_models2/'];
if(~exist(path_models,'dir'))
   mkdir(path_models); 
  % mkdir([path_models '/passive/']);
  % mkdir([path_models '/active/']);
end

path1 = [path0 'ADL_annotations/action_annotation/'];     %% action annottaion
 if person_ids(end)<7
     path2 = [path0 'ADL_detected_objects/trainset/active/'];   %% detected active objects
     path3 = [path0 'ADL_detected_objects/trainset/passive/'];  %% detected passive objects    
  else
     path2 = [path0 'ADL_detected_objects/testset/active/'];   %% detected active objects
     path3 = [path0 'ADL_detected_objects/testset/passive/'];  %% detected passive objects
  end
% [best_s_active frs_active objects_active] = read_detected_objects(path2, person_ids);
% [best_s_passive frs_passive objects_passive] = read_detected_objects(path3, person_ids);

%%% list of detected objects
dirlistpass = dir(path2);
dirlistact = dir(path3);
dirlistpass(1:2) = [];
dirlistact(1:2) = [];

for i = 1:length(dirlistpass)
  objectspass{i} = dirlistpass(i).name;
  %mkdir([path_models '/passive/' objectspass{i} ]); 
end
for i = 1:length(dirlistact)
  objectsact{i} = dirlistact(i).name;
  %mkdir([path_models '/active/' objectsact{i}]); 
end


if vis_annotation
  path_annot = [path0 'ADL_annotations/object_annotation/'];
  path_frames_annotated0 = [path0 'ADL_annotations/frames_annotated/'];
end

for i = person_ids
  path_frames = [path_frames0 'P_' sprintf('%0.2d', i) '/'];  
  valid_annotations_file=[path_annot 'object_annot_P_' sprintf('%0.2d', i) '_annotated_frames.txt'];
  
%   for j = 1:length(objectspass)
%     fname = [path2 objectspass{j} '/' 'P_' sprintf('%0.2d', i) '.mat'];
%     clear boxes frs
%     detectedpass{j}=load(fname);    
%   end
%   
%   for j = 1:length(objectsact)
%     fname = [path3 objectsact{j} '/' 'P_' sprintf('%0.2d', i) '.mat'];
%     clear boxes frs
%     detectedact{j}=load(fname);    
%   end
  
  path_frames_annotated = [path_frames_annotated0 'P_' sprintf('%0.2d', i) '/'];
  fname_annot = [path_annot 'object_annot_P_' sprintf('%0.2d', i) '.txt'];

  list_frames=dir([path_frames '*.jpg']);
  [annot annot_frs] = read_object_annotation(fname_annot);
  objlist=unique(annot.label);
  for iTemp=1:length(objlist)
    dirtemp=sprintf('%s/%s/',path_models,objlist{iTemp})
    if(~exist(dirtemp,'dir'))
        mkdir(dirtemp);
    end
  end
  
  iName=0;
  for fr = annot_frs
    im1 = imread([path_frames sprintf('%0.6d.jpg', fr+1)]); %%% +1 since frame in annotation starts from 0.
    im1= imresize(im1,0.5);
    f1 = find(annot.fr == fr);
    if ~isempty(f1)
        bbox = annot.bbox(f1, :);
        bbox_id = annot.id(f1) + 1; %% +1 since id
        bbox_label=annot.label(f1);
    end
    
   % imshow(im1);
   % hold on;
    for iDet=1:length(bbox_id)
        %rectangle('Position',[bbox(iDet,1),bbox(iDet,2),(bbox(iDet,3)-bbox(iDet,1)),( bbox(iDet,4)-bbox(iDet,2))])
        m1=im1(max(bbox(iDet,2),1):min(bbox(iDet,4),size(im1,1)),max(bbox(iDet,1),1):min(bbox(iDet,3),size(im1,2)),:);
       % imshow(m1)
        iName=iName+1;
        if(iName==18)
           pause(1); 
        end
     
        imwrite(m1,sprintf('%s/%s/%08d.png',path_models,bbox_label{iDet},iName)); 
        
        %imshow(m1)
        
    end
      
  end
end



