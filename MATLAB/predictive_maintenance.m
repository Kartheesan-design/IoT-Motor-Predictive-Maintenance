%------------------------------- PREDICTIVE MAINTENANCE--------------------

%   Step 1: Import and Organize Data
%   Load your CSV file into MATLAB:

% Import the motor data
data = readtable('3phase_induction_motor_data.csv');

% View the first few rows
head(data)

% Check data dimensions
[numSamples, numFeatures] = size(data);
disp(['Total samples: ', num2str(numSamples)]);

%   Step 2: Preprocess the Data
%   Clean and prepare the data:

% Remove missing values
data = rmmissing(data);

% Separate features and labels
features = data(:, 2:11); % Voltage, Current, Temp, Vibration columns
labels = data.Motor_Status;

% Normalize the features (important for machine learning)
normalizedFeatures = normalize(table2array(features));

% Convert back to table with original variable names
normalizedData = array2table(normalizedFeatures, ...
    'VariableNames', features.Properties.VariableNames);


%   Handle time-series data:

% Convert timestamp to datetime if not already
data.Timestamp = datetime(data.Timestamp);

% Create time-series plot for visualization
figure;
subplot(3,1,1);
plot(data.Timestamp, data.Temperature_C);
title('Temperature vs Time');
ylabel('Temperature (°C)');

subplot(3,1,2);
plot(data.Timestamp, data.Vibration_X_mm_s);
title('Vibration X-axis vs Time');
ylabel('Vibration (mm/s)');

subplot(3,1,3);
plot(data.Timestamp, data.Current_R_Phase_A);
title('Current R-Phase vs Time');
ylabel('Current (A)');
xlabel('Time');


%   Step 3: Feature Extraction

% Extract statistical features from sensor data
featureTable = table();

% Calculate features for temperature
featureTable.Temp_Mean = mean(data.Temperature_C);
featureTable.Temp_Std = std(data.Temperature_C);
featureTable.Temp_RMS = rms(data.Temperature_C);
featureTable.Temp_Peak = max(data.Temperature_C);
featureTable.Temp_Kurtosis = kurtosis(data.Temperature_C);
featureTable.Temp_Skewness = skewness(data.Temperature_C);

% Calculate features for vibration
featureTable.Vib_X_Mean = mean(data.Vibration_X_mm_s);
featureTable.Vib_X_RMS = rms(data.Vibration_X_mm_s);
featureTable.Vib_X_Peak = max(data.Vibration_X_mm_s);

% Calculate voltage imbalance (CORRECTED)
voltageMatrix = [data.Voltage_R_Phase_V, data.Voltage_Y_Phase_V, data.Voltage_B_Phase_V];
voltageImbalancePerSample = std(voltageMatrix, 0, 2);
featureTable.Voltage_Imbalance_Mean = mean(voltageImbalancePerSample);
featureTable.Voltage_Imbalance_Max = max(voltageImbalancePerSample);

% Calculate current imbalance (CORRECTED)
currentMatrix = [data.Current_R_Phase_A, data.Current_Y_Phase_A, data.Current_B_Phase_A];
currentImbalancePerSample = std(currentMatrix, 0, 2);
featureTable.Current_Imbalance_Mean = mean(currentImbalancePerSample);
featureTable.Current_Imbalance_Max = max(currentImbalancePerSample);

% Display the results
disp(featureTable);



% Create high-frequency vibration data (simulating accelerometer)
Fs = 10000; % 10 kHz sampling rate
duration = 1; % 1 second
t = 0:1/Fs:duration-1/Fs;

% Motor parameters
rpm = 1500; % Motor speed
f_rotor = rpm/60; % Rotor frequency = 25 Hz

% Bearing fault frequencies (calculated from bearing geometry)
BPFO = 3.5 * f_rotor; % Outer race fault
BPFI = 5.5 * f_rotor; % Inner race fault
BSF = 2.3 * f_rotor;  % Ball fault
FTF = 0.4 * f_rotor;  % Cage fault

% Simulate vibration signal
Vib_normal = 0.1 * randn(size(t)); % Background noise
Vib_rotor = 0.05 * sin(2*pi*f_rotor*t); % Rotor imbalance

