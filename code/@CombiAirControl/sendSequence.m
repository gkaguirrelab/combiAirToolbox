function sendSequence(obj,stimIdxSeq)
% In configure mode, pass a sequence of trial indices

% Check that we have an open connection
if isempty(obj.serialObj)
    warning('Serial connection not yet established');
end

% Sanity check the sequence. This must be an array of integers, with one
% integer value for each stimulus type. We must not skip any integers.
stimTypes = unique(stimIdxSeq);
assert(all(diff(stimTypes)==1));
assert(max(stimIdxSeq)+1==length(stimTypes));

% Place the CombiLED in CONFIG Mode
switch obj.deviceState
    case 'CONFIG'
    case {'DIRECT','RUN'}
        writeline(obj.serialObj,'CM');
        readline(obj.serialObj);
        obj.deviceState = 'CONFIG';
end

% Prepare to send the sequence
writeline(obj.serialObj,'SI');
readline(obj.serialObj);

% Pass the number of trials
writeline(obj.serialObj,num2str(length(stimIdxSeq)));
readline(obj.serialObj);

% Loop over the sequence and write the values
for ii=1:length(stimIdxSeq)
    % Each value is sent as an integer
    writeline(obj.serialObj,num2str(stimIdxSeq(ii)));
    readline(obj.serialObj);
end

% Say
if obj.verbose
    fprintf('Stimulus index sequuence sent\n');
end

end