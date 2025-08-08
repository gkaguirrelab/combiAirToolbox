function serialClose(obj)

% Close the serial ports
clear obj.serialObjEPC
obj.serialObjEPC = [];

clear obj.serialObjSolenoid
obj.serialObjSolenoid = [];

if obj.verbose
    fprintf('Serial port closed\n');
end

end