% Add bearing fault (outer race)
Vib_fault = 0.02 * sin(2*pi*BPFO*t); % BPFO signature

% Total vibration
Vib_total = Vib_normal + Vib_rotor + Vib_fault;

% Apply FFT
L = length(Vib_total);
Y = fft(Vib_total);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:(L/2))/L;

% Plot
figure;
plot(f, P1);
xlim([0 500]); % Focus on 0-500 Hz
title('Vibration FFT - Bearing Outer Race Fault Detected');
xlabel('Frequency (Hz)');
ylabel('Acceleration (g)');
grid on;

% Mark fault frequencies
hold on;
xline(BPFO, 'r--', 'LineWidth', 2, 'Label', 'BPFO');
xline(2*BPFO, 'r:', 'LineWidth', 1, 'Label', '2x BPFO');
xline(3*BPFO, 'r:', 'LineWidth', 1, 'Label', '3x BPFO');
hold off;


% Create high-frequency current data (simulating AC waveform)
%% Motor Current FFT Analysis
Fs = 10000; % 10 kHz sampling
duration = 1; % 1 second
t = 0:1/Fs:duration-1/Fs;

% Motor parameters
f_supply = 50; % Hz
slip = 0.03; % 3% slip
f_rotor = f_supply * (1 - slip); % 48.5 Hz

% Generate current signal with fault
I_fundamental = 20 * sin(2*pi*f_supply*t);
I_3rd_harmonic = 2 * sin(2*pi*3*f_supply*t);
I_5th_harmonic = 1 * sin(2*pi*5*f_supply*t);

% Add broken rotor bar fault signature
I_brb_lower = 0.5 * sin(2*pi*(f_supply - 2*slip*f_supply)*t); % 47 Hz
I_brb_upper = 0.5 * sin(2*pi*(f_supply + 2*slip*f_supply)*t); % 53 Hz

% Total current
I_total = I_fundamental + I_3rd_harmonic + I_5th_harmonic + ...
          I_brb_lower + I_brb_upper + randn(size(t))*0.1;

% FFT
L = length(I_total);
Y = fft(I_total);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:(L/2))/L;

% Plot
figure('Name', 'Motor Current FFT Analysis');
subplot(2,1,1);
plot(t(1:1000), I_total(1:1000)); % First 100ms
title('Time-Domain Current Signal');
xlabel('Time (s)');
ylabel('Current (A)');
grid on;

subplot(2,1,2);
plot(f, P1);
xlim([0 300]);
title('Frequency-Domain Current Spectrum');
xlabel('Frequency (Hz)');
ylabel('Amplitude (A)');
grid on;

% Mark important frequencies
hold on;
xline(f_supply, 'g-', 'LineWidth', 2, 'Label', 'Fundamental (50Hz)');
xline(f_supply - 2*slip*f_supply, 'r--', 'LineWidth', 2, 'Label', 'BRB Lower (47Hz)');
xline(f_supply + 2*slip*f_supply, 'r--', 'LineWidth', 2, 'Label', 'BRB Upper (53Hz)');
xline(150, 'b:', 'Label', '3rd Harmonic');
xline(250, 'b:', 'Label', '5th Harmonic');
hold off;


%% Extract FFT Features for Machine Learning
function features = extractFFTFeatures(signal, Fs, freq_bands)
    % Apply FFT
    L = length(signal);
    Y = fft(signal);
    P2 = abs(Y/L);
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
    f = Fs*(0:(L/2))/L;
    
    % Extract features
    features = struct();
    
    % 1. Peak amplitude at fundamental (50 Hz)
    [~, idx_fund] = min(abs(f - 50));
    features.Fund_Amplitude = P1(idx_fund);
    
    % 2. Sideband amplitudes (for broken rotor bar)
    [~, idx_lower] = min(abs(f - 47));
    [~, idx_upper] = min(abs(f - 53));
    features.BRB_Lower = P1(idx_lower);
    features.BRB_Upper = P1(idx_upper);
    features.BRB_Ratio = (P1(idx_lower) + P1(idx_upper)) / P1(idx_fund);
    
    % 3. Harmonic ratios (for power quality)
    [~, idx_3rd] = min(abs(f - 150));
    [~, idx_5th] = min(abs(f - 250));
    features.THD_3rd = P1(idx_3rd) / P1(idx_fund);
    features.THD_5th = P1(idx_5th) / P1(idx_fund);
    
    % 4. Energy in frequency bands
    for i = 1:length(freq_bands)-1
        band_name = ['Energy_' num2str(freq_bands(i)) '_' num2str(freq_bands(i+1)) 'Hz'];
        idx_band = (f >= freq_bands(i)) & (f < freq_bands(i+1));
        features.(band_name) = sum(P1(idx_band).^2);
    end
    
    % 5. Spectral entropy (measure of disorder)
    features.Spectral_Entropy = -sum((P1/sum(P1)) .* log2(P1/sum(P1) + eps));
    
    % 6. Peak frequency
    [~, idx_peak] = max(P1);
    features.Peak_Frequency = f(idx_peak);
