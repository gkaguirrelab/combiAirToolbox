function setPressureDirect(obj,pressureSettingPSI)
% In direct mode, set the stimulus pressure in PSI units
% Check that we have an open connection
if isempty(obj.serialObj)
    warning('Serial connection not yet established');
end

% Sanity check the contrast value
mustBeInRange(pressureSettingPSI,0,40);

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
writeline(obj.serialObj,num2str(pressureSettingPSI));
msg=readline(obj.serialObj);

% Say
if obj.verbose
    fprintf(['Pressure setting PSI: ' char(msg) '\n']);
end

end