% Object to support accessing the RPI control of IR video camera recording
% in the Vincent Lau puff device.

classdef PuffCameraControl < handle

    properties (Constant)
        USERNAME = getpref('combiAirToolbox','linuxBoxUsername');
        HOSTNAME = getpref('combiAirToolbox','linuxBoxHostname');
        PASSWORD = getpref('combiAirToolbox','linuxBoxPassword');
        rpiDataSaveStem = getpref('combiAirToolbox','linuxBoxPathstem');
        rpiCommandDir = getpref('combiAirToolbox','linuxBoxCommandDir');
        audioSourceCommand = 'pactl set-default-source alsa_input.pci-0000_05_00.6.analog-stereo'; % Use the external headphone jack source
        usbResetCommand = 'usbreset 2560:c124'; %% This is the product and vendor ID for the See3Cam cameras
        cameraSettingsCommand = 'v4l2-ctl -d /dev/video0 --set-ctrl=exposure_absolute=40 --set-ctrl=brightness=40 -d /dev/video2 --set-ctrl=exposure_absolute=40 --set-ctrl=brightness=40';
        recordingCommand = ['ffmpeg -loglevel quiet '  ...
            '-f v4l2 -use_wallclock_as_timestamps 1 -input_format gray -video_size 640x480 -framerate 180 -thread_queue_size 8192 -i /dev/video0 '  ...
            '-f v4l2 -use_wallclock_as_timestamps 1 -input_format gray -video_size 640x480 -framerate 180 -thread_queue_size 8192 -i /dev/video2 '  ...
            '-f alsa -thread_queue_size 8192 -ac 1 -ar 8000 -i default '  ...
            '-filter_complex '  ...
            '"[0:v]crop=320:240:160:120[left]; '  ...
            ' [1:v]crop=320:240:160:120,hflip,vflip,setpts=PTS+0.2/TB[right]; '  ...
            ' [left][right]hstack=inputs=2:shortest=1[v_stacked]; ' ...
            ' [v_stacked]setpts=PTS-STARTPTS,fps=180[v]; '  ...
            ' [2:a]asetpts=PTS-STARTPTS[a]" '  ...
            '-map "[v]" -map "[a]" '  ...
            '-vcodec rawvideo -pix_fmt gray '  ...
            '-acodec pcm_s16le '  ...
            '-t {dur} '  ...
            '-y {stem}/{path}/{label}_dual.avi &'];
    end

    % Private properties
    properties (GetAccess=private)

        ssh2_conn
        rpiDataSavePath

    end

    % Calling function can see, but not modify
    properties (SetAccess=private)

    end

    % These may be modified after object creation
    properties (SetAccess=public)

        % Duration of recording
        durationSecs

        % Verbosity
        verbose = false;

    end

    methods

        % Constructor
        function obj = PuffCameraControl(experimentName,subjectID,varargin)

            % input parser
            p = inputParser; p.KeepUnmatched = false;
            p.addParameter('durationSecs',5,@isnumeric);
            p.addParameter('verbose',true,@islogical);
            p.parse(varargin{:})

            obj.rpiDataSavePath = fullfile(experimentName,subjectID);
            obj.durationSecs = p.Results.durationSecs;

            % Store the verbosity
            obj.verbose = p.Results.verbose;

            % Open the connection
            obj.openConnection;

        end

        % Required methds
        openConnection(obj)
        closeConnection(obj)
        prepareToRecord(obj,trialLabel)
        startRecording(obj,trialLabel)
        cleanRecording(obj,trialLabel)
        checkFileClosed(obj)
    end
end