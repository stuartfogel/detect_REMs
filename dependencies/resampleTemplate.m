function [templateREM] = resampleTemplate(EEG,templateREM)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% [templateREM] = resampleTemplate(EEG,templateREM)
%
% This function resamples the REM template for use in datasets with 
% sampling rates otehr than 256Hz
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

% define input and parameters
newSR = EEG.srate; % new sampling rate
oldSR = 256; % sampling rate of the original template

% pad start and end to reduce edge effects
startSegment = flip(templateREM(:,1:floor(length(templateREM)/2))'); % get start segment, flip hozitontally
endSegment = flip(templateREM(:,floor((length(templateREM)+1)/2)+1:end)'); % get end segment, flip hozitontally
startSegment(:,:) = startSegment(end,:) + (startSegment(end,:) - startSegment(:,:)); % flip vertically about end point
endSegment(:,:) = endSegment(1,:) + (endSegment(1,:) - endSegment(:,:)); % flip vertically about start point
templateREMtemp = [startSegment; templateREM'; endSegment]; % concatenate
points = 1:length(templateREMtemp); % time series

% resample
templateREMtemp = resample(templateREMtemp,points,newSR/oldSR,'spline'); % resample: spline slightly reduces edge effects and works better for EEG
templateREMtemp = templateREMtemp'; % invert template back to original orientation
templateREMtemp = templateREMtemp(:,(length(startSegment)*newSR/oldSR)+1:(end-length(endSegment)*newSR/oldSR)-1); % trim padding
templateREM = templateREMtemp; % put it back

% plot
% plot(templateREM'); % plot
% set(gca,'xlim',[1 length(templateREM)]); % fix axes
% set(gca,'ylim',[-100 5000]); % fix axes

end