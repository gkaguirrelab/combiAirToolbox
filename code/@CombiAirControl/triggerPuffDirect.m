function triggerPuffDirect(obj)
% In direct mode, trigger a puff.

% Check that we have an open connection
if isempty(obj.serialObj)
    warning('Serial connection not yet established');
end

% Place the CombiLED in DIRECT Mode
switch obj.deviceState
    case 'DIRECT'
    case {'CONFIG','RUN'}
        writeline(obj.serialObj,'DM');
        readline(obj.serialObj);
        obj.deviceState = 'DIRECT';
end

% Initiate the puff; there will be no serial response back
writeline(obj.serialObj,'PP');

% Say
if obj.verbose
    fprintf('Puff delivered\n');
end

end