% This function is made using nnstart
%
%   The imput parameters are
%
%     test_data           : test features
%     train_data          : train features
%     train_target_label  : train labels
%     plots_on_off        : 'on' to show plots
%
%   The output parameter is test label

function [label,label_text] = nnclassify(test_data, folder_labels, net)

% load NeuralNetworkDataFinal

test = net(test_data');
label = vec2ind(test);

label_text = char(folder_labels(label));

end