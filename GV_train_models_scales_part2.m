
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to train models in different sizes and aspect ratios 
% from the available trainig models organized in a tree structure
% Class X -> sizes -> sample images
% Author: Gonzalo Vaca-castano
% Date: Aug 26 2014
% Bosch CR/RTC 3 NorthAmerica
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [models, sizes]=GV_train_models_scales_part2(obj_id, descriptor_folder, negative_folder)

if (~exist('descriptor_folder','var'))
    descriptor_folder='/home/gonzalo/WACV2015/ADL_newmodelsCNNreduced/';
end
if (~exist('negative_folder','var'))
    negative_folder='/home/gonzalo/WACV2015/negatives/P_01/';
end
workdir='/home/gonzalo/WACV2015/ADL_code/';

if(~isnumeric(obj_id))
   obj_id=str2num(obj_id); 
end


 load(sprintf('%s/allclasses.mat',workdir));
descriptor_folder=[descriptor_folder '/' classes{obj_id} '/']
load(sprintf('%s/positives%02d.mat',workdir,obj_id )); 
load(sprintf('%s/allsizeslist.mat',workdir));
 load(sprintf('%s/modelsinsizes.mat',workdir));

 % Load negatives for each size and train different models for each size
models=cell(length(full_sizes2),1);
for iSize=1:length(full_sizes2)   % for all available sizes !
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
          negtemp=load(sprintf('%s/positives%02d.mat',workdir, othermodels(iOthers) ));         
          neg_data1=[neg_data1;negtemp.descriptors{iSize}.desc];
       end
       neg_data=[neg_data1;negatives];       
       traindata=sparse([double(pos_data);double(neg_data)]);
       trainlabels=[ones(size(pos_data,1),1) ; -ones(size(neg_data,1),1)];
       models{iSize} = train(trainlabels,(traindata));
    end
    save(sprintf('%s/models%02d.mat',workdir,obj_id ),'models');
end
save(sprintf('%s/models%02d.mat',workdir,obj_id ),'models');

end