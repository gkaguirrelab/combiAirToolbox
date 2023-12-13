function updateContrast(obj,contrast)

% Check that we have an open connection
if isempty(obj.serialObj)
    warning('Serial connection not yet established');
    return
end

% Sanity check the contrast value
mustBeInRange(contrast,0,1);

% Place the CombiLED in Run Mode
switch obj.deviceState
    case 'RUN'
    case {'CONFIG','DIRECT'}
        writeline(obj.serialObj,'RM');
        readline(obj.serialObj);
        obj.deviceState = 'RUN';
end

% Create the command, which is a concatenation of the FQ command with the
% frequency value itself
command = ['CN' num2str(contrast,'%.4f')];

% Send the frequency command
writeline(obj.serialObj,command);
msg = readline(obj.serialObj);

if obj.verbose
    fprintf(['Contrast set to ' char(msg) '\n']);
end


end