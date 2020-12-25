function [corr_index] = find_corr(array1,array2)
%UNTITLED2 이 함수의 요약 설명 위치
%   자세한 설명 위치
corr_index = []
for i = 1:size(array1,2)
    for j=1:size(array2,2) 
        if((array1(1,i) == array2(1,j))&& (array1(2,i) == array2(2,j)))
            corr = [i,j];
            corr_index = [corr_index;corr];
        end
    end
end
return
end

