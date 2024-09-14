function sendTrialDur(obj,trialDurSecs)
% In configure mode, define the duration of each trial in units of seconds

% Check that we have an open connection
if isempty(obj.serialObj)
    warning('Serial connection not yet established');
end

% Sanity check value. It cannot be less than the 2 seconds + the maximum
% air puff duration. Hard coding this for now as must equal to or greater
% than 3 seconds
assert(trialDurSecs>=3);

% Place the CombiAir in CONFIG Mode
switch obj.deviceState
    case 'CONFIG'
    case {'DIRECT','RUN'}
        writeline(obj.serialObj,'CM');
        readline(obj.serialObj);
        obj.deviceState = 'CONFIG';
end

% Prepare to send the sequence
writeline(obj.serialObj,'ST');
readline(obj.serialObj);

% Send the value
writeline(obj.serialObj,num2str(trialDurSecs));
readline(obj.serialObj);

% Say
if obj.verbose
    fprintf('Trial duration sent\n');
end

end