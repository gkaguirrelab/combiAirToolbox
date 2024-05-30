function setDuration(obj,durationMs)
% In direct mode, set the stimulus duration in units of ms.

% Check that we have an open connection
if isempty(obj.serialObj)
    warning('Serial connection not yet established');
end

% Sanity check the contrast value
durationMs = round(durationMs);
mustBeInRange(durationMs,100,1000);

% Place the CombiLED in DIRECT Mode
switch obj.deviceState
    case 'DIRECT'
    case {'CONFIG','RUN'}
        writeline(obj.serialObj,'DM');
        readline(obj.serialObj);
        obj.deviceState = 'DIRECT';
end

% Send pressure setting value
writeline(obj.serialObj,'SD');
readline(obj.serialObj);
writeline(obj.serialObj,num2str(durationMs));
msg=readline(obj.serialObj);

% Say
if obj.verbose
    fprintf(['Stimulus duration set to (ms): ' char(msg) '\n']);
end

end