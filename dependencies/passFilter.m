function [y,N,B,A]= passFilter(x,fs,fc,type,attentuation)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% [y,N,B,A]= passFilter(x,fs,fc,type,attentuation)
%
% This function uses an elliptical filter to filter out high frequencies
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

% [y,N,B,A] = lowpass(x,fs,fc)
%
% Variable Definition:
% x: Input signal
% fs: Input signal sampling frequency in Hz
% fc: cutoff frequency
%
% y: Filtered signal (output)
% N: Filter order
% B: Feedforward (FIR) coefficients
% A: Feedback (IIR) coefficients
Rp = 0.5;   % Ripple in dB (passband)
Rs = attentuation;    % Attenuation
mf = fs/2;  % Maximum frequency
Wp = fc/mf; % Cuttoff frequency
Ws = 1.2 * Wp; %Stopband frequency
% First, determine the minimum filter order to meet specifics
[N,Wn] = ellipord(Ws,Wp,Rp,Rs);
% Next, Design the filter (find the coefficients)
[B,A] = ellip(N,Rp,Rs,Wn,type);
% Now, apply the filter (filter the signal)
y = filtfilt(B,A,x);
% Plot the filter
%figure('Color',[1 1 1]);
%freqz(B,A,2^14,fs);