end

% Usage example
freq_bands = [0 25 50 100 200 500]; % Define frequency bands
current_features = extractFFTFeatures(I_total, Fs, freq_bands);
vib_features = extractFFTFeatures(Vib_total, Fs, freq_bands);

% Display features
disp('Current FFT Features:');
disp(current_features);
disp('Vibration FFT Features:');
disp(vib_features);



% Split data into training (80%) and testing (20%)
cv = cvpartition(labels, 'HoldOut', 0.2);
idxTrain = training(cv);
idxTest = test(cv);

% Training data
trainFeatures = normalizedData(idxTrain, :);
trainLabels = labels(idxTrain);

% Testing data
testFeatures = normalizedData(idxTest, :);
testLabels = labels(idxTest);




%% Step 5: Train Machine Learning Models

% IMPORTANT: Convert labels to categorical FIRST
data.Motor_Status = categorical(data.Motor_Status);

% Separate features and labels
features = data(:, 2:11); % Voltage, Current, Temp, Vibration columns
labels = data.Motor_Status; % Now categorical

% Normalize the features
normalizedFeatures = normalize(table2array(features));
normalizedData = array2table(normalizedFeatures, ...
    'VariableNames', features.Properties.VariableNames);

% Split data into training (80%) and testing (20%)
cv = cvpartition(labels, 'HoldOut', 0.2);
idxTrain = training(cv);
idxTest = test(cv);

% Training data
trainFeatures = normalizedData(idxTrain, :);
trainLabels = labels(idxTrain);

% Testing data
testFeatures = normalizedData(idxTest, :);
testLabels = labels(idxTest);

% Convert table to array for model training
trainFeaturesArray = table2array(trainFeatures);
testFeaturesArray = table2array(testFeatures);



%%  Random Forest (Ensemble)
ensembleMdl = fitcensemble(trainFeaturesArray, trainLabels, 'Method', 'Bag');
ensemblePredictions = predict(ensembleMdl, testFeaturesArray);
ensembleAccuracy = sum(ensemblePredictions == testLabels) / length(testLabels);
disp(['Random Forest Accuracy: ', num2str(ensembleAccuracy * 100), '%']);

%% Display Confusion Matrix

figure;
confusionchart(testLabels, ensemblePredictions);
title('Random Forest');

% Create degradation model for temperature-based RUL
% Assume failure threshold = 80°C

% Extract degradation data for training
degradationData = data(data.Motor_Status ~= 'Normal', :);

% Fit exponential degradation model
mdl = exponentialDegradationModel('theta', 0.5, 'beta', 1, ...
    'thetaVariance', 0.1, 'betaVariance', 0.1);





%% Simple RUL Estimation Without Predictive Maintenance Toolbox

% Get degradation data (Warning and Critical samples)
degradationData = data(data.Motor_Status ~= 'Normal', :);

% Convert time to numeric (minutes from start)
timeNumeric = minutes(degradationData.Timestamp - degradationData.Timestamp(1));

% Extract temperature
temperature = degradationData.Temperature_C;

% Fit linear degradation model: Temp = a*Time + b
p = polyfit(timeNumeric, temperature, 1);
a = p(1); % Slope (°C per minute)
b = p(2); % Intercept

disp('=== Linear Degradation Model ===');
disp(['Temperature Rise Rate: ', num2str(a), ' °C/minute']);
disp(['Initial Temperature: ', num2str(b), ' °C']);

