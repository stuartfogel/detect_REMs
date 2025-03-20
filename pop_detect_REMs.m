function [EEG, com] = pop_detect_REMs(EEG)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% pop_detect_REMs() - EEGLAB plugin for detecting rapid eye movements in REM
% sleep.
%
% Usage:
%   >>  EEGOUT = pop_detect_REMs; % pop up main app
%   >>  EEGOUT = pop_detect_REMs(EEG); % detect REMs without pop up
%
% Inputs:
%   'EEG'   - EEG dataset structure
%
% Outputs:
%   EEGOUT  - EEG dataset structure
%
% See also:
%   detect_REMs, pop_detect_REMs, eeglab
%
% REQUIREMENTS:
% MATLAB version R2019a or later
% EEGlab 2019 or later (https://eeglab.org)
%
% USAGE:
% Loads an EEGlab PSG dataset
% Customize input parameters
% Run REM detection
% Outputs both CSV and MAT summary data files
%
% Works best if recording includes:
% - sleep stage scoring in EEG.event structure
% - Bad Data event markers (e.g., 'Movement') in EEG.event structure
%

% Jan 20, 2023: Version 1.0
%
% https://socialsciences.uottawa.ca/sleep-lab/
% https://www.sleepwellpsg.com
%
% Copyright (C) Stuart Fogel & Sleep Well, 2022.
% See the GNU General Public License v3.0 for more information.
%
% This file is part of 'detect_REMs'.
% See https://github.com/stuartfogel/detect_REMS for details.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
%
% 1. Redistributions of source code must retain the above author, license,
% copyright notice, this list of conditions, and the following disclaimer.
%
% 2. Redistributions in binary form must reproduce the above author, license,
% copyright notice, this list of conditions, and the following disclaimer in
% the documentation and/or other materials provided with the distribution.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
% THE POSSIBILITY OF SUCH DAMAGE.
%
% Detect REMs is intended for research purposes only. Any commercial 
% or medical use of this software and source code is strictly prohibited.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% handle history & check input arguments
com = '';
if nargin < 1
    help pop_detect_REMs;
    return;
end

% GUI geometry setup
g = [3, 2];
geometry = {1,g,g,g,1,[2 2 1]};
geomvert = [1 1 1 1 1 1];

% select channels
cb_chan = 'pop_chansel(get(gcbf, ''userdata''), ''field'', ''labels'', ''handle'', findobj(''parent'', gcbf, ''tag'', ''ChOI''));';

% build GIU
uilist = { ...
    ... label settings
    {'style', 'text', 'string', 'Automatic Rapid Eye Movement Detection'} ...
    {'style', 'text', 'string', 'Label for all sleep stages'} ...
    {'style', 'edit', 'string', 'W N1 N2 SWS REM Unscored' 'tag' 'allSleepStages'} ...
    {'style', 'text', 'string', 'Label for REM stage label'} ...
    {'style', 'edit', 'string', 'REM' 'tag' 'REMstageLabel'} ...
    {'style', 'text', 'string', 'Label for bad data'} ...
    {'style', 'edit', 'string', 'Movement' 'tag' 'badData'} ...
    ... channel options
    { 'style' 'text'       'string' '' } ...
    { 'style' 'text'       'string' 'Channel labels or indices' } ...
    { 'style' 'edit'       'string' 'LEOG REOG' 'tag' 'ChOI' }  ...
    { 'style' 'pushbutton' 'string' '...' 'callback' cb_chan }
    };

% channel labels
if ~isempty(EEG(1).chanlocs)
    tmpchanlocs = EEG(1).chanlocs;
else
    tmpchanlocs = [];
    for index = 1:EEG(1).nbchan
        tmpchanlocs(index).labels = int2str(index);
        tmpchanlocs(index).type = '';
    end
end

% launch gui
result = inputgui('geometry', geometry, 'geomvert', geomvert, 'uilist', uilist, 'title', 'Rapid Eye Movement Detection -- detect_REMs', 'helpcom', 'pophelp(''detect_REMs'')', 'userdata', tmpchanlocs);

% launch detect_REMs
if ~isempty(result)
    allStageLabels = result{1};
    REMstageLabel = result{2};
    badData = result{3};
    result{4} = strsplit(result{4},' ');
    locChannel = result{4}{1};
    rocChannel = result{4}{2};
    outputFilename = [EEG(1).filepath filesep 'REMdetectionResults_' datestr(now, 'dd-mmm-yyyy-hh-MM')]; % output CSV & MAT file name
    remTable = [];
    locsInSamples = cell(length(EEG),1);
    for iSet = 1:length(EEG)
        [EEG(iSet),remTableTemp,locsInSamplesTemp] = detect_REMs(EEG(iSet),locChannel,rocChannel,badData,allStageLabels,REMstageLabel);
        % save output
        if isempty(remTableTemp)
            warning(['No rapid eye movements detected for: "' EEG(iSet).setname '". If this unexpected, check dataset and detection settings.'])
        else
            remTableTemp = remTableTemp(:,["file","type","latency"]);
            remTable = [remTable; remTableTemp];
        end
        locsInSamples{iSet} = locsInSamplesTemp;
        if length(EEG) > 1
            EEG(iSet).setname = [EEG(iSet).setname '_REMdet'];
            EEG(iSet).filename = [EEG(iSet).setname '.set'];
            EEG(iSet) = pop_saveset(EEG(iSet),'filepath',EEG(iSet).filepath,'filename',EEG(iSet).setname,'savemode','onefile');
        end
    end
    disp('===========================================================================')
    disp(['Saving Output to: ' outputFilename])
    disp('===========================================================================')
    save([outputFilename '.mat'],'remTable','locsInSamples', '-v7.3');
    writetable(remTable,[outputFilename '.csv']);
else
    com = '';
    return
end
% update EEG.history
com = sprintf('EEG = detect_REMs(''%s'',''%s'',''%s'',''%s'',''%s'',''%s'');',inputname(1),locChannel,rocChannel,badData,allStageLabels,REMstageLabel);
EEG = eegh(com, EEG); % update history

end