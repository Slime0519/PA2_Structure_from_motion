function [E,R,T,x1_set,x2_set, X,homogen_X] = two_view_sfm(image1,image2,K,threshold,iteration)
%TWO_VIEW_SFM 이 함수의 요약 설명 위치
%   자세한 설명 위치

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
    [E,g_best] = specify_E(x1_set,x2_set,featurenum,K,threshold,iteration);

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
  
return

end

