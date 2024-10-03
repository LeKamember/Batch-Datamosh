# Batch-Datamosh
A batch script that will remove I-frames from your video, creating glitch transitions. Nearly all the code comes from [Reddit thread comments](https://www.reddit.com/r/datamoshing/comments/t46x3i/datamoshing_with_ffmpeg_howto_in_comments/) by user [justhadto](https://www.reddit.com/user/justhadto/), I just made a script out of it.

## Dependency
[FFmpeg](https://www.ffmpeg.org/)

## Use
In the command prompt (cmd), use the following syntax:
```
datamosh.bat INPUT_PATH [OUTPUT_PATH] [FFMPEG_BINARY_PATH]
```
- **`INPUT_PATH`**: The path of the video you want to datamosh (relative or absolute). If the file path contains special characters (like spaces, punctuation, etc.), it may not work correctly.
- **`OUTPUT_PATH`**: The path where the datamoshed video will be saved (relative or absolute path with filename and extension). The default path is in current working directory, and the default filename is `Datamosh_{name}.mp4`.
- **`FFMPEG_BINARY_PATH`**: The path of the FFmpeg binary. If not specified, the script will use the Windows PATH for FFmpeg. This default behavior can be modified in the script (see line 26).
## Notes
This script can (and will) create a LOT of temporary files (files are deleted at the end) and the script takes a long time to finish, it's recommended to not take heavy videos.
