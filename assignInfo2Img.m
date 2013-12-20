% function  assignInfo2Img( img_save_folder )
%ASSIGNINFO2IMG assign all percepts into each image.

mat_save_folder=strcat( img_save_folder,'_mat');
g_img_save_folder=strcat( img_save_folder,'_img');
rect_files=getFilesinFolder(fullfile(mat_save_folder,'*_rect_info.mat'));
lm_files=getFilesinFolder(fullfile(mat_save_folder,'*_lm_info.mat'));
img_files=getFilesinFolder(g_img_save_folder);
idx_rect_info=1;
idx_lm_info=1;
load( fullfile( mat_save_folder, rect_files(idx_rect_info).name));
for i=1:1:length(img_files)
      
      
      face_info=[];
      inner_idx=1;
      while strcmp(temp_mat.imgname,img_files(i).name)
          single_face_info=[];
          single_face_info.yaw=temp_mat.rectinfo.yaw;
          single_face_info.pitch=temp_mat.rectinfo.pitch;
          single_face_info.rot=temp_mat.rectinfo.rot;
          single_face_info.confidence=temp_mat.rectinfo.confidence;
          single_face_info.rectangle=temp_mat.correctified_rect;
          load( fullfile(mat_save_folder,lm_files(idx_lm_info).name));
          while  strcmp(temp_lm.imgname,img_files(i).name)
              single_face_info.lm=temp_lm.pred;
              idx_lm_info=idx_lm_info+1;
              if idx_lm_info<=length(lm_files)
               load( fullfile(mat_save_folder,lm_files(idx_lm_info).name));
              else
                  break;
              end
          end
          face_info{inner_idx}=single_face_info;
          inner_idx=inner_idx+1;
          idx_rect_info=idx_rect_info+1;
          if idx_rect_info<=length(rect_files)
          load( fullfile( mat_save_folder, rect_files(idx_rect_info).name));
          else
          break;
          end
      end
       if  ~ isempty(face_info)
%           face_info.name=img_files(i).name;
          [~,file_name,~]=fileparts(img_files(i).name);
          file_name=strcat(file_name,'.mat');
          save(fullfile( g_img_save_folder,file_name),'face_info');
      end
     
      
    
    
end

% end

