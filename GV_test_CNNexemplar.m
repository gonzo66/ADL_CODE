% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to test the results of CNN exemplar SVM
% in different sizes
% Author: Gonzalo Vaca-castano
% Date: July 28 2014
% Bosch CR/RTC 3 NorthAmerica
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function GV_test_CNNexemplar(obj_id,bin_folder)
%list of videos to run
if(~exist('bin_folder','var'))
    bin_folder='/home/gonzalo/WACV2015/new_results/';
end
models_dir='/home/gonzalo/WACV2015/ADL_code/';
outdir=sprintf('%s/outs/',models_dir);

if(~exist(outdir,'dir'))
    mkdir(outdir);
end

if(~isnumeric(obj_id))
    obj_id=str2num(obj_id);
end

%load the models trained in different scales for that object
load(sprintf('%s/models%02d.mat',models_dir,obj_id));

%load all sizes
load(sprintf('%s/allsizeslist.mat',models_dir));

% test images are assumed to be 640*480
%sizepix=[480 640];
sizecnn=[14 19];
sizedesc=prod(sizecnn)*256*4;

% Get frame by frame
for iVideo=1:20
    flist=dir(sprintf('%s/P_%02d/*.bin',bin_folder,iVideo));
     detections=[];
    for iFlist=1:length(flist)
        fname=sprintf('%s/P_%02d/%s', bin_folder, iVideo ,flist(iFlist).name);
        fid = fopen(fname);
        tempdescs = fread(fid,[1 sizedesc] , 'single');
        fclose(fid);
        
       
        for iSize=1:size(cnn_sizes2,1)
            if(isfield(models{iSize}, 'w'))	%the size has a valid model
                [outdesc, starts]= GV_getsubfeature(single(tempdescs),sizecnn, cnn_sizes2(iSize,:),1);
                %test the valid models
                %for iValid=1:length(models{iSize}.valids)
                tempscores=outdesc*transpose(models{iSize}.w);
                candidates=find(tempscores>-5);
                numcandidates=length(candidates);
                if(numcandidates>0)
                    detections=[detections;repmat(iFlist,numcandidates,1) starts(candidates,:) repmat(cnn_sizes2(iSize,:),numcandidates,1) repmat(obj_id,numcandidates,1) tempscores(candidates)];
                end
                %end
            end
            %   impath=[img_folder '\' flist(iFlist).name(1:end-4) '.jpg'];            
            %GV_visualize_detections(impath,detections,classes);
            %  pause(0.001);
        end
    end
    sprintf(['Saving video: ' num2str(iVideo)])
    %flist(iFlist).name(1:end-4)
    save(sprintf('%s/P%02d-%02d.mat',outdir,iVideo,obj_id) , 'detections');
    
end
end
