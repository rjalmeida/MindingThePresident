function [] = plotCIs(x,y,col,a)

% This function colours the area between the upper and the lower bound of
% the CI of the IRs contained in the matrix y.
% This shaded area is plotted against the axis x.

% x - plot against specified x axis
% y - two rows/columns of matrix y describing the upper and lower bound of 
%     the CI.    
% col - colour for filled up area
% a - degree of "transparency" of the colour

if size(y,1)>size(y,2)
    y=y';
end
px=[x,fliplr(x)];
py=[y(1,:), fliplr(y(2,:))];
s=patch(px,py,1,'FaceColor',col,'EdgeColor','none');
hold off
alpha(s,a);