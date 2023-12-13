function setLEDUpdateOrder(obj,ledUpdateOrder)

% Check that the settings match the number of primaries
if length(ledUpdateOrder) ~= obj.nPrimaries
    warning('Length of settings must match number of primaries')
    return
end

% Sanity check the settings range
mustBeInRange(ledUpdateOrder,0,obj.nPrimaries-1);

% Check that we have an open connection
if isempty(obj.serialObj)
    warning('Serial connection not yet established');
    return
end

% Place the CombiLED in Config Mode
switch obj.deviceState
    case 'CONFIG'
    case {'RUN','DIRECT'}
        writeline(obj.serialObj,'CM');
        readline(obj.serialObj);
        obj.deviceState = 'CONFIG';
end

% Prepare to send settings
writeline(obj.serialObj,'LU');
readline(obj.serialObj);

% Loop over the primaries and write the values
report = 'ledUpdateOrder: ';

for ii=1:length(ledUpdateOrder)
    writeline(obj.serialObj,num2str(ledUpdateOrder(ii)));
    msg = readline(obj.serialObj);
    report = [report, char(msg), ', '];
end
report = [report,']\n'];

if obj.verbose
    fprintf(report);
end

end