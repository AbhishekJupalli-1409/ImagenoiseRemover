%% Initialization
    % Clear command window and workspace
    clc
    clear all

    % Select an image file using a file dialog
    [filename, pathname] = uigetfile('*.*','Pick a Matlab code file');

    % Read the selected image
    X1 = imread([pathname filename]);
    X2 = X1;
    imshow(X1)
    title('Original')

    % Get image dimensions
    [M, N, C] = size(X1);

    % Initialize sample image with mid-gray values
    sample = 0.5 * ones([M, N]);

    % Get noise ratio input from user
    percentage = input('Enter noise ratio : ');

    % Add salt and pepper noise to sample image
    sample2 = imnoise(sample, 'salt & pepper', percentage);

    % Convert image to double for processing
    X2 = double(X2);

%% Add Random-Valued Impulse Noise - Correlated
    for i = 1:M
        for j = 1:N
            location = randperm(4);
            if location(1) == 1
                if sample2(i,j) == 0
                    X2(i,j,1) = 0;
                elseif sample2(i,j) == 1
                    X2(i,j,1) = 255;
                end
            elseif location(1) == 2
                if sample2(i,j) == 0 || sample2(i,j) == 1
                    X2(i,j,2) = 255 * rand(1);
                end
            elseif location(1) == 3
                if sample2(i,j) == 0 || sample2(i,j) == 1
                    X2(i,j,3) = 255 * rand(1);
                end 
            elseif location(1) == 4
                if sample2(i,j) == 0 || sample2(i,j) == 1
                    X2(i,j,1) = 255 * rand(1);
                    X2(i,j,2) = 255 * rand(1);
                    X2(i,j,3) = 255 * rand(1);
                end 
            end
        end
    end

%% Add Additional Noise Patterns
    for i = 1:M
        for j = 1:N
            location1 = randperm(4);
            if location1(1) == 1
                if sample2(i,j) == 0
                    X2(i,j,2) = 0;
                    X2(i,j,3) = 0;
                elseif sample2(i,j) == 1
                    X2(i,j,2) = 255;
                    X2(i,j,3) = 255;
                end
            elseif location1(1) == 2
                if sample2(i,j) == 0 || sample2(i,j) == 1
                    X2(i,j,1) = 255 * rand(1);
                    X2(i,j,3) = 255 * rand(1);
                end
            elseif location1(1) == 3
                if sample2(i,j) == 0 || sample2(i,j) == 1
                    X2(i,j,1) = 255 * rand(1);
                    X2(i,j,2) = 255 * rand(1);
                end 
            end
        end
    end

    % Display the noisy image
    figure
    imshow(uint8(X2))
    title('Noise')

%% Vector Median Filtering
    X3 = X2;
    X3 = double(X3);
    cont = 0;
    while cont == 0
        tic
        for i = 2:M-1
            for j = 2:N-1
                P1 = X3(i,j,1); P2 = X3(i,j,2); P3 = X3(i,j,3);
                neighbors = [...
                    X3(i-1,j-1,:), X3(i,j-1,:), X3(i+1,j-1,:); ...
                    X3(i-1,j,:),   X3(i+1,j,:); ...
                    X3(i-1,j+1,:), X3(i,j+1,:), X3(i+1,j+1,:)];

                P1 = [P1; neighbors(:,:,1)];
                P2 = [P2; neighbors(:,:,2)];
                P3 = [P3; neighbors(:,:,3)];
                
                % Calculate distance metric
                d1 = zeros(1,9);
                for m = 1:9
                    for n = 1:9
                        d1(m) = d1(m) + abs(P1(m) - P1(n)) + abs(P2(m) - P2(n)) + abs(P3(m) - P3(n));
                    end
                end
                
                % Find minimum distance
                ds = sort(d1);
                dmin = ds(1);
                k = find(d1 == dmin, 1);
                
                % Update pixel values with median
                X3(i,j,1) = P1(k);
                X3(i,j,2) = P2(k);
                X3(i,j,3) = P3(k);  
            end
        end
        
        % Boundary filtering
        X3(1,1,:) = X3(2,2,:);
        X3(1,N,:) = X3(2,N-1,:);
        X3(M,1,:) = X3(M-1,2,:);
        X3(M,N,:) = X3(M-1,N-1,:);
        for i = 2:M-1
            X3(i,N,:) = X3(i,N-1,:);
        end
        for i = 2:N-1
            X3(M,i,:) = X3(M-1,i,:);
        end
        for i = 2:M-1
            X3(i,1,:) = X3(i,2,:);
        end
        for i = 2:N-1
            X3(1,i,:) = X3(2,i,:);
        end
        toc
    end

    % Display the filtered image
    figure
    imshow(uint8(X3))
    title('Filtered')

%% Normalized Color Difference (NCD)
    Labo = double(X1);
    Labf = double(X3);
    top = 0;
    bottom = 0;
    for i = 1:M
        for j = 1:N
            top = top + sqrt((Labo(i,j,1) - Labf(i,j,1))^2 + (Labo(i,j,2) - Labf(i,j,2))^2 + (Labo(i,j,3) - Labf(i,j,3))^2);
            bottom = bottom + sqrt(Labo(i,j,1)^2 + Labo(i,j,2)^2 + Labo(i,j,3)^2);        
        end
    end
    ncd_value = top / bottom;
    disp('NCD is ')
    disp(ncd_value)

%% Calculate MSE, PSNR, and MAE
    % Mean Squared Error (MSE)
    num = (double(X1) - double(X3)).^2;
    mse = sum(num(:)) / (3 * M * N);
    disp('MSE is : ')
    disp(mse)

    % Peak Signal-to-Noise Ratio (PSNR)
    up = sum(num(:));
    psnr = 10 * log10((M * N * 3 * 255 * 255) / up);         
    disp('PSNR is : ')
    disp(psnr)

    % Mean Absolute Error (MAE)
    mae = sum(abs(double(X1) - double(X3)), 'all') / (M * N * 3);
    disp('MAE is')
    disp(mae)