% Current state
currentTime = timeNumeric(end);
currentTemp = temperature(end);

% Failure threshold
failureThreshold = 80; % °C

% Calculate RUL
% RUL = (Threshold - CurrentTemp) / RiseRate
if a > 0
    estimatedRUL = (failureThreshold - currentTemp) / a;
    timeToFailure = currentTime + estimatedRUL;
    
    disp(' ');
    disp('=== RUL Prediction ===');
    disp(['Current Temperature: ', num2str(currentTemp, '%.2f'), ' °C']);
    disp(['Failure Threshold: ', num2str(failureThreshold), ' °C']);
    disp(['Estimated RUL: ', num2str(estimatedRUL, '%.2f'), ' minutes']);
    disp(['Estimated RUL: ', num2str(estimatedRUL/60, '%.2f'), ' hours']);
    disp(['Predicted Failure Time: ', num2str(timeToFailure, '%.2f'), ' minutes from start']);
else
    disp('Temperature is not increasing. No imminent failure predicted.');
end

% Plot degradation and prediction
figure('Name', 'Temperature Degradation and RUL Prediction');
plot(timeNumeric, temperature, 'bo-', 'LineWidth', 2, 'MarkerSize', 6);
hold on;

% Plot fitted line
timeFit = linspace(0, timeToFailure * 1.2, 100);
tempFit = a * timeFit + b;
plot(timeFit, tempFit, 'r--', 'LineWidth', 2);

% Plot failure threshold
yline(failureThreshold, 'k--', 'LineWidth', 2, 'Label', 'Failure Threshold');

% Mark current state and predicted failure
plot(currentTime, currentTemp, 'gs', 'MarkerSize', 15, 'LineWidth', 3, ...
    'DisplayName', 'Current State');
plot(timeToFailure, failureThreshold, 'rx', 'MarkerSize', 15, 'LineWidth', 3, ...
    'DisplayName', 'Predicted Failure');

xlabel('Time (minutes)');
ylabel('Temperature (°C)');
title('Motor Temperature Degradation and RUL Prediction');
legend('Observed Data', 'Linear Fit', 'Failure Threshold', ...
       'Current State', 'Predicted Failure', 'Location', 'northwest');
grid on;
hold off;



% After training your Random Forest model
ensemblePredictions = predict(ensembleMdl, testFeaturesArray);

% Get confusion matrix
confMat = confusionmat(testLabels, ensemblePredictions);

% Get class names
classNames = categories(testLabels);

% Calculate metrics for each class
fprintf('\n=== Per-Class Performance Metrics ===\n');
for i = 1:length(classNames)
    TP = confMat(i,i);
    FP = sum(confMat(:,i)) - TP;
    FN = sum(confMat(i,:)) - TP;
    TN = sum(confMat(:)) - TP - FP - FN;
    
    % Calculate metrics with checks for division by zero
    if (TP + FP) > 0
        precision = TP / (TP + FP);
    else
        precision = NaN; % No predicted positives for this class
    end
    
    if (TP + FN) > 0
        recall = TP / (TP + FN);
    else
        recall = NaN; % No actual positives for this class
    end
    
    if ~isnan(precision) && ~isnan(recall) && (precision + recall) > 0
        f1Score = 2 * (precision * recall) / (precision + recall);
    else
        f1Score = NaN;
    end
    
    fprintf('\n%s Class:\n', classNames{i});
    fprintf('  TP=%d, FP=%d, FN=%d, TN=%d\n', TP, FP, FN, TN);
    if ~isnan(precision)
        fprintf('  Precision: %.2f%%\n', precision * 100);
    else
        fprintf('  Precision: N/A (no predictions for this class)\n');
    end
    if ~isnan(recall)
        fprintf('  Recall: %.2f%%\n', recall * 100);
    else
        fprintf('  Recall: N/A (no actual samples for this class)\n');
    end
    if ~isnan(f1Score)
        fprintf('  F1-Score: %.2f%%\n', f1Score * 100);
    else
        fprintf('  F1-Score: N/A\n');
    end
end

% Calculate overall accuracy
overallAccuracy = sum(diag(confMat)) / sum(confMat(:));
fprintf('\nOverall Accuracy: %.2f%%\n', overallAccuracy * 100);

