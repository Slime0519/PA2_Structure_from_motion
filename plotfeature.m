function [] = plotfeature(image1,image2,feature1,feature2,matcharr)
%UNTITLED2 이 함수의 요약 설명 위치
%   자세한 설명 위치
figure();
imagesc(cat(2, image1, image2)) ;
axis image off ;
%vl_demo_print('sift_match_1', 1) ;

xa = feature1(1,matcharr(1,:));
xb = feature2(1,matcharr(2,:)) + size(image1,2);
ya = feature1(2,matcharr(1,:));
yb = feature2(2,matcharr(2,:));

hold on;
h = line([xa ; xb], [ya ; yb]);
set(h,'linewidth', 0.1, 'color', 'b');

vl_plotframe(feature1(:,matcharr(1,:))) ;
feature2_temp = feature2;
feature2_temp(1,:) = feature2(1,:) + size(image1,2) ;
vl_plotframe(feature2_temp(:,matcharr(2,:))) ;
axis image off ;

end

