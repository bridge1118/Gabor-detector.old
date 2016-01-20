close all;clear all;clc

numElementLimit = 15;
imNum = 131;
deformedTemplates = cell(imNum, numElementLimit);

for idx = 1 : numElementLimit
    templates(idx) = load(['/Users/ful6ru04/Desktop/deformedTemplate' ...
        num2str(idx) '.mat']);
    
    if idx == 1 
        for img = 1 : imNum
            deformedTemplates{img, idx} = ...
                templates(idx).deformedTemplate{img};
        end
        continue;
    end
    
    for img = 1 : imNum
        deformedTemplates{img, idx} = ...
            templates(idx).deformedTemplate{img} - ...
            templates(idx-1).deformedTemplate{img};
    end
end

save '/Users/ful6ru04/Desktop/deformedTemplates.mat' deformedTemplates