clc;clear;warning off all;close all;
load HOG_Features_Data;

%%
group = label_Marix';

class = zeros(numel(unique(group)),numel(group'));      

for i = 1:numel(unique(group))
    class(i,:) = group == i;    
end

class_t = class';

save Neural_Net_features class_t folder_labels label_Marix group HOG_feature_Matrix

