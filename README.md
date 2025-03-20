# detect_REMs

EEGLAB-compatible automatic rapid eye movement detection for REM sleep

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.  

## Prerequisites

Mac, PC and Linux compatible.  
Designed for use with EEGLAB 2019 or later (https://eeglab.org) on Matlab R2019a.  
For use on continuous EEGLAB datasets (*.set).  

Works best if recording includes (in the EEG.event structure):  
* sleep stage scoring in EEG.event structure
* Bad Data event markers (e.g., 'Movement') in EEG.event structure

## Installing

Simply unzip 'detectREMs' and add to Matlab path.  
Alternatively, unzip and move folder to '~/eeglab/plugins/' directory for EEGLAB GUI integration.
Available for download/install/update directly through EEGLAB GUI (recommended).

## Usage

* Loads an EEGlab PSG dataset
* Customize input parameters
* Run REM detection
* Outputs both CSV and MAT summary data files
    
## Authors

Stuart Fogel & Sleep Well
School of Psychology, University of Ottawa, Canada.  
uOttawa Sleep Research Laboratory.  

## Contact 

https://socialsciences.uottawa.ca/sleep-lab/  
https://www.sleepwellpsg.com  
sfogel@uottawa.ca  

## License

Copyright (C) Stuart Fogel & Sleep Well, 2022.  
See the GNU General Public License v3.0 for more information.

This file is part of 'detect_REMs'.
See https://github.com/stuartfogel/detect_REMs for details.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above author, license,
copyright notice, this list of conditions, and the following disclaimer.

2. Redistributions in binary form must reproduce the above author, license,
copyright notice, this list of conditions, and the following disclaimer in 
the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
THE POSSIBILITY OF SUCH DAMAGE.

Detect REMs is intended for research purposes only. Any commercial 
or medical use of this software and source code is strictly prohibited.
