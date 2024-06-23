% Specify the folder where the images are located
folderPath = 'path_to_your_image_folder';

% Specify the new size for the images
newSize = [256, 256]; 
% Get a list of all the image files in the folder
imageFiles = dir(fullfile(folderPath, '*.png')); 

for i = 1:length(imageFiles)
    % Read the image
    img = imread(fullfile(folderPath, imageFiles(i).name));
    
    % Resize the image
    resizedImg = imresize(img, newSize);
    
    % Add noise to the image
    noisyImg = imnoise(resizedImg, 'gaussian');
    
    % Save the noisy image, overwriting the original file
    imwrite(noisyImg, fullfile(folderPath, imageFiles(i).name));
end

disp('All images have been resized and noise added.');
