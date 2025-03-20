function [EEG,remTable,locsInSamples] = detect_REMs(EEG,locChannel,rocChannel,badData,allStageLabels,REMstageLabel)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% [EEG] = detect_REMs(EEG,locChannel,rocChannel,badData,allStageLabels,REMstageLabel)
%
% Usage:
%   >>  [EEGOUT,remTable] = detect_REMs; % pop up main app
%   >>  [EEGOUT,remTable = detect_REMs(EEG); % detect REMs without pop up
%
% Inputs:
%   'EEG'       - EEG dataset structure
%    
% Outputs:
%   EEGOUT      - EEG dataset structure
%   remTable    - Table of results
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
% customize input parameters
% runs REM detection
%
% Works best if recording includes:
% - sleep stage scoring in EEG.event structure
% - Bad Data event markers (e.g., 'Movement') in EEG.event structure
%

% Jan 20, 2023: Version 1.0
%
% Main function to launch Hatzilabrou Et Al 1994 detector adapted from
% Yetton et al 2016: DOI: 10.1016/j.jneumeth.2015.11.015
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

%% USER-DEFINED INPUT PARAMETERS
PARAM.allStageLabels = cell(strsplit(allStageLabels)); % complete set of sleep stage labels [default {{'Wake'},{'N1'},{'N2'},{'SWS'},{'REM'},{'Unscored'}}]
PARAM.locChannel = locChannel;
PARAM.rocChannel = rocChannel;
PARAM.REMlabel = REMstageLabel;
PARAM.badData = badData;

%% ADDIOTIONAL ADVANCED USER-DEFINED PARAMETERS
PARAM.monocular = 0; % monocular / binocular criteria [binocular = 0, monocular = 1]
PARAM.EMlabel = 'EM'; % user-defined label for eye movement events
PARAM.filterOptionHP = 0.5; % default 0.5 NOTE: 1Hz works better for some files!!!!
PARAM.filterOptionLP = 10; % default 10, NOTE: 5Hz works better for some files!!!!

addpath('dependencies')

%% Get REM periods for all datasets

progress = waitbar(0, 'Finding REM periods...'); pause(1)

[REMperiods] = getREMperiods(EEG, PARAM);

%% Run detector on each file

disp('===========================================================================')
disp('              Detecting eye movements. This can take a while...            ')
disp('===========================================================================')

startTimes = REMperiods.StartREM(strcmpi(EEG.setname,REMperiods.Name));
endTimes = REMperiods.EndREM(strcmpi(EEG.setname,REMperiods.Name));
EEG.data = double(EEG.data); % filtfilt requires data to be double precision
locsInSamples = cell(length(startTimes),1);

% loop over each REM period
for remperiod = 1:length(startTimes)
    
    waitbar(1/(length(startTimes)+1)*remperiod,progress,['Detecting eye movements in REM period: ' num2str(remperiod) ' of ' num2str(length(startTimes)) '...']); pause(1)

    % import and parse data
    parsedData = importAndParseData(EEG,PARAM,startTimes(remperiod),endTimes(remperiod));
    
    % detect eye movments
    locsInSamples{remperiod} = HatzilabrouEtAl(EEG,PARAM,parsedData.rawTimeData);

end

% import REMs onto EEG dataset and save dataset
EEG = eeg_checkset(EEG,'eventconsistency');
EEG = eeg_checkset(EEG,'checkur');
EEG = eeg_checkset(EEG);

EEG = importREMs(EEG,PARAM,REMperiods,locsInSamples);

% convert eeglab event structure to table for CSV and mat export
remTable = [];
remTableTemp = struct2table(EEG.event);
remTableTemp(~strcmp(remTableTemp.type,PARAM.EMlabel),:)=[]; % filter events table so that it only contains eye movements
File = repmat({EEG.setname}, height(remTableTemp), 1); % add column with file name
remTableTemp = [File remTableTemp];
remTableTemp.Properties.VariableNames{'Var1'} = 'file';
remTable = [remTable; remTableTemp];

waitbar(1,progress,'Eye movement detection complete...'); pause(1)
close(progress)

end