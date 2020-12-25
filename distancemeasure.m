function [distance] = distancemeasure(x1set,x2set,F)
%UNTITLED 이 함수의 요약 설명 위치
%   자세한 설명 위치

%apply sampson approximation
pointnum = size(x1set,2);
dist_square = squeeze(zeros(1,pointnum));

for index = 1:size(x1set,2)
    x1 = squeeze(x1set(:,index));
    x2 = squeeze(x2set(:,index));
    x2t = transpose(x2);
    dist_square(index) = ((x2t*F*x1)^2)/(((norm(F*x1))^2)+((norm(x2t*F))^2)); %sampson distance
end

distance = sqrt(dist_square);

end

