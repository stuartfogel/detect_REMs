function vers = eegplugin_detect_REMs(fig, trystrs, catchstrs)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% eegplugin_detect_REMs() - EEGLAB plugin for deteting rapid eye movements 
% in REM sleep. 
%
% Usage:
%   >> eegplugin_detect_REMs(fig, trystrs, catchstrs)
%
% Inputs:
%   fig        - [integer] EEGLAB figure.
%   trystrs    - [struct] "try" strings for menu callbacks.
%   catchstrs  - [struct] "catch" strings for menu callbacks. 
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

% version
vers = '1.0';

% handle input arguments from EEGLAB
if nargin < 3
    error('eegplugin_detect_REMs requires 3 arguments');
end

% add plugin folder to path
if exist('pop_detect_REMs.m','file')
    p = which('eegplugin_detect_REMs');
    p = p(1:findstr(p,'eegplugin_detect_REMs.m')-1);
    addpath(p);
end

% find tools menu
menu = findobj(fig, 'tag', 'tools');

% menu callbacks
detect_REMs_cback = [trystrs.no_check '[EEG,LASTCOM] = pop_detect_REMs(EEG);' catchstrs.add_to_hist trystrs.no_check '[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET);eeglab redraw;' catchstrs.add_to_hist];

% create menu
uimenu(menu, 'Label', 'Detect Rapid Eye Movements', 'CallBack', detect_REMs_cback);