% clear;clc;
%%

% HandwrittenDatasetPath = fullfile('.\dataset');

% HandwrittenData = imageDatastore(HandwrittenDatasetPath,...
%     'IncludeSubfolders',true,'LabelSource','foldernames');


%% Display some of the images in the datastore.

% figure;
% perm = randperm(30,20);
% for i = 1:20
%     subplot(4,5,i);
%     imshow(HandwrittenData.Files{perm(i)});
% end

%% Calculate the number of images in each category. 

% labelCount = countEachLabel(HandwrittenData);


%% You must specify the size of the images in the input layer of the network.
% Check the size of the first image in digitData.

% It is assumed that all the images have same size or dimensions

% img = readimage(HandwrittenData,16);
% size(img)

%% Specify Training and Validation Sets
% can be set according to the size of dataset

% trainNumFiles = 1000;
% [trainHandwrittenData,valHandwrittenData] = splitEachLabel(HandwrittenData,trainNumFiles,'randomize');

%% Define Network Architecture
% Define the convolution neural network architecture.

% For further understanding of the layers see the documentation of MATLAB

load tempdata

layers = [
	%  integer values [h w c], where h is the height, w is the width, and c is the number of channels
    imageInputLayer([128 128 3])		

	% layer = convolution2dLayer(filterSize,numFilters,Name,Value)
    convolution2dLayer(3,16,'Padding','same')
    batchNormalizationLayer
    reluLayer

	% layer = maxPooling2dLayer(poolSize,Name,Value)
    maxPooling2dLayer(2,'Stride',2)

    convolution2dLayer(3,32,'Padding','same')
    batchNormalizationLayer
    reluLayer

    maxPooling2dLayer(2,'Stride',2)

    convolution2dLayer(3,64,'Padding','same')
    batchNormalizationLayer
    reluLayer

	% layer = fullyConnectedLayer(outputSize)
    fullyConnectedLayer(62)
    softmaxLayer
    classificationLayer];

%% Specify Training Options

options = trainingOptions('sgdm',...
    'MaxEpochs',3, ...
    'ValidationData',valHandwrittenData,...
    'ValidationFrequency',3,...
    'Verbose',true,...
    'Plots','training-progress');

%% Train Network Using Training Data

Deep_Net = trainNetwork(trainHandwrittenData,layers,options);

save Deep_NeuralNet Deep_Net valHandwrittenData

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Classify Validation Images and Compute Accuracy

% predictedLabels = classify(Deep_Net,valHandwrittenData);
% valLabels = valHandwrittenData.Labels;

% accuracy = sum(predictedLabels == valLabels)/numel(valLabels)



















