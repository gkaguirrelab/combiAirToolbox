% Object to support accessing the RPI control of IR video camera recording
% in the Vincent Lau puff device.

classdef PuffCameraControl < handle

    properties (Constant)

        USERNAME = 'gka';
        HOSTNAME = '128.91.12.22';
        PASSWORD = 'braincrunch';
        rpiDataSaveStem = '/media/gka/EYEVIDEOS/';
        rpiCommandDir = '/home/gka/Documents/commands';
        usbResetCommand = 'usbreset 004/003'; %% Should use the output of the usbreset command to get this ID
        cameraSettingsCommand = 'v4l2-ctl -d /dev/video0 --set-ctrl=exposure_absolute=40 --set-ctrl=brightness=50';
        recordingCommandL = "ffmpeg -loglevel quiet -f v4l2 -input_format gray -video_size 640x480 -framerate 180 -i /dev/video0 -vcodec rawvideo -pix_fmt gray -t {dur} -y {stem}/{path}/{label}_side-L.avi &"
        recordingCommandR = "ffmpeg -loglevel quiet -f v4l2 -input_format gray -video_size 640x480 -framerate 180 -i /dev/video0 -vcodec rawvideo -pix_fmt gray -t {dur} -y {stem}/{path}/{label}_side-R.avi &"
        cropCommand = 'ffmpeg -i {stem}/{path}/{label}_side-L.avi -vf "crop=320:240:160:120" -c:v rawvideo {stem}/{path}/{label}_side-L_cropped.avi'
        rmVideoCommand = "rm {stem}/{path}/{label}_side-L.avi"
        mvVideoCommand = "mv {stem}/{path}/{label}_side-L_cropped.avi {stem}/{path}/{label}_side-L.avi"
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
        function obj = PuffCameraControl(rpiDataSavePath,varargin)

            % input parser
            p = inputParser; p.KeepUnmatched = false;
            p.addParameter('durationSecs',5,@isnumeric);
            p.addParameter('verbose',true,@islogical);
            p.parse(varargin{:})

            obj.rpiDataSavePath = rpiDataSavePath;
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