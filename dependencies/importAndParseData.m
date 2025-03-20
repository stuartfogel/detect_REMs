function [dataSet] = importAndParseData(EEG,PARAM,startREM,endREM)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% [dataSet] = importAndParseData(EEG,PARAM,startREM,endREM)
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

%% Setup
settings.SAMPLE_RATE = EEG.srate; % Sample Rate
settings.SAMPLING_MULTIPLIER = 200; % x2 times 100 for some reason from scoring programs output
settings.LOW_FILTER_CUTOFF_FREQ = 5;
settings.HIGH_FILTER_CUTOFF_FREQ = .3;
settings.FILTER_ATENUATION = 40; % dB
settings.SAME_TIME_SEC = 0.120; % the time differnece we call 'same rem' by other raters (120ms)
settings.WIN_SIZE_SECS = 1; % window size in secs
settings.WIN_SIZE = round(settings.SAMPLE_RATE*settings.WIN_SIZE_SECS); % win size in samples
settings.WIN_OVERLAP_FRACTION = 0; % percentage of window overlap
settings.WIN_OVERLAP = round(settings.WIN_OVERLAP_FRACTION*settings.WIN_SIZE); % window overlab in samples (both sides)
settings.CENTER_PERIOD = settings.WIN_SIZE-settings.WIN_OVERLAP; % the amount of samples between each windows center

% if missing or zero, will run on whole period
if ~exist('startREM','var') || startREM == 0
   startREM = 1; 
end
if ~exist('endREM','var') || endREM == 0 || endREM > length(EEG.data)
    endREM = length(EEG.data);
end

% check for EOG channels labels
if ischar(PARAM.locChannel)
    locChannelNum = find(strcmp(PARAM.locChannel,{EEG.chanlocs.labels}));
else
    locChannelNum = PARAM.locChannel;
end
if ischar(PARAM.rocChannel)
    rocChannelNum = find(strcmp(PARAM.rocChannel,{EEG.chanlocs.labels}));
else
    rocChannelNum = PARAM.rocChannel;
end

%% Filter
psgTemp1L = passFilter(EEG.data(locChannelNum,startREM:endREM),settings.SAMPLE_RATE,settings.LOW_FILTER_CUTOFF_FREQ,'low',settings.FILTER_ATENUATION); % 20Hz cutoff filter
psgTemp1R = passFilter(EEG.data(rocChannelNum,startREM:endREM),settings.SAMPLE_RATE,settings.LOW_FILTER_CUTOFF_FREQ,'low',settings.FILTER_ATENUATION);
psgTemp2L = passFilter(psgTemp1L,settings.SAMPLE_RATE,settings.HIGH_FILTER_CUTOFF_FREQ,'high',settings.FILTER_ATENUATION); % 0.5Hz cutoff highpass filter
psgTemp2R = passFilter(psgTemp1R,settings.SAMPLE_RATE,settings.HIGH_FILTER_CUTOFF_FREQ,'high',settings.FILTER_ATENUATION);
psgChannelDataL = psgTemp2L;
psgChannelDataR = psgTemp2R;

%% Create windows (of raw data and scores)
numSamples = length(psgChannelDataL); % total number of samples
% Extract features of interest and return threshholded results from raw data
numWindows = floor(numSamples/(settings.WIN_SIZE-settings.WIN_OVERLAP));
featureWindowsIndex = cell(1,numWindows-1);
psgWindowData = cell(2,numWindows-1);
psgWindowFreqData = cell(3,numWindows-1);
for winIndex = 1:numWindows-1
    winStart = (winIndex-1)*settings.CENTER_PERIOD+1; % the start of a window in samples
    winEnd = ((winIndex-1)*settings.CENTER_PERIOD)+settings.WIN_SIZE+1;
    psgWindowData{1,winIndex} = psgChannelDataL(winStart:winEnd)-mean(psgChannelDataL(winStart:winEnd)); % remove DC offset
    psgWindowData{2,winIndex} = psgChannelDataR(winStart:winEnd)-mean(psgChannelDataR(winStart:winEnd));
    psgWindowData{3,winIndex} = (-psgWindowData{1,winIndex}).*psgWindowData{2,winIndex};
    psgWindowFreqData{1,winIndex} = fft(psgWindowData{1,winIndex});
    psgWindowFreqData{2,winIndex} = fft(psgWindowData{2,winIndex});
    psgWindowFreqData{3,winIndex} = fft(psgWindowData{3,winIndex});
    featureWindowsIndex{winIndex} = [winStart:winEnd];
end

%% Tidy and output
dataSet.rawTimeData = [EEG.data(locChannelNum,startREM:endREM); EEG.data(rocChannelNum,startREM:endREM)];
dataSet.timeData = psgWindowData;
dataSet.freqData = psgWindowFreqData;
dataSet.winIndexData = featureWindowsIndex;
dataSet.settings = settings;

end
