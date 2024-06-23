%% Load Image Data
    % Set the path to the folder containing images
    dataPath = fullfile(matlabroot, "Path to specific folder");

    % Create an imageDatastore object to manage the image data
    imds = imageDatastore(dataPath);

%% Display Sample Images
    % Display 20 random images from the dataset to verify the data
    figure;
    perm = randperm(1500, 20); % Randomly select 20 images from 1500
    for i = 1:20
        subplot(4, 5, i); % Create a subplot for each image
        imshow(imds.Files{perm(i)}); % Display the image
    end

%% Count and Display Labels
    % Count the number of images for each label
    labelCount = countEachLabel(imds);
    disp(labelCount); % Display the label count

%% Read and Display Image Size
    % Read an image from the datastore
    img = readimage(imds, 3);

    % Display the size of the image
    imgSize = size(img);
    disp(imgSize);

%% Split Data into Training and Validation Sets
    % Specify the number of training files
    trainFiles = 500;

    % Split the data into training and validation sets
    [imdsTrain, imdsValidation] = splitEachLabel(imds, trainFiles, 'randomized');

%% Define the Network Architecture
    % Define the layers of the convolutional neural network
    layers = [
        imageInputLayer([28, 28, 3]) % Input layer
        convolution2dLayer(3, 8, 'Padding', 'same') % Convolutional layer
        batchNormalizationLayer % Batch normalization layer
        reluLayer % ReLU activation layer
        fullyConnectedLayer(10) % Fully connected layer
        softmaxLayer % Softmax layer
        classificationLayer]; % Classification layer

%% Set Training Options
    % Set the training options
    options = trainingOptions('sgdm', ...
        'InitialLearnRate', 0.01, ... % Initial learning rate
        'MaxEpochs', 4, ... % Number of epochs
        'Shuffle', 'every-epoch', ... % Shuffle the data every epoch
        'ValidationData', imdsValidation, ... % Validation data
        'ValidationFrequency', 30, ... % Validation frequency
        'Verbose', false, ... % Suppress verbose output
        'Plots', 'training-progress'); % Display training progress plot

%% Train the Network
    % Train the network using the specified layers and options
    net = trainNetwork(imdsTrain, layers, options);

%% Evaluate the Network
    % Classify the validation images using the trained network
    YPred = classify(net, imdsValidation);

% Get the true labels of the validation images
    YValidation = imdsValidation.Labels;

% Calculate and display the accuracy of the network
    accuracy = sum(YPred == YValidation) / numel(YValidation);
    disp("Validation Accuracy: " + accuracy);
