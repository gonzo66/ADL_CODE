
if(~exist('detection_dir','var'))
    detection_dir='/home/gonzalo/WACV2015/ADL_code/outs/'
end
if(~exist('annotation_dir','var'))
    annotation_dir='/home/gonzalo/WACV2015/ADL_annotations/object_annotation/'
end
load('allclasses2.mat');
annot3={}
for iiVideo=1:20
[annot annot_frs] = read_object_annotation(sprintf('%s/object_annot_P_%02d.txt',annotation_dir,iiVideo));
annot3=unique({annot3{:} annot.label{:}})
end