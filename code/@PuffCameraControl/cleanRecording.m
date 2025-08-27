function cleanRecording(obj,trialLabel)

% Assemble the command to crop the video
command = obj.cropCommand;
command = strrep(command,"{stem}",obj.rpiDataSaveStem);
command = strrep(command,"{path}",obj.rpiDataSavePath);
command = strrep(command,"{label}",trialLabel);

% Ignore the response to speed execution
obj.ssh2_conn.command_ignore_response = 1;

% Issue the command
obj.ssh2_conn = ssh2_command(obj.ssh2_conn, command);

% Assemble the command to delete the original version of the recording
command = obj.rmVideoCommand;
command = strrep(command,"{stem}",obj.rpiDataSaveStem);
command = strrep(command,"{path}",obj.rpiDataSavePath);
command = strrep(command,"{label}",trialLabel);

% Issue the command
obj.ssh2_conn = ssh2_command(obj.ssh2_conn, command);

% Assemble the command to rename the recording
command = obj.mvVideoCommand;
command = strrep(command,"{stem}",obj.rpiDataSaveStem);
command = strrep(command,"{path}",obj.rpiDataSavePath);
command = strrep(command,"{label}",trialLabel);

% Issue the command
obj.ssh2_conn = ssh2_command(obj.ssh2_conn, command);

% Re-enable receiving the response
obj.ssh2_conn.command_ignore_response = 0;

% Report it
if obj.verbose
    fprintf(['Cropped the video for trial ' trialLabel '\n']);
end

end