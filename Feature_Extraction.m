clc;clear;close all;
%%

HOG_feature_Matrix = [];
label_Marix = [];
% folder_labels = {};
count = 0;

% imds = imageDatastore('.\dataset\','IncludeSubfolders',true,'FileExtensions','.png','LabelSource','foldernames');

folder_list = dir('.\dataset');

% Due to PC system constraints and to save time we will train for only first 100 samples in dataset
% if we need to train for complete dataset the replace 100 by
% length(files_per_folder) in the following code

for i = 3:length(folder_list)
    
    address = strcat('.\dataset\',folder_list(i).name,'\*.png');
    files_per_folder = dir(address);
    count = count+1;
    
    for j = 1:100
        
        clc;
        fprintf('Processing Folder: %s, File: %s\n',folder_list(i).name,files_per_folder(j).name);
        
        image_filename = strcat('.\dataset\',folder_list(i).name,'\',files_per_folder(j).name);
        
        img = imread(image_filename);
        img = imresize(img,[128,128]);
        
        [r,c,p] = size(img);
        
        % if input image is RGB then convert to gray
        
        if p>2
            imgray = rgb2gray(img);
        else
            imgray = img;
        end
        
        
        BW = imbinarize(imgray);
        subplot(1,4,1)
        imshow(BW)
        drawnow
        
        stats = regionprops(~BW,'BoundingBox');
        subplot(1,4,2)
        imshow(~BW)
        drawnow
        
        imgcroppedgray = imcrop(imgray,stats(1).BoundingBox);        
        imgcroppedgray = imresize(imgcroppedgray,[50,50]);
        
        
        [temp_features,temp_visual] = extractHOGFeatures(imgcroppedgray,'CellSize',[2 2]);
        
        subplot(1,4,3)
        imshow(imgcroppedgray);
        subplot(1,4,4)
        plot(temp_visual);
        
        drawnow
        
        [HOG_feature_Matrix] = [HOG_feature_Matrix;temp_features];
        [label_Marix] = [label_Marix;count];
        folder_labels{i-2} = folder_list(i).name;
        
    end
    
    
end

save HOG_Features_Data HOG_feature_Matrix label_Marix folder_labels

