% Object to support accessing the RPI control of IR video camera recording
% in the Vincent Lau puff device.

classdef PuffCameraControl < handle

    properties (Constant)

        USERNAME = 'testuser';
        HOSTNAME = '10.102.11.73';
        PASSWORD = 'test';
        rpiDataSaveStem = '/media/testuser/EYEVIDEOS/';
        rpiCommandDir = '/home/testuser/Documents/commands';
        commandBaseL = "ffmpeg -loglevel quiet -f v4l2 -input_format gray -video_size 320x240 -framerate 280 -i /dev/video0 -vcodec libx264 -preset ultrafast -t {dur} /media/testuser/EYEVIDEOS/{path}/{label}_side-L.mp4 &"
        commandBaseR = "ffmpeg -loglevel quiet -f v4l2 -input_format gray -video_size 320x240 -framerate 280 -i /dev/video2 -vcodec libx264 -preset ultrafast -t {dur} /media/testuser/EYEVIDEOS/{path}/{label}_side-R.mp4 &"

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

    end
end