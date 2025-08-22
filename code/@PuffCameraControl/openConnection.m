function openConnection(obj)


% Announce it
if obj.verbose
    fprintf('Opening SSH connection to RPI\n');
end

% Define the connection
obj.ssh2_conn = ssh2_config(obj.HOSTNAME,obj.USERNAME,obj.PASSWORD);

% Test the connection by creating the remote data directory
try
    command = char("mkdir -p " + fullfile(obj.rpiDataSaveStem,obj.rpiDataSavePath));
    obj.ssh2_conn = ssh2_command(obj.ssh2_conn, command);
catch
    % If we are unable to connect, check these things:
    % - Make sure the the IP address defined for the HOSTNAME variable is
    % correct.
    % - By default, the RPI is not able to accept the key exchange protocol
    % that is used by the "ssh2_config" commands. To address this, edit
    % this file on the RPI:
    %   /etc/ssh/sshd_config
    % Add this line:
    %   KexAlgorithms +diffie-hellman-group14-sha1
    % then reboot the RPI.
    error('Unable to connect to RPI. Take a look at the comments in this section of code for troubleshooting advice.');
end


end