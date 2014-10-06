% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to train models in different sizes and aspect ratios 
% from the available trainig models organized in a tree structure
% Class X -> sizes -> sample images
% Author: Gonzalo Vaca-castano
% Date: Aug 26 2014
% Bosch CR/RTC 3 NorthAmerica
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [models, sizes]=GV_train_models_scales(obj_id, descriptor_folder, negative_folder)

if (~exist('descriptor_folder','var'))
    descriptor_folder='/home/gonzalo/WACV2015/ADL_newmodelsCNNreduced/';
end
if (~exist('negative_folder','var'))
    negative_folder='/home/gonzalo/WACV2015/negatives/P_01/';
end
workdir='/home/gonzalo/WACV2015/';

if(~isnumeric(obj_id))
   obj_id=str2num(obj_id); 
end

 maxheight=480;
 

%% Finding classes and available sizes from the training data
if (~exist(sprintf('%s/positives%02d.mat',workdir,obj_id ),'file'))
    load(sprintf('%s/allclasses.mat',workdir));

    %% Load all the data of positives in memory
    descriptors=cell(length(full_sizes2),1);
    cnn_sizes=[];
    for iSizes=1:length(full_sizes2)
        %get image and descriptor dimensions
        sizestr=full_sizes2{iSizes};
        cnn_coord=cnn_sizes2(iSizes,:);
        desc_dim=256*cnn_coord(1)*cnn_coord(2);
        
        descriptors{iSizes}.classes=[];

 %       for iClass=1:length(classes)
            the_dir=[descriptor_folder '/' sizestr];
            if(~exist(the_dir,'dir'))
                continue;
            end
            descriptors{iSizes}.classes=[descriptors{iSizes}.classes obj_id];   %classes availables for the particular scale
            sizeslist=dir([the_dir '/*']);
            sizeslist(1:2)=[];
            descs=zeros(length(sizeslist),desc_dim);
            for iSample=1:length(sizeslist)
                pool_fname=sprintf('%s/%s', the_dir,sizeslist(iSample).name);
                fid = fopen(pool_fname);
                descs(iSample,:) = fread(fid,[1 desc_dim] , 'single');
                fclose(fid);            
            end
            descriptors{iSizes}.desc=descs;
%        end
    end
    save(sprintf('%s/positives%02d.mat',workdir,obj_id ),'descriptors','-v7.3');
else
    load(sprintf('%s/positives%02d.mat',workdir,obj_id ));    
end

 load(sprintf('%s/modelsinsizes.mat',workdir));
% Load negatives for each size and train different models for each size
models=cell(length(sizes),1);
for iSize=1:length(sizes)   % for all available sizes !
    models{iSize}.valids=descriptors{iSize}.classes;
    %load negatives
    load(sprintf('%s/neg-%03d',negative_folder,iSize));
    for iModels=1:length(models{iSize}.valids)
       currentmodel=models{iSize}.valids(iModels);
       othermodels=modelsinsizes{iSize};
       othermodels(iModels)=[];
       %Buil SVM data
       pos_data=descriptors{iSize}.desc;
       neg_data1=[];
       for iOthers=1:length(othermodels)
          neg_data1=[neg_data1;descriptors{iSize}.models{othermodels(iOthers)}];
       end
       neg_data=[neg_data1;negatives];       
       traindata=sparse([double(pos_data);double(neg_data)]);
       trainlabels=[ones(size(pos_data,1),1) ; -ones(size(neg_data,1),1)];
       models{iSize}.model{currentmodel} = train(trainlabels,(traindata));
    end
    %save('models.mat','models');
end

save('models.mat','models','cnn_sizes');

end