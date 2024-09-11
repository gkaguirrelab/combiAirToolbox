function sendDurations(obj,stimDursMs)
% In configure mode, pass a set of trial durations in ms units

% Check that we have an open connection
if isempty(obj.serialObj)
    warning('Serial connection not yet established');
end

% Sanity check the sequence. No value should be greater than 1000.
assert(all(stimDursMs<=1000));

% Place the CombiAir in CONFIG Mode
switch obj.deviceState
    case 'CONFIG'
    case {'DIRECT','RUN'}
        writeline(obj.serialObj,'CM');
        readline(obj.serialObj);
        obj.deviceState = 'CONFIG';
end

% Prepare to send the sequence
writeline(obj.serialObj,'SD');
readline(obj.serialObj);

% Loop over the sequence and write the values
for ii=1:length(stimDursMs)
    % Each value is sent as an float
    writeline(obj.serialObj,num2str(stimDursMs(ii)));
    readline(obj.serialObj);
end

% Say
if obj.verbose
    fprintf('Trial durations sent\n');
end

end