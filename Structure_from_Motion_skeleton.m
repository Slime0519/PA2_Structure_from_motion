%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is the skeleton code of PA2 in EC5301 Computer Vision.              %
% It will help you to implement the Structure-from-Motion method easily.   %
% Using this skeleton is recommended, but it's not necessary.              %
% You can freely modify it or you can implement your own program.          %
% If you have a question, please send me an email to haegonj@gist.ac.kr    %
%                                                      Prof. Hae-Gon Jeon  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all;
clear all;

addpath('Givenfunctions');
run('../vlfeat-0.9.21-bin\vlfeat-0.9.21\toolbox\vl_setup.m')

%% Define constants and parameters
% Constants ( need to be set )
number_of_iterations_for_5_point    = 10000;

% Thresholds ( need to be set )
threshold_of_distance = 0.03; 

% Matrices
K               = [ 1698.873755 0.000000     971.7497705;
                    0.000000    1698.8796645 647.7488275;
                    0.000000    0.000000     1.000000 ];

%% Feature extraction and matching
% Load images and extract features and find correspondences.
% Fill num_Feature, Feature, Descriptor, num_Match and Match
% hints : use vl_sift to extract features and get the descriptors.
%        use vl_ubcmatch to find corresponding matches between two feature sets.

image1 = imread('./data_2_sfm/sfm01.JPG');
image2 = imread('./data_2_sfm/sfm02.JPG');

image1_gray = im2single(rgb2gray(image1));
image2_gray = im2single(rgb2gray(image2));

[feature1,descriptor1] = vl_sift(image1_gray,'EdgeThresh',10); %feature : (x,y,radius,orientation)(ref vl_plotframe)
[feature2,descriptor2] = vl_sift(image2_gray,'EdgeThresh',10); %descriptor : 128-dim histogram
disp("features")
disp(size(feature1))
disp(size(feature2))

[matches, scores] = vl_ubcmatch(descriptor1,descriptor2,1.4);
disp("original matches")
disp(size(matches))
imshowpair(image1,image2,'montage')
[sorted_score, orig_idx] = sort(scores, 'descend') ;
matches = matches(:, orig_idx) ;
scores = scores(orig_idx);

plotfeature(image1,image2,feature1,feature2,matches);

%% Initialization step
% Estimate E using 8,7-point algorithm or calibrated 5-point algorithm and RANSAC

x1_set = feature1(1:2,matches(1,:));
x2_set = feature2(1:2,matches(2,:));
disp("matches")
disp(size(matches))
featurenum = size(x1_set,2); 

x1_set = cat(1,x1_set, ones(1,featurenum));
x2_set = cat(1,x2_set, ones(1,featurenum));

disp(size(x1_set))
[E,g_best] = specify_E(x1_set,x2_set,featurenum,K,threshold_of_distance,number_of_iterations_for_5_point);

xa = x1_set(1,g_best(:));
xb = x2_set(1,g_best(:)) + size(image1,2);

ya = x1_set(2,g_best(:));
yb = x2_set(2,g_best(:));

g_best_extension = repelem(g_best,2,1);
plotfeature(image1,image2,x1_set,x2_set,g_best_extension)

x1_set = x1_set(:,g_best(:));
x2_set = x2_set(:,g_best(:));
%% Decompose E into [R, T]

[R T X,homogen_X] = specify_RT(E,K,x1_set,x2_set);


%% Reconstruct 3D points using triangulation
% image의 모든 점을 projection
%{
P1 = K*horzcat(eye(3),zeros(3,1));
P2 = K*horzcat(R,T);

homogeneous_X = zeros(4,size(x1_set,2));
for i = 1:size(x1_set,2)
    homogeneous_X(:,i) = recover3D(x1_set(:,i),x2_set(:,i),P1,P2); % find out
end
X= zeros(3,size(homogeneous_X,2));
for i = 1:size(homogeneous_X,2)
    %X(:,i) = homogeneous_X(1:3,i);
    X(:,i) = homogeneous_X(1:3,i)/sign(homogeneous_X(4,i));
end
X;
%}
nn_x1_set = round(x1_set);
nn_x1_set(3,:) = [];
nn_x2_set = round(x2_set);
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
X_with_color  = [X;color_info]; % [6 x # of feature matrix] - XYZRGB

minz = find(X_with_color(3,:)<0);
X_with_color(:,minz) = [];
X_with_color(1:2,:) = -X_with_color(1:2,:);

% Save 3D points to PLY
SavePLY('2_views_sfm_result_Junmyeong.ply', X_with_color);


