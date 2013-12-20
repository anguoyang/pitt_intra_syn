function Expedition_pittpatt_intrface_dir(dir_path,save_flag,startid,clip_length)
%Expedition_pittpatt_intrface_dir - given a folder than contains image files, compute face-location
%using pittpatt and face lanmarks, face orientation using intraface. Save
%data to the folder video file located at with the same name as videofile_mat,
%if save_flag indicated, save images to the folder "videofile"
%
% Syntax:   Expedition_pittpatt_intrface_dir(video_file,save_flag,startid,clip_length)
%
% Inputs:
%    dir_name  - path of video to be processed
%    save_flag   - save visualization or not Default: 0
%    startid     - start frame number of video. Provided by function
%    synchronizeAudio Default: 1
%    clip_length - number of frames to process. Provided by function
%    synchronizeAudio Default: all the frames in audio
%
%
%
% Other m-files required: FaceDetectPittPattWindows.m xx_initialize.m,
%                         xx_initialize2.m 
%


% Author: Zijun Wei     Research Associate 
% Robotics Institute    Carnegie Mellon University
% email address: hzwzijun@gmail.com 
% Website:  http://zijunwei.com/
% December 2013; Last revision: 

%------------- BEGIN CODE --------------


if nargin<2
   save_flag=0; 
end
if nargin<3
   startid=1; 
end
if nargin<4
   clip_length=100000000000000; 
end
if ~exist(dir_path,'dir')
   error('Directory does not exist, please check');
end
[video_folder, dir_name, ~]=fileparts(dir_path);
img_save_folder=fullfile(video_folder,[dir_name,'_img']);
mat_save_folder=fullfile(video_folder,[dir_name,'_mat']);
if ~exist(img_save_folder,'dir')
   mkdir(img_save_folder);
end
if ~exist(mat_save_folder,'dir')
   mkdir(mat_save_folder); 
end

continueID_rectinfo=getContinueID(fullfile(mat_save_folder,'*_rect_info.mat'));
continueID_lminfo=getContinueID(fullfile(mat_save_folder,'*_lm_info.mat'));
if continueID_lminfo~=0 && continueID_rectinfo~=0
continue_imgID=getFrameIDFromMat(mat_save_folder,continueID_rectinfo,continueID_lminfo);
else
    continueID_lminfo=0;
    continueID_rectinfo=0;
    continue_imgID=0;
end


mean_height_pittpatt=176.3637;
mean_width_pittpatt=141.0943;
img_suffix='.png';
[DM,TM,option] = xx_initialize;

% videoObj=VideoReader(video_file);
img_files=dir(dir_path);
img_files=img_files(not([img_files.isdir]));
nFrames=length(img_files);
% vidHeight=videoObj.Height;
% vidWidth=videoObj.Width;



idx_bb=continueID_rectinfo+1;
idx_lm=continueID_lminfo+1;
% rects_info=[];
temp_lm=[];
if save_flag==1
figure;
set(gcf,'visible','off');
end
%%
% if offset >0, it means that video 
loop_length=min(nFrames-startid+1,clip_length);
    
 for i=continue_imgID+1:1:loop_length;
     fprintf('Computing %d th img of %d...\n',i,loop_length);
     tmp_img_name='temp.png';
%      temp_img=read(videoObj,i);
    temp_img=imread(fullfile( dir_path,img_files(i).name));

if isempty(temp_img)
%   temp_img=zeros(vidHeight,vidWidth,3);
end

imwrite(temp_img,fullfile(pwd,tmp_img_name));
result_pitt=[];

result_pitt=FaceDetectPittPattWindows(fullfile(pwd,tmp_img_name),pwd);
if save_flag==1
imshow(temp_img);
end
if ~isempty(result_pitt)
     
    for numl=1:1: length(result_pitt)

        
        pittpatt_rect= round([result_pitt(numl).x1 result_pitt(numl).y1 result_pitt(numl).w result_pitt(numl).h]);
        pittpatt_ang=[result_pitt(numl).yaw result_pitt(numl).pitch result_pitt(numl).rot];
        pittpatt_rect= pittpatt_rect- ceil([-(1.0668*pittpatt_ang(1)+10.3149)*  pittpatt_rect(3)/mean_width_pittpatt,...
            -35.1369 *pittpatt_rect(4)/mean_height_pittpatt, ...
            ((1.0668*pittpatt_ang(1)+10.3149+ (-1.2393)*pittpatt_ang(1) +9.5758)*pittpatt_rect(3)/mean_width_pittpatt),...
            ((19.2323+35.1369)*pittpatt_rect(4)/mean_height_pittpatt)]);
        
        
        
        if sum(pittpatt_rect>0)==4 
            temp_mat=[];
            temp_mat.imgname=img_files(i).name;
            temp_mat.frameid=i;
            temp_mat.rectinfo=result_pitt(numl);
            temp_mat.correctified_rect=pittpatt_rect;
            save(fullfile( mat_save_folder,sprintf('%.05d_rect_info.mat',idx_bb)),'temp_mat');
            idx_bb=idx_bb+1;
            [pred,pose] = xx_track_detect2(DM,TM,temp_img,pittpatt_rect,option);
            % draw rectangle on image to show results of pittpatt
            if(save_flag==1)
               hold on;
               rectangle('position',int32(pittpatt_rect),'edgecolor','w');
               rectangle('position',int32(pittpatt_rect+[1,1,0,0]),'edgecolor','k');
            end
            if ~isempty(pred)
                
                temp_lm=[];
                temp_lm.imgname=img_files(i).name;
                temp_lm.frameid=i;
                temp_lm.pred=pred;
                temp_lm.pose=pose;
                save(fullfile( mat_save_folder,sprintf('%.05d_lm_info.mat',idx_lm)),'temp_lm');
                 idx_lm=idx_lm+1;
                % draw landmarks on iamge to show results of pittpatt
                if(save_flag==1)
                 Pts = int32(pred);
                 plot(Pts(:,1),Pts(:,2),'b.');
                end
            end
        end
        
    end
end
if(save_flag==1)
 im=export_fig();
 imwrite(im,fullfile(img_save_folder,img_files(i).name));
hold off;
end

  end


%  save([video_name,'.mat'],'rects_info','landmarks_info');

end
%------------- BEGIN CODE --------------