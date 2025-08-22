function startRecording(obj,trialLabel)

% Assemble the command
command = [fullfile(obj.rpiCommandDir,[trialLabel '.sh']) ' &'];

% Ignore the response to speed execution
obj.ssh2_conn.command_ignore_response = 1;

% Issue the command
obj.ssh2_conn = ssh2_command(obj.ssh2_conn, command);

% Move the shell script to the recording directory
command = ['mv ' fullfile(obj.rpiCommandDir,[trialLabel '.sh']) ' ' ...
    fullfile(obj.rpiDataSaveStem,obj.rpiDataSavePath,[trialLabel '.sh'])];
obj.ssh2_conn = ssh2_command(obj.ssh2_conn, command);

% Re-enable receiving the response
obj.ssh2_conn.command_ignore_response = 0;

% Report it
if obj.verbose
    fprintf(['Recording started for trial ' trialLabel '\n']);
end

end