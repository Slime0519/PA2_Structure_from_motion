function [inlier,ratio] = count_inlier_mult(input3Dset,inputimageset,P_cand,threshold)
%COUNT_INLIER_MULT 이 함수의 요약 설명 위치
%   자세한 설명 위치
    %disp(size(input3Dset))
    inlier = 0;
    pointnum = size(input3Dset,2);
    %input3Dset =input3Dset./sign(input3Dset(4,
    %input3Dset(4,:)=1;
    input3Dset = vertcat(input3Dset,ones(1,size(input3Dset,2)));
    
    %disp(size(input3Dset))
    for i = 1:pointnum
        point3D = squeeze(input3Dset(:,i));
        proj_point = P_cand*point3D;
        proj_point = proj_point./proj_point(3,:);
        target_point = squeeze(inputimageset(:,i));
        diff = (proj_point-target_point).^2;
        distance = sqrt(sum(diff(1:2)));
        
        if(distance<threshold)
            inlier = inlier+1;
        end
    end
    ratio = double(inlier)/pointnum;    
    return 
end

