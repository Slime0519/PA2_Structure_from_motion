function [R,T,D3X,homogen_D3X] = specify_RT(E,K,x1set,x2set)
%SPECIFY_E 이 함수의 요약 설명 위치
%   자세한 설명 위치


W               = [ 0.000000    -1.00000    0.000000;
                    1.000000    0.000000    0.000000;
                    0.000000    0.000000    1.000000 ];

Z               = [ 0.000000    1.00000     0.000000;
                    -1.00000    0.000000    0.000000;
                    0.000000    0.000000    0.000000 ];

[U,S,V] = svd(E);

R_cand1 = U*W*V';
R_cand2 = U*W'*V';
t = U(:,3);

P_cand = zeros(4,3,4);
sol = zeros(4,3);
depth = squeeze(zeros(1,4));

P_left = K*horzcat(eye(3),squeeze(zeros(3,1)))

P_cand(1,:,:) = K*horzcat(R_cand1,t);
P_cand(2,:,:) = K*horzcat(R_cand1,-t);
P_cand(3,:,:) = K*horzcat(R_cand2,t);
P_cand(4,:,:) = K*horzcat(R_cand2,-t);

det1 =det(U*W*V');
det2 =det(U*W'*V');

P1 = det1*squeeze(P_cand(1,:,:));
P2 = det1*squeeze(P_cand(2,:,:));
P3 = det2*squeeze(P_cand(3,:,:));
P4 = det2*squeeze(P_cand(4,:,:));

point1 = zeros(4,size(x1set,2));
point2 = zeros(4,size(x1set,2));
point3 = zeros(4,size(x1set,2));
point4 = zeros(4,size(x1set,2));

for i = 1:size(x1set,2)
    point1(:,i) = recover3D(x1set(:,i),x2set(:,i),P_left,P1);
    point2(:,i) = recover3D(x1set(:,i),x2set(:,i),P_left,P2);
    point3(:,i) = recover3D(x1set(:,i),x2set(:,i),P_left,P3);
    point4(:,i) = recover3D(x1set(:,i),x2set(:,i),P_left,P4);
end

points = zeros(4,size(point1,2));

%points(1,:) = point1(3,:)./point1(4,:);
%points(2,:) = point2(3,:)./point2(4,:);
%points(3,:) = point3(3,:)./point3(4,:);
%points(4,:) = point4(3,:)./point4(4,:);
points(1,:) = point1(3,:)./sign(point1(4,:));
points(2,:) = point2(3,:)./sign(point2(4,:));
points(3,:) = point3(3,:)./sign(point3(4,:));
points(4,:) = point4(3,:)./sign(point4(4,:));


sum_points = sum(sign(points),2)
[maxval,maxind] = max(sum_points)

if maxind == 1
    R = det1*R_cand1;
    T = det1*t;
    homogen_D3X = point1%./sign(point1(4,:));
    D3X = point1(1:3,:)./sign(point1(4,:));
elseif maxind==2
    R = det1*R_cand1;
    T = -t*det1;
    homogen_D3X = point2%./sign(point2(4,:));
    D3X = point2(1:3,:)./sign(point2(4,:));
elseif maxind==3
    R = det2*R_cand2;
    T = det2*t;
    homogen_D3X = point3%./sign(point3(4,:));
    D3X = point3(1:3,:)./sign(point3(4,:));
else
    R = det2*R_cand2;
    T = -t*det2;
    homogen_D3X = point4%./sign(point4(4,:));
    D3X = point4(1:3,:)./sign(point4(4,:));
    
%rot_axis = [R(3,2)-R(2,3), R(1,3) - R(3,1), R(2,1) - R(1,2)];
%rot_axis = rot_axis /norm(rot_axis)
%rot_angle = acos( (trace(R)-1)/2)

return

end

