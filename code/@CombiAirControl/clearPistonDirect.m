function clearPistonDirect(obj)
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

% Send the command to clear the piston
writeline(obj.serialObj,'CP');
readline(obj.serialObj);

% Say
if obj.verbose
    fprintf('Piston cleared\n');
end

end