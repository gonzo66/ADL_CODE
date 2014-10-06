% do SVM training direct from the image descriptor !!
feat_dir='/home/gonzalo/WACV2015/new_results/'
load('sceneannotations3.mat')

% load training data
numclasses=8;
desc_dim=256*14*19;

for iT=1:6
   train_files=dir(sprintf('%s/P_%02d/*',feat_dir,iT));
   train_files(1:2)=[];
   traindata{iT}=zeros(length(train_files),desc_dim);
   labeldata{iT}=-ones(length(train_files),1);
   for iFile=1:length(train_files)
       fc6_fname=sprintf('%s/P_%02d/%s',feat_dir,iT,train_files(iFile).name);
       fid = fopen(fc6_fname);
       fc6tmp =fread(fid, [1 desc_dim], 'single');
       fclose(fid);
       traindata{iT}(iFile,:)=fc6tmp;
       labelval=P{iT}(P{iT}(:,1)<=iFile &  P{iT}(:,2)>=iFile,3);
       if length(labelval)==1
        labeldata{iT}(iFile)=labelval;
       else
          % pause(0.001);
       end
   end    
end
traindata=cat(1,traindata{:});
labeldata=cat(1,labeldata{:})

model = train(labeldata,sparse(traindata),' -c 1.5 ');
save('scene_simplemodel3.mat','model');
