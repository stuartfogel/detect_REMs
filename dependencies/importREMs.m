function [EEG] = importREMs(EEG,PARAM,REMperiods,locsInSamples)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% [EEG] = importREMs(EEG,PARAM,remStartAndEnd,locsInSamples)
%
% function to import REM events to an EEGLAB dataset
%
% Part of detect_REMs for HatzilabrouEtAl method of REM detection
%
% Adapted Yetton et al 2016: DOI: 10.1016/j.jneumeth.2015.11.015
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

% setup
% idx = [];
REMlatency = [];
REMlatencyTemp = [];

% create empty EEGlab event structure to match existing to merge
fields = fieldnames(EEG.event)';
fields{2,1} = {};
events = struct(fields{:});

% for each REM period, create EEG.event structure
i = 1; % rem period counter
for nREMperiod = 1:height(REMperiods)
%    if idx(nREMperiod) == 1 % check that the REM period corresponds to the current file
        REMlatencyTemp = locsInSamples{i};
        REMlatencyTemp = REMlatencyTemp + table2array(REMperiods(nREMperiod,3)); % align to REM periods from original recording
        REMlatency = [REMlatency REMlatencyTemp]; % concatenate each REM period's event latencies
        i = i + 1; % increment REM period counter
        clear REMlatencyTemp
%    end
end

% for each EM event, put it into the empty EEGlab event structure
for nEvt = 1:length(REMlatency)
    events(nEvt).type = PARAM.EMlabel;
    events(nEvt).latency = REMlatency(nEvt);
    events(nEvt).duration = 1; % one data point long
    events(nEvt).urevent = [];
    if isfield(events, 'SleepStage')
        events(nEvt).SleepStage = PARAM.REMlabel;
    end
end

% concatenate event strtures and sort
EEG.event = [EEG.event events];
EEG = eeg_checkset(EEG, 'eventconsistency');
EEG = eeg_checkset(EEG, 'checkur');

% delete events during Movement
if ~isempty(find(ismember({EEG.event(:).type},'Movement'),1))
    EEG = deleteBadEvent(EEG, PARAM);
end

end