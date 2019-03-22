clc;clear;

load('NeuralNetworkData.mat')

%%

for i = 1:62
    
    TF_1 = contains(char(folder_labels(i)),'_cap');
    TF_2 = contains(char(folder_labels(i)),'_small');
    
    if TF_1 == 1
        temp = char(folder_labels(i));
        newStr = split(temp,'_cap');
        temp2 = newStr(1);
        folder_labels(i) = temp2;
    end
    
    if TF_2 == 1
        temp = char(folder_labels(i));
        newStr = split(temp,'_small');
        temp2 = newStr(1);
        folder_labels(i) = temp2;
    end
    
end


save NeuralNetworkDataFinal class_t folder_labels label_Marix group HOG_feature_Matrix net