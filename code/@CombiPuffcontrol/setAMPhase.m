function setAMPhase(obj,amplitudePhase)

% Check that we have an open connection
if isempty(obj.serialObj)
    warning('Serial connection not yet established');
    return
end

% Sanity check the input
mustBeInRange(amplitudePhase,0,2*pi);

% Place the CombiLED in Config Mode
switch obj.deviceState
    case 'CONFIG'
    case {'RUN','DIRECT'}
        writeline(obj.serialObj,'CM');
        readline(obj.serialObj);
        obj.deviceState = 'CONFIG';
end

% Enter the amplitude values send state
writeline(obj.serialObj,'AH');
readline(obj.serialObj);

% Loop over the amplitude values and send these
report = 'amplitude phase: [ ';
writeline(obj.serialObj,num2str(amplitudePhase,'%.4f'));
msg = readline(obj.serialObj);
report = [report, char(msg), ' '];
report = [report,']\n'];

if obj.verbose
    fprintf(report);
end

end