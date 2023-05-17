% Params
a = 100;
b = 50;
theta = 0;
alpha = 45;

res = [300 300];
ctr = res./2;

bwImTrue = bwEllipse(res,ctr,2*a,2*b,theta);
bwImLevel = bwEllipse(res,ctr,2*a,2*b,0);

D = (a*b)/sqrt((b^2-a^2)*cosd(alpha-theta)^2+a^2);

newx = D*cosd(alpha-theta);
newy = D*sind(alpha-theta);

imshow(bwImLevel);
hold on
plot([ctr(1) newx+ctr(1)],[ctr(2) -newy+ctr(2)],'r')