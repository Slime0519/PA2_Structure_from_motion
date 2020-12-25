close all;
clear all;

addpath('Givenfunctions');

%% Define constants and parameters
% Constants ( need to be set )
number_of_iterations_for_5_point    = 10000;
number_of_iterations_for_3_point = 50000;

% Thresholds ( need to be set )
threshold_of_distance = 0.03; 
threshold_of_3point = 10;

% Matrices
K               = [ 1698.873755 0.000000     971.7497705;
                    0.000000    1698.8796645 647.7488275;
                    0.000000    0.000000     1.000000 ];

W               = [ 0.000000    -1.00000    0.000000;
                    1.000000    0.000000    0.000000;
                    0.000000    0.000000    1.000000 ];

Z               = [ 0.000000    1.00000     0.000000;
                    -1.00000    0.000000    0.000000;
                    0.000000    0.000000    0.000000 ];
%% load dataset

image1 = imread('./data_2_sfm/sfm01.JPG');
image2 = imread('./data_2_sfm/sfm02.JPG');

temp_imageset = zeros(1,size(image1,1),size(image1,2),size(image1,3));
temp_imageset(1,:,:,:) = image1;
imageset = temp_imageset;
temp_imageset(1,:,:,:) = image2;
imageset = cat(1,imageset,temp_imageset);

imagelist = dir('./data/*.jpg');
imageset_length = size(imagelist,1)

for i=1:imageset_length
    imagepath = strcat('./data/',imagelist(i).name);
    image = imread(imagepath);
    temp_imageset(1,:,:,:) = image;
    imageset = cat(1,imageset,temp_imageset);
end

disp(size(imageset))
imageset = uint8(imageset);
%imshow(squeeze(imageset(1,:,:,:)))
%{
gray_imageset = zeros(size(imageset,1),size(imageset,2),size(imageset,3));
for i = 1:imageset_length
    gray_imageset(i,:,:) = im2single(rgb2gray(squeeze(imageset(i,:,:,:))));
end
disp(size(gray_imageset))
%}

%% apply initial two-view SFM

image1 = squeeze(imageset(1,:,:,:));
image2 = squeeze(imageset(2,:,:,:));
[E,R,T,inlierset1,inlierset2,orig_3D,homo_orig_3D]=two_view_sfm(image1,image2,K,threshold_of_distance,number_of_iterations_for_5_point);

pre_inlier = inlierset2
pre_3D = orig_3D
pre_homo3D = homo_orig_3D
pre_P = K*[R,T]
pre_R = R
pre_T = T

nn_x1_set = round(inlierset1);
nn_x1_set(3,:) = [];
nn_x2_set = round(inlierset2);
nn_x2_set(3,:) = [];
color_info = zeros(3,size(nn_x1_set,2));
for i=1:size(nn_x1_set,2)
    xind1 = nn_x1_set(1,i);
    xind2 = nn_x2_set(1,i);
    yind1 = nn_x1_set(2,i);
    yind2 = nn_x2_set(2,i);
    color_info(:,i) = (image1(yind1,xind1,:));
end

color_info = color_info/255;
X_with_color  = [orig_3D;color_info]; % [6 x # of feature matrix] - XYZRGB
 minz = find(X_with_color(3,:)<0);
X_with_color(:,minz) = [];
X_with_color(1:2,:) = -X_with_color(1:2,:);
pre_homo3D = orig_3D

SavePLY('multi_views_orig.ply', X_with_color);
for i = 3:int8(imageset_length/2)
    image1 = squeeze(imageset(i-1,:,:,:));
    image2 = squeeze(imageset(i,:,:,:));
    [E,R,T,temp_inlierset1,temp_inlierset2,temp_3D,temp_homo_3D]=two_view_sfm(image1,image2,K,threshold_of_distance,number_of_iterations_for_5_point);
    
    %find corresponding features' location
    matchedpoints_index= find_corr(pre_inlier,temp_inlierset1)
    matchedindex_num =size(matchedpoints_index,1)
    
    matched_3Dpoints = pre_homo3D(:,matchedpoints_index(:,1))
    matched_imagepoints = temp_inlierset2(:,matchedpoints_index(:,2))
    
    best_inlier_num = 0
    best_RT = zeros(3,4)
    
    for j = 1 : number_of_iterations_for_3_point
        randindex = randperm(matchedindex_num,3);
        image1_index = matchedpoints_index(randindex,1);
        image2_index = matchedpoints_index(randindex,2);
        
        target_imagepoints = temp_inlierset2(:,image2_index);
        target_3D = pre_3D(:,image1_index);
        
        input = [target_imagepoints',target_3D];
        
        threepoint_result = PerspectiveThreePoint(input); % find out
        RT_candidate = reshape(threepoint_result,[],4,4);
        
        for k = 1:size(RT_candidate,1)
            temp_RT = squeeze(RT_candidate(k,1:3,:));
            temp_P = K*temp_RT;
            [inlier,ratio] = count_inlier_mult(matched_3Dpoints,matched_imagepoints,temp_P,threshold_of_3point);
            
            if inlier>best_inlier_num
                best_RT = temp_RT
                best_inlier_num =inlier
                disp(ratio)
            end
            
        end      
        
    end
    
  %  translated_matrix = (pre_R*best_RT);
  %  translated_matrix(:,4) = translated_matrix(:,4)+pre_T;
    cur_P = K*best_RT;
    matched_imagepoints1 = temp_inlierset1(:,matchedpoints_index(:,2))
    matched_imagepoints2 = temp_inlierset2(:,matchedpoints_index(:,2))
    homogeneous_X = zeros(4,size(matched_imagepoints1,2));
    for i = 1:size(matched_imagepoints1,2)
       % homogeneous_X(:,i) = recover3D(temp_inlierset1(:,i),temp_inlierset2(:,i),pre_P,cur_P); % find out
        homogeneous_X(:,i) = recover3D(matched_imagepoints1(:,i),matched_imagepoints2(:,i),pre_P,cur_P); % find out
    end
    X= zeros(3,size(homogeneous_X,2));
    for i = 1:size(homogeneous_X,2)
        %X(:,i) = homogeneous_X(1:3,i);
        X(:,i) = homogeneous_X(1:3,i)/sign(homogeneous_X(4,i));
       % X(:,i) = homogeneous_X(1:3,i)/homogeneous_X(4,i);
    end
    
    nn_x1_set = round(matched_imagepoints1);
    nn_x1_set(3,:) = [];
    nn_x2_set = round(matched_imagepoints2);
    nn_x2_set(3,:) = [];
    color_info = zeros(3,size(nn_x1_set,2));
    for i=1:size(nn_x1_set,2)
        xind1 = nn_x1_set(1,i);
        xind2 = nn_x2_set(1,i);
        yind1 = nn_x1_set(2,i);
        yind2 = nn_x2_set(2,i);
        color_info(:,i) = (image1(yind1,xind1,:));
    end

    color_info = color_info/255;
    X_with_color_temp  = [X;color_info]; % [6 x # of feature matrix] - XYZRGB

    minz = find(X_with_color(3,:)<0);
    X_with_color(:,minz) = [];
    X_with_color_temp(1:2,:) = -X_with_color_temp(1:2,:);

    % Save 3D points to PLY
    X_with_color = [X_with_color,X_with_color_temp]
    SavePLY('multi_views_temp.ply', X_with_color_temp);
    pre_inlier = temp_inlierset2
    return
end
 




  