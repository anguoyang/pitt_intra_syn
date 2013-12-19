function  visualizePercepts_Pittpatt( video_path1,video_path2,percepts_file,offset_file )
%VISUALIZEPERCEPTS_PITTPATT Given two videos and percepts data, draw
%information on images 
% Attention: make sure the order of  video_path1, video_path2 should be the
% same as the order input at synchronizeVideo function


videoObj1=VideoReader(video_path1);
videoObj2=VideoReader(video_path2);

FPS=videoObj1.FrameRate;
offset_data=load(offset_file);
percepts_data=load(percepts_file);

v1_startid=offset_data.v1_startid;
v2_startid=offset_data.v2_startid;
clip_length=offset_data.clip_length;
percepts=percepts_data.percepts;
if length(percepts)<6
  error('percepts not complete')
end
videow=VideoWriter('temp.avi');
videow.FrameRate=30;
videow.open;
% convert cell to struct arrays

for i=1:1:length(percepts)
    
   percepts_array(i)=percepts{i}; 
end


figure;
 set(gcf,'Visible','off');
idx_ch_face=1;
idx_ex_face=1;
idx_ch_lm=1;
idx_ex_lm=1;

for i=1:1:clip_length
    im1=videoObj1.read(v1_startid+i-1);
    imshow(im1);
    singlePercept_ch_loc=findSinglePerceptbyDescription(percepts_array,'child_face_location_detection');
    singlePercept_ch_lm=findSinglePerceptbyDescription(percepts_array,'child_face_landmarks');
    [~,idx_ch_face] =drawonlc(im1,v1_startid+i-1,singlePercept_ch_loc,idx_ch_face,FPS);
    [~,idx_ch_lm]=drawonlm(im1,v1_startid+i-1,singlePercept_ch_lm,idx_ch_lm,FPS);
    im1=export_fig();
    
    im2=videoObj2.read(v2_startid+i-1);
    imshow(im2);
    singlePercept_ex_loc=findSinglePerceptbyDescription(percepts_array,'examiner_face_location_detection');
    singlePercept_ex_lm=findSinglePerceptbyDescription(percepts_array,'examiner_face_landmarks');
    [~,idx_ex_face] =drawonlc(im1,v1_startid+i-1,singlePercept_ch_loc,idx_ex_face,FPS);
    [~,idx_ex_lm]=drawonlm(im1,v1_startid+i-1,singlePercept_ch_lm,idx_ex_lm,FPS);
    im2=export_fig();
    im=ImgSyn(im1,im2,'h');
    videow.writeVideo(im);
    
    
end
videow.close;
close all;



end
function [im,idx]=drawonlc(im,im_idx,singlePercept,idx,FPS)
hold on;
while  im_idx>(mms2frame(singlePercept.events{idx}.starttime,FPS))
    idx=idx+1;
end
while  im_idx==(mms2frame(singlePercept.events{idx}.starttime,FPS))
rectangle('position',singlePercept.events{idx}.value,'edgecolor','r');    
idx=idx+1;
end

end

function [im,idx]=drawonlm(im,im_idx,singlePercept,idx,FPS)

while im_idx>(mms2frame(singlePercept.events{idx}.starttime,FPS))
    idx=idx+1;
end

while  im_idx==(mms2frame(singlePercept.events{idx}.starttime,FPS))
pts=int32(singlePercept.events{idx}.value);
plot(pts(:,1),pts(:,2),'b.');
idx=idx+1;
end
hold off;
end

function frameid=mms2frame(mms,FPS)
frameid=ceil(mms*FPS)+1;

end

function singlePercept=  findSinglePerceptbyDescription(percepts_array,descripStr)
idx= strcmp({percepts_array.name},descripStr);
    singlePercept=percepts_array(idx);

end