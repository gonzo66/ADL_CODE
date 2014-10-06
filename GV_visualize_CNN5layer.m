%Check the dense CNN
fname='000619'
pool_fname=sprintf('/home/gonzalo/Downloads/bing/BingObjectnessCVPR14/Objectness-master/Src/results/pool5/microwave-0000000900000001.bin' );
%pool_fname=sprintf('/home/gonzalo/Downloads/bing/BingObjectnessCVPR14/Objectness-master/Src/results/pool5/coffemaker-0000002900000001.bin' );
pool_fname='/home/gonzalo/Downloads/bing/BingObjectnessCVPR14/Objectness-master/Src/new_results/cup/675-707/cup1-1.bin'
pool_fname=['/home/gonzalo/WACV2015/new_results/P_01/' fname '.bin']
frame=['/home/gonzalo/WACV2015/ADL_frames/P_01/' fname '.jpg']


fid = fopen(pool_fname);
%pool5 = fread(fid, [256*20*21 1], 'single');
pool5 = fread(fid, [256*19*14 1], 'single');
fclose(fid);

% try1=reshape(pool5,[22 39 256]);
% representation=sum(try1,3);
% figure(3);
% imagesc(representation);
% axis equal
% axis off

%try2=reshape(pool5,[21 20 256]);
try2=reshape(pool5,[19 14 256]);
try2=permute(try2, [2 1 3]);
% normval=max(try2(:));
% for iChannel=1:256
%     imshow(try2(:,:,iChannel)/normval);
%     imagesc(try2(:,:,iChannel)/normval)
% end
representation2=sum(try2,3);
figure(4);
subplot(1,2,1);
imshow(imread(frame));
subplot(1,2,2);
imagesc(representation2);
imshow(representation2,[]);
axis equal
axis off