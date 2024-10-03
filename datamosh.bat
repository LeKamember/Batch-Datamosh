:::: init -----------------------------------------------------------------------------------
@echo off
setlocal enabledelayedexpansion

:::: inti file paths ------------------------------------------------------------------------
:: input file path
IF [%1] equ [] (
	echo Error : Missing file name
	echo datamosh.bat INPUT_PATH [OUTPUT_PATH] [FFMPEG_BINARY_PATH]
	goto :end
)
CALL :NORMALIZEPATH %1
set input_file="%RETVAL%"

:: output file path, default if not specified
IF [%2] equ [] (
	CALL :DefaultOutputFile %input_file%
)ELSE (
	CALL :NORMALIZEPATH %2
)
set output_file="%RETVAL%"

:: default if ffmpeg path is not specified
IF [%3] equ [] (
	:: default path (can be modified)
	set ffmpeg=ffmpeg
)ELSE (
	set ffmpeg=%3
)
:: normalize ffmpeg path if it's a binary
CALL :NORMALIZEPATH %ffmpeg%
IF "%ffmpeg%" neq "ffmpeg" set ffmpeg="%RETVAL%"

:::: Create a temp folder ------------------------------------------------------
:uniqTempFolder
set "TempDatamosh=%tmp%\Datamosh-%RANDOM%"
if exist "%TempDatamosh%" goto :uniqTempFolder
mkdir %TempDatamosh%

:::: DATAMOSH -------------------------------------------------------------------------------
:: Convert the video to a file with low I-frames
%ffmpeg% -i %input_file% -vcodec libxvid -q:v 1 -g 1000 -qmin 1 -qmax 1 -flags qpel+mv4 -an -y %TempDatamosh%\xvid_video.avi

:: Extract the raw frames
%ffmpeg% -i %TempDatamosh%\xvid_video.avi -vcodec copy -start_number 0 %TempDatamosh%\f_1%%05d.raw

:: get the I-frames and store their numbers in a file (it's stupid, but it's the only way I've found to make it work)
%ffmpeg% -i %TempDatamosh%\xvid_video.avi -vf select='eq(pict_type,PICT_TYPE_I)' -vsync 2 -f image2 -start_number 0 %TempDatamosh%\i_%%05d.jpg -loglevel debug -hide_banner 2>&1|for /f "tokens=5 delims=:. " %%i in ('findstr "pict_type:I"') do echo %%i >> %TempDatamosh%\iframes.txt
:: reverse the order in case there are consecutive I-frames
for /f "tokens=*" %%a in (%TempDatamosh%\iframes.txt) do set reversed=%%a !reversed! 
:: "delete" I-frames (by replacing them with the next frame to maintain sound synchronization)
for %%f in (!reversed!) do call :DEL_IFRAME %%f

:: create an AVI file with the raw frames
copy NUL /b  %TempDatamosh%\edited_video.avi 
for /f %%i in ('dir /on/b %TempDatamosh%\*.raw') do copy /b %TempDatamosh%\edited_video.avi+%TempDatamosh%\%%i %TempDatamosh%\edited_video.avi

:: create final file (with sound)
%ffmpeg% -i %TempDatamosh%\edited_video.avi -i %input_file% -map 0:v:0 -map 1:a:0 -vcodec h264 %output_file%

rmdir /q /s "%TempDatamosh%"
goto :end

:NORMALIZEPATH
SET RETVAL=%~f1
EXIT /B

:DefaultOutputFile
SET RETVAL=%cd%\Datamosh_%~n1.mp4
EXIT /B

:DEL_IFRAME
if %1 equ 0 goto :eof
set /a frame_nb=%1+100000
set /a next_frame_nb=%frame_nb%+1
set frame_name=%TempDatamosh%\f_%frame_nb%.raw
set next_frame_name=%TempDatamosh%\f_%next_frame_nb%.raw
copy /y %next_frame_name% %frame_name%
goto :eof

:end