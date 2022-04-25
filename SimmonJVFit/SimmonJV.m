clc;
clear all;

%%%%%%%%%%%%%%%%%%%%%data loading%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

file=dir('*.xlsx');

J=xlsread(file.name,1);
V=xlsread(file.name,2);

%%%%%%%%%%%%%%%Data plot%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure()
plot(V,J)
xlabel('Voltage (V)')
ylabel('Current density ($\frac{A}{m^{2}}$)','interpreter','latex')
title('J vs V plot')
f=gcf;
print(f,'experimental.png','-dpng','-r1200')

%%%%%%%%%%%%%%%%%%%%%%%%%Constant definition%%%%%%%%%%%%%%%%%%%%%%
e=1.6e-19 ;
h=1.054e-34 ;
d=23.28e-10 ;
m0=9.109e-31 ;
C=( e/( 4*pi^(2)*h*d^(2) ) ) ;

%%%%%%%%%%%%initial guess%%%%%%%%%%%%%%%%%%
p0=[3.0, 0.9, 0.8]
%%%%%%%%%%%%%%%%%fitting%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt','FunctionTolerance',2e-10, 'MaxIterations',5000); 
lb = [];
ub = [];
phi=[];
meff=[];
alpha=[];
NormRes=[];
Residual=[];
Coeff=[];
p=[];
Jac=[];
figure()
for i=1:size(V,2)
%%%%%%%%%%%%%%%%%%%model definition%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f=@(p,v)C*( (e*p(1) - e*v/2).*exp( (-2*(abs(2*p(2)*m0)).^(1/2)/h).*p(3).*( abs((e*p(1) - e*v/2) ).^(1/2) )*d  ) -   (e*p(1) + e*v/2).*exp( (-2*(abs(2*p(2)*m0) ).^(1/2)/h).*p(3).*( abs((e*p(1) + e*v/2) ).^(1/2) )*d  )  )/(max(J(:,i)));

[coeff,resnorm,residual,exitflag,output, lambda, jacobian] = lsqcurvefit(f,p0,V(:,i),J(:,i),lb,ub,options);
p0=coeff
Coeff(end+1,:)=p0
phi(end+1)=coeff(1);
meff(end+1)=coeff(2);
alpha(end+1)=coeff(3);
NormRes(end+1)=resnorm;
Residual(:,end+1)=residual;
Jac(:,end+1:end+3)=jacobian;

plot(V(:,i),J(:,i),'.')
hold on
plot(V(:,i),f(coeff,V(:,i)),'--','LineWidth',1)
hold on
end
xlabel('Voltage (V)')
ylabel('Current density ($\frac{A}{m^{2}}$)','interpreter','latex')
hold off
g=gcf;
print(g,'fitted.png','-dpng','-r1200')
