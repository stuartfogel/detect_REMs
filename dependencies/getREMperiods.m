function [REMperiods] = getREMperiods(EEG,PARAM)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% [REMperiods] = getREMperiods(EEG,PARAM)
%
% function to extract start and end of REM periods from an EEGLAB dataset
% for use with Yetton et al's REM detector.
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

% convert eeglab event structure to table
events = struct2table(EEG.event);

% filter events table so that it only contains sleep stages
events(~ismember(events.type,PARAM.allStageLabels),:)=[];

% find start and end of EEG periods
idx = ismember(events{:,'type'},PARAM.REMlabel);
StartIdx = strfind([ 0 idx'],[0 1]);
EndIdx = strfind([idx',0],[1 0]);
StartREM = events{[StartIdx(:)],'latency'};
EndREM = events{[EndIdx(:)],'latency'} + events{[EndIdx(:)],'duration'} - 1;
[Name{1:length(StartREM)}] = deal(EEG.setname);
REMperiod = 1:length(StartREM);
clear events nStage idx StartIdx EndIdx

% put it in a table for output
REMperiods = table(Name',REMperiod(:),StartREM(:),EndREM(:),'VariableNames',{'Name','REMperiod','StartREM','EndREM'});
clear StartREM EndREM Name REMperiod

end