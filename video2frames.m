function video2frames(video_fname, frames_path)
mkdir(frames_path)
cmd = ['LD_LIBRARY_PATH=/usr/lib/; ffmpeg -i ' video_fname ' ' frames_path '/%6d.jpg'];
unix(cmd);

