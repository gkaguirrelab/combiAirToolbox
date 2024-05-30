function setPressure(obj,pressureSetting)
% In direct mode, set the stimulus pressure in raw device units in the
% range of 0 to 1023.

% Check that we have an open connection
if isempty(obj.serialObj)
    warning('Serial connection not yet established');
end

% Sanity check the contrast value
pressureSetting = round(pressureSetting);
mustBeInRange(pressureSetting,0,1023);

% Place the CombiLED in DIRECT Mode
switch obj.deviceState
    case 'DIRECT'
    case {'CONFIG','RUN'}
        writeline(obj.serialObj,'DM');
        readline(obj.serialObj);
        obj.deviceState = 'DIRECT';
end

% Send pressure setting value
writeline(obj.serialObj,'SP');
readline(obj.serialObj);
writeline(obj.serialObj,num2str(pressureSetting));
msg=readline(obj.serialObj);

% Say
if obj.verbose
    fprintf(['Pressure setting: ' char(msg) '\n']);
end

end