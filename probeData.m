
function probeData(varargin)

settings = deal(varargin{1});
fileNameStr = settings.fileName;

%% Generate plot of raw data ==============================================
[fid, ~] = fopen(fileNameStr, 'rb');
fseek(fid, settings.skipNumberOfBytes, 'bof');

% Find number of samples per spreading code
samplesPerCode = round(settings.samplingFreq / ...
(settings.codeFreqBasis / settings.codeLength));

% Read 100ms of signal
dataAdaptCoeff=2;
data = fread(fid, [1, dataAdaptCoeff*100*samplesPerCode], settings.dataType);

fclose(fid);

%--- Initialization ---------------------------------------------------

timeScale = 0 : 1/settings.samplingFreq : 5e-3;

%--- Time domain plot -------------------------------------------------
data=data(1:2:end) + i .* data(2:2:end);
figure(1)
hold on
plot(1000 * timeScale(1:round(samplesPerCode/50)), ...
real(data(1:round(samplesPerCode/50))));

axis tight;    grid on;
title ('Time domain plot (I)');
xlabel('Time (ms)'); ylabel('Amplitude');

plot(1000 * timeScale(1:round(samplesPerCode/50)), ...
imag(data(1:round(samplesPerCode/50))));

axis tight;    grid on;
title ('Time domain plot (I/Q)');
xlabel('Time (ms)'); ylabel('Amplitude');

%--- Frequency domain plot --------------------------------------------
[sigspec,freqv]=pwelch(data, 32758, 2048, 16368, settings.samplingFreq,'twosided');
figure(2)
plot(([-(freqv(length(freqv)/2:-1:1));...
    freqv(1:length(freqv)/2)])/1e6, 10*log10([sigspec(length(freqv)/2+1:end);...
    sigspec(1:length(freqv)/2)]));
% plot(freqv,10*log10(sigspec));



grid on;
title ('Frequency domain plot');
xlabel('Frequency (MHz)'); ylabel('Magnitude');

figure(3)
spectrogram(data,'yaxis')

end 
