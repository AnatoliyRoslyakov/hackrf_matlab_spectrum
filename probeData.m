clear; close all; clc;
%% Входные данные ==============================================
skipNumberOfBytes     = 10000;
fileNameStr = 'D:\GitHubSkillBox\hackrf_matlab_spectrum\1.bin';
fileNameStr2 = 'D:\GitHubSkillBox\hackrf_matlab_spectrum\1.bin';
dataType           = 'schar';

samplingFreq       = 40e6/2;  %Гц
codeFreqBasis      = 0.5115e6;      %Гц
numberSamples      = samplingFreq/10;

%% Открытие, чтение данных ===============================================
[fid, ~] = fopen(fileNameStr, 'rb');
fseek(fid, skipNumberOfBytes, 'bof');

[fid2, ~] = fopen(fileNameStr2, 'rb');
fseek(fid2, skipNumberOfBytes+1000000, 'bof'); % <--- проверка ВКФ(убрать + 100..)

% Чтение 1/10 от всего кол-ва сэмплов
dataAdaptCoeff=2;
data = fread(fid, [1, numberSamples], dataType);
data2 = fread(fid2, [1, numberSamples], dataType);
fclose(fid); fclose(fid2);

%% Временная область =====================================================
data=data(1:2:end) + 1i .* data(2:2:end);
data2=data2(1:2:end) + 1i .* data2(2:2:end);
timeScale = 1 : 1 : numberSamples;

%% Частотная область =====================================================
[sigspec,freqv]=pwelch(data, 32758, 2048, 16368, samplingFreq,'twosided');
[sigspec2,freqv2]=pwelch(data2, 32758, 2048, 16368, samplingFreq,'twosided');

%% Оценка мощности сигнала в полосе ======================================
power_in_band = bandpower(sigspec);
power_in_band2 = bandpower(sigspec2);
% Мощность сигнала в определенной полосе
% power_in_band = bandpower(sigspec,samplingFreq,[0, 10e6])

%% Коэффициент взаимной корреляции ======================================
% Вычисление взаимной корреляции
[r, lags] = xcorr(data, data2, 'normalized');

%% Вывод результатов =====================================================
%--- График временной области --------------------------------------------
figure(1)
hold on
plot(timeScale(1:1e4), real(data(1:1e4)));
plot(timeScale(1:1e4), imag(data(1:1e4)));

axis auto;    grid on;
title ('График временной области (I/Q)');
xlabel('Отсчеты'); ylabel('Амплитуда');

%--- График частотной области --------------------------------------------
figure(2)
hold on
plot(([-(freqv(length(freqv)/2:-1:1));...
    freqv(1:length(freqv)/2)])/1e6, 10*log10([sigspec(length(freqv)/2+1:end);...
    sigspec(1:length(freqv)/2)]));

plot(([-(freqv2(length(freqv2)/2:-1:1));...
    freqv2(1:length(freqv2)/2)])/1e6, 10*log10([sigspec2(length(freqv2)/2+1:end);...
    sigspec2(1:length(freqv2)/2)]));

grid on;
legend('Ant-left', 'Ant-right');
title ('График частотной области');
xlabel('Частота (МГц)'); ylabel('Мощность дБм');

%--- График взаимной корреляции ------------------------------------------
figure(3)
plot(lags, r);
grid on;
title('Взаимная корреляция двух сигналов');
xlabel('Лаг'); ylabel('Коэффициент корреляции');

%-------------------------------------------------------------------------
disp(['Взаимный коэффициент корреляции: ' num2str(real(max(r)))]);
disp(['Средняя мощность в полосе-1 0-20 МГц: ' num2str(power_in_band) ' Вт/Гц']);
disp(['Средняя мощность в полосе-2 0-20 МГц: ' num2str(power_in_band2) ' Вт/Гц']);

if power_in_band - power_in_band2 > 0.05
    disp('Объект излучения находится: ЛЕВЕЕ');
elseif power_in_band - power_in_band > 0.05
    disp('Объект излучения находится: ПРАВЕЕ');
else
    disp('Объект излучения находится: ПО ЦЕНТРУ');
end



%% Пример взят с интернета, все константы рандом, но если поднастроить, то норм
c = 3e8; % скорость света (м/с)
Pt = 1e3; % мощность излучаемого сигнала (в Вт)
Gt = 10^(10/10); % коэффициент усиления антенны передатчика (в дБ)
Gr = 10^(15/10); % коэффициент усиления антенны приёмника (в дБ)
sigma = 0.1; % эффективная площадь рассеяния объекта (в м^2)
L = 2; % потери на расстоянии 1 метр (в дБ)

% Загрузка данных
% предполагаем, что сигнал уже записан в файл 'signal.mat'
t = (0:length(data)-1)/samplingFreq; % время дискретизации сигнала

% Оценка мощности принимаемого сигнала
noise_power = 1e-10; % мощность шума (в Вт/Гц)
R = abs(data); % амплитуда сигнала (в вольтах)
Pn = bandpower(R.^2); % мощность шума (в Вт)
Pr = Pn + Gt + Gr - L; % мощность принимаемого сигнала (в Вт)

% Вычисление расстояния до объекта
R0 = 1; % расстояние до объекта при котором мощность сигнала равна Pt (в метрах)
R = sqrt(Pt*Gt*Gr*sigma./(Pr*(4*pi)^3*R0^4)); % расстояние до объекта (в метрах)

% Вывод результата
disp(['Расстояние до объекта: ' num2str(R) ' м']);
