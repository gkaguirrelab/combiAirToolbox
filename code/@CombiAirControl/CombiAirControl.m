% Object to support controlling the AirPuff device created by Vincent Lau.
% The device houses an Arduino nano, with a baud rate of 115200.

classdef CombiAirControl < handle

    properties (Constant)

        baudrate = 115200;
    end

    % Private properties
    properties (GetAccess=private)

    end

    % Calling function can see, but not modify
    properties (SetAccess=private)

        serialObj
        deviceState

    end

    % These may be modified after object creation
    properties (SetAccess=public)

        % Verbosity
        verbose = false;

    end

    methods

        % Constructor
        function obj = CombiAirControl(varargin)

            % input parser
            p = inputParser; p.KeepUnmatched = false;
            p.addParameter('verbose',false,@islogical);
            p.parse(varargin{:})

            % Store the verbosity
            obj.verbose = p.Results.verbose;

            % Open the serial port
            obj.serialOpen;

        end

        % Required methds
        serialOpen(obj)
        serialClose(obj)
        setRunMode(obj)        
        sendPressures(obj,stimPressuresPSI)
        sendDurations(obj,stimDursMs)
        sendSequence(obj,stimIdxSeq)
        sendTrialDur(obj,trialDurSecs)
        startSequence(obj)
        stopSequence(obj)
        setPressureDirect(obj,pressureSetting)
        setDurationDirect(obj,durationMs)
        clearPistonDirect(obj)
        triggerPuffDirect(obj)

    end
end