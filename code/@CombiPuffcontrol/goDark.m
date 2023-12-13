function goDark(obj)

% Check that we have an open connection
if isempty(obj.serialObj)
    warning('Serial connection not yet established');
end

% Place the CombiLED in Run Mode
switch obj.deviceState
    case 'RUN'
    case {'CONFIG','DIRECT'}
        writeline(obj.serialObj,'RM');
        readline(obj.serialObj);
        obj.deviceState = 'RUN';
end

% Go dark
writeline(obj.serialObj,'DK');
msg = readline(obj.serialObj);

% Say
if obj.verbose
    fprintf([char(msg) '\n']);
end

end