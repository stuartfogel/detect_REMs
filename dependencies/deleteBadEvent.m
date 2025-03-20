function [EEG] = deleteBadEvent(EEG,PARAM)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Delete bad events in EEG data according to movement and other
% criteria, as set in the user-defined PARAM structure
%
% This function deletes that occur during events that mark bad data
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

%% Remove events during movement artifact
Event = EEG.event;
% to be sure that all is in the right order
[~, idx] = sort([Event.latency]);
Event = Event(idx);
evtIdx = find(strcmpi({Event.type},PARAM.EMlabel));
ToRmv = [];
for iSpin = evtIdx % loop on event
    bad = find(ismember({Event(1:iSpin).type},PARAM.badData),1,'last');
    if ~isempty(bad)
        if Event(bad).latency + Event(bad).duration > Event(iSpin).latency
            ToRmv(end+1) = iSpin;
        end
    end
end
% let's kill the bad event
Event(ToRmv) = [];
EEG.event = Event;
% check that everything is ok
EEG = eeg_checkset(EEG, 'eventconsistency');
EEG = eeg_checkset(EEG, 'checkur');
EEG = eeg_checkset(EEG);

end