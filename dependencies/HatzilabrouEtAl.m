function [locs] = HatzilabrouEtAl(EEG,PARAM,LOCAndROCSig)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% [locs] = HatzilabrouEtAl(EEG,PARAM,LOCAndROCSig)
%
% This replicates the matched filtering method employed by Hatzilabrou et al, 1994 
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

% Requirements for REM:
% - Bandpass filter (0.5-10Hz), NOTE: 1-5Hz works better for some files!!!!
% - windowize
% - Remove DC offset
% - Smooth using hamming window
% - Compare smoothed window to template REM via Magnitude Squared Correlation

load('templateREM.mat','-mat','templateREM');

% template is in 256Hz. Resample if EEG.srate differs
if ~isequal(EEG.srate,256)
    [templateREM] = resampleTemplate(EEG,templateREM);
end

%% filtering
sigLeft = bandpass(LOCAndROCSig(1,:),PARAM.filterOptionLP,PARAM.filterOptionHP,EEG.srate);
sigRight = bandpass(LOCAndROCSig(2,:),PARAM.filterOptionLP,PARAM.filterOptionHP,EEG.srate);

%% Windowize
L = EEG.srate/2;
cL = zeros(size(sigLeft));
cR = zeros(size(sigRight));
for i=(1+L):(length(sigLeft)-L) % windowize
    currentWinL = sigLeft((i-L):(i+L-1));
    currentWinR = sigRight((i-L):(i+L-1));
    currentWinL = zscore(currentWinL); % power normalize, zero offset
    currentWinR = zscore(currentWinR); 
    hamWinL = hamming(2*L).*currentWinL';
    hamWinR = hamming(2*L).*currentWinR';
    template = templateREM(1,1:EEG.srate);
    hamTemplate = hamming(2*L).*template';
    cL(i) = sum(hamTemplate'.*hamWinL',2)/sum(hamTemplate'.*hamTemplate',2);
    cR(i) = sum(hamTemplate'.*hamWinR',2)/sum(hamTemplate'.*hamTemplate',2);
end
negProduct = -cL.*cR;

%% Find potential REM
[locs, peaks] = findREMamplitude(negProduct,0.0005);

%% Monocular test
if PARAM.monocular == 1
    locs = locs((abs(sigLeft(locs)) > 23) & (abs(sigRight(locs)) > 23));
elseif PARAM.monocular == 0
    locs = locs((abs(sigLeft(locs)) > 23) | (abs(sigRight(locs)) > 23)); % NOTE: monocular threshold works better for some files!
else
    error('monocular criteria not correctly defined')
end
    
end