% do SVM training direct from the image descriptor !!
feat_dir='/home/gonzalo/WACV2015/new_results/'
load('sceneannotations3.mat')

% load testing data
numclasses=8;
desc_dim=256*14*19;
load('scene_simplemodel3.mat');

for iT=7:20
   test_files=dir(sprintf('%s/P_%02d/*',feat_dir,iT));
   test_files(1:2)=[];
   testdata{iT}=zeros(length(test_files),desc_dim);
   labeldata{iT}=-ones(length(test_files),1);
   for iFile=1:length(test_files)
       fc6_fname=sprintf('%s/P_%02d/%s',feat_dir,iT,test_files(iFile).name);
       fid = fopen(fc6_fname);
       fc6tmp =fread(fid, [1 desc_dim], 'single');
       fclose(fid);
       testdata{iT}(iFile,:)=fc6tmp;
       labelval=P{iT}(P{iT}(:,1)<=iFile &  P{iT}(:,2)>=iFile,3);
       if length(labelval)==1
        labeldata{iT}(iFile)=labelval;
       else
          % pause(0.001);
       end
   end  
   [a{iT-6},b{iT-6},c{iT-6}]=predict(labeldata{iT},sparse(testdata{iT}),model,'-b 1');
end
save('scene_detections_CNN5-3.mat','a','b','c','labeldata');
%testdata=cat(1,testdata{:});
%labeldata=cat(1,labeldata{:});


%model = svmtrain(trainlabels,testdata,' -c 1.5 ');
%predict(model,testdata);