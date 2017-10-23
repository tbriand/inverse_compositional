ind=[-10:0.001:10];
f0 = @(x,l) 0.5*x.^2;
f1 = @(x,l) 0.5*x.^2.*(x.^2<l^2) + 0.5*l^2*(x.^2>=l^2);
f2 = @(x,l) 0.5*x.^2./(x.^2+l^2);
f3 = @(x,l) 0.5*log(1+(x/l).^2);
f4 = @(x,l) 2*sqrt(x.^2 + l^2);


g0 = @(x,l) x;
g1 = @(x,l) x.*(abs(x)<l);
g2 = @(x,l) l^2*x./(x.^2 + l^2).^2;
g3 = @(x,l) x./(x.^2 + l^2);
g4 = @(x,l) x./sqrt(s.^2 + l^2);

lambda= 5;
plot( ind, f1(ind,lambda));
plot(ind, f2(ind,lambda));
plot(ind, f3(ind,lambda));
plot(ind, f4(ind,lambda));