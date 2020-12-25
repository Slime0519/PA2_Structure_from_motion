function [E,g_best] = specify_E(x1_set,x2_set,featurenum,K,threshold,iterations)
%UNTITLED 이 함수의 요약 설명 위치
%   자세한 설명 위치

count = 0;
final_E =zeros(3,3);

for i = 1 : iterations
    
    randindex = randperm(featurenum,5);
%    disp("featuresize")
%    disp(size(feature2(1:2,:)))
    random_x1 = x1_set(:,randindex);
    random_x2 = x2_set(:,randindex);
    
    
    x1_hat = inv(K)*random_x1;
    x2_hat = inv(K)*random_x2;
%    disp("size")
 %   disp(size(x1_hat))
 
    fivepoint_result = calibrated_fivepoint(x1_hat,x2_hat); % find out
    %disp(size(fivepoint_result))
    E_candidate = zeros(size(fivepoint_result,2),3,3);
    for i = 1:size(fivepoint_result,2)
        E_candidate(i,:,:) = reshape(fivepoint_result(:,i),[3,3]);
    end
    
    for i = 1:size(E_candidate,1)
        E_temp = squeeze(E_candidate(i,:,:));
        F = inv(transpose(K))*E_temp*inv(K);
        distance = distancemeasure(x1_set,x2_set,F);
        
        g = find(abs(distance)<threshold);
        number = length(g);
        
        if number>count
            g_best = g;
            count = number;
            final_E = E_temp;
        end
        
    end
    %disp(size(fivepoint_result))  
    %disp(size(E_candidate))
    
   % return
end

ratio = count/size(x1_set,2)
E = final_E
end

