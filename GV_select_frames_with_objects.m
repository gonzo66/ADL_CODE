% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script obtain all the frames from the video,
% and erase all the frames where there is no object annotation.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear
path0 = '/home/gonzalo/WACV2015/'; %% Dataset path

person_ids = [6:20];
vis_annotation = 1; %% set to 1 if you want to visualize the annottaions on the top of frames

path_video = [path0 'ADL_videos/'];
path_frames0 = [path0 'ADL_frames/'];

if vis_annotation
  path_annot = [path0 'ADL_annotations/object_annotation/'];
  path_frames_annotated0 = [path0 'ADL_annotations/frames_annotated/'];
end

for i = person_ids
  path_frames = [path_frames0 'P_' sprintf('%0.2d', i) '/'];
  if (~exist(path_frames,'dir'))
    video2frames([path_video 'P_' sprintf('%0.2d', i) '.MP4'], path_frames);
  end
  valid_annotations_file=[path_annot 'object_annot_P_' sprintf('%0.2d', i) '_annotated_frames.txt'];

  fid = fopen(valid_annotations_file);
  valid_annotations = fscanf(fid, '%d', [1 inf]);
  fclose(fid);
  
  list_frames=dir([path_frames '*.jpg']);
  to_remove=1:max(length(list_frames)+1);
  to_remove(valid_annotations+1)=[];
  for iFile=1:length(to_remove)
     unix(sprintf('rm %s%06d.jpg',path_frames, to_remove(iFile))); 
  end
  
end



