function s_files = getFilesinFolder( file_type )
%GETFILESINFOLDER get a list of files that satisfy specific file_type
% Zijun Wei
s_files=dir(file_type);
s_files=s_files(not([s_files.isdir]));


end

