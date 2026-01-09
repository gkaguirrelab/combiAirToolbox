function prepareToRecord(obj,trialLabel)

%% Confirm or create the directory into which the data will be saved
dirCommand = ['mkdir -p ' fullfile(obj.rpiDataSaveStem,obj.rpiDataSavePath)];
[obj.ssh2_conn, ~] = ssh2_command(obj.ssh2_conn, dirCommand);    

%% Set the audio source to the external headphone jacl
[obj.ssh2_conn, ~] = ssh2_command(obj.ssh2_conn, obj.audioSourceCommand);    

%% Reset the USB camera connect
[obj.ssh2_conn, ~] = ssh2_command(obj.ssh2_conn, obj.usbResetCommand);    

%% Set the camera exposure and brightness
[obj.ssh2_conn, ~] = ssh2_command(obj.ssh2_conn, obj.cameraSettingsCommand);    

%% Assemble the recording command
thisLine = obj.recordingCommand;
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
[obj.ssh2_conn] = scp_put(obj.ssh2_conn, localName, remotePath, localPath, remoteName);

% Make the script executable
command = ['chmod +x ' fullfile(remotePath,remoteName)];
[obj.ssh2_conn, ~] = ssh2_command(obj.ssh2_conn, command);    

%% Assemble the command to check that the recorded video file has closed
clear command
command = "";
command(1) = "FILE=""" + fullfile(obj.rpiDataSaveStem,obj.rpiDataSavePath,[trialLabel '_side-R.avi']) + char(34);
command(2) = "while true; do";
command(3) = "    if [[ -z ""$(lsof -t ""$FILE"" 2>/dev/null)"" ]]; then";
command(4) = "        exit 0";
command(5) = "    fi";
command(6) = "done";

% Define a local temp file path and name and save the comand text
[localPath,localName] = fileparts(tempname());
writelines(command,fullfile(localPath,localName))

% Assign a name to the command file and move it to the recording computer
remotePath = fullfile(obj.rpiCommandDir);
remoteName = 'checkFileClosed.sh';
[obj.ssh2_conn] = scp_put(obj.ssh2_conn, localName, remotePath, localPath, remoteName);

% Make the script executable
command = ['chmod +x ' fullfile(remotePath,remoteName)];
[obj.ssh2_conn, ~] = ssh2_command(obj.ssh2_conn, command);    

% Announce it
if obj.verbose
    fprintf(['Recording script prepared for trial ' trialLabel '\n']);
end


end