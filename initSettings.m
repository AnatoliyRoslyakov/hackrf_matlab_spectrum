function settings = initSettings()

settings.skipNumberOfSamples     = 0*8.1838e6;
settings.skipNumberOfBytes     = 0;
settings.fileName = 'C:\Program Files\korr\1.bin';
settings.dataType           = 'schar';

settings.samplingFreq       = 40e6/2;  %[Hz]
settings.codeFreqBasis      = 0.5115e6;      %[Hz]


% Define number of chips in a code period
settings.codeLength         = 2046;

