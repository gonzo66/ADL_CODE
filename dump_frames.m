clear
path0 = '/home/gonzalo/WACV2015/'; %% Dataset path

person_ids = [1:20];
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
  if vis_annotation
    path_frames_annotated = [path_frames_annotated0 'P_' sprintf('%0.2d', i) '/'];
    fname_annot = [path_annot 'object_annot_P_' sprintf('%0.2d', i) '.txt'];
    visualize_object_annotation_on_frames(path_frames, fname_annot, path_frames_annotated);
  end
end



