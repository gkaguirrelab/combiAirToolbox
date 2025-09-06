function checkFileClosed(obj)

% Assemble the command
command = fullfile(obj.rpiCommandDir,'checkFileClosed.sh');

% Issue the command
[obj.ssh2_conn,~] = ssh2_command(obj.ssh2_conn, command);

% Report it
if obj.verbose
    fprintf('Video file closed\n');
end

end