function prepareToRecord(obj,trialLabel)

% Ignore the response to speed execution
obj.ssh2_conn.command_ignore_response = 1;

% Reset the USB camera connect
obj.ssh2_conn = ssh2_command(obj.ssh2_conn, obj.usbResetCommand);    

% Set the camera exposure and brightness
obj.ssh2_conn = ssh2_command(obj.ssh2_conn, obj.cameraSettingsCommand);    

% Assemble the command
thisLine = obj.recordingCommandR;
thisLine = strrep(thisLine,"{dur}",sprintf("%2.2f",obj.durationSecs));
thisLine = strrep(thisLine,"{stem}",obj.rpiDataSaveStem);
thisLine = strrep(thisLine,"{path}",obj.rpiDataSavePath);
thisLine = strrep(thisLine,"{label}",trialLabel);
command(1) = thisLine;

% Define a local temp file path and name and save the comand text
[localPath,localName] = fileparts(tempname());
writelines(command,fullfile(localPath,localName))

% Assign a name to the command file and move it to the recording computer
remotePath = fullfile(obj.rpiCommandDir);
remoteName = [trialLabel '.sh'];
obj.ssh2_conn = scp_put(obj.ssh2_conn, localName, remotePath, localPath, remoteName);

% Make the script executable
command = ['chmod +x ' fullfile(remotePath,remoteName)];
obj.ssh2_conn = ssh2_command(obj.ssh2_conn, command);    

% Re-enable receiving the response
obj.ssh2_conn.command_ignore_response = 0;

% Announce it
if obj.verbose
    fprintf(['Recording script prepared for trial ' trialLabel '\n']);
end


end