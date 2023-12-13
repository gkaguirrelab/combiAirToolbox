function combiPuffToolboxLocalHook

%  combiPuffToolboxLocalHook
%
% As part of the setup process, ToolboxToolbox will copy this file to your
% ToolboxToolbox localToolboxHooks directory (minus the "Template" suffix).
% The defalt location for this would be
%   ~/localToolboxHooks/combiPuffToolboxLocalHook.m
%
% Each time you run tbUseProject('combiPuffToolbox'), ToolboxToolbox will
% execute your local copy of this file to do setup for prizmatixDesign.
%
% You should edit your local copy with values that are correct for your
% local machine, for example the output directory location.
%


% Say hello.
projectName = 'combiPuffToolbox';

% Delete any old prefs
if (ispref(projectName))
    rmpref(projectName);
end

% Handle hosts with custom dropbox locations
[~, userName] = system('whoami');
userName = strtrim(userName);
switch userName
    case 'aguirre'
        dropBoxUserFullName = 'Geoffrey Aguirre';
        dropboxBaseDir = fullfile(filesep,'Users',userName,...
            'Aguirre-Brainard Lab Dropbox',dropBoxUserFullName);
    otherwise
        dropboxBaseDir = ...
            fullfile('/Users', userName, ...
            'Aguirre-Brainard Lab Dropbox',userName);
end

% Set preferences for project output
setpref(projectName,'dropboxBaseDir',dropboxBaseDir); % main directory path 

end