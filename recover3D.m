function [X] = recover3D(x1,x2,P1,P2)
%UNTITLED 이 함수의 요약 설명 위치
%   자세한 설명 위치

A = [x1(1)*P1(3,:)-P1(1,:);
     x1(2)*P1(3,:)-P1(2,:);
     x2(1)*P2(3,:)-P2(1,:);
     x2(2)*P2(3,:)-P2(2,:)];

%{
for i=1:4
    A(1,i) = x1(1)*P1(3,i)-P1(1,i);
    A(2,i) = x1(2)*P1(3,i)-P1(2,i);
    A(3,i) = x2(1)*P2(3,i)-P2(1,i);
    A(4,i) = x2(2)*P2(3,i)-P2(2,i);
end
%}

[u s v] = svd(A);
X = v(:,end);
%X = X(1:3)/X(4);
%X = linsolve(A,zeros(4,1));
%A
%disp(size(A))
%X = linsolve(A(1:3),-A(4)); %suppose to last coord is 1
%syms x y z
%syms z positive
%[X Y Z] = solve(A(1)*x+A(2)*y+A(3)*z+A(4) ==0, [x y z])
return
end

