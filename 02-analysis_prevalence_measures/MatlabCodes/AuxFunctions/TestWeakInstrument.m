function[F,RR]=TestWeakInstrument(Z,Y,X,H,p)

% This function conducts an F-test on the (joint) siginifance of paremeters 
% in B associated with the following first-stage IV regression: Y = B*Z + C*X + U
% where Y is the endogenous variable of interest, Z is the (set of)
% instrument(s) and X contains additional control varriables. 
% In addition to the F-statistic the difference in R-squared between the
% model with and without instrument(s) is computed.

% INPUT:
% Z - Instrument(s)
% Y - Endogenous Variable
% X - Controls
% H - max Horizon

% OUTPUT:
% F - F-statistic
% RR - difference in R-squared in "percentage points"

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% all (lagged) regressors:
W = regressor_matrix([Y;X],p);
% dep. variable:
Y = Y(p+1:end);
% instruments:
Z = Z(:,p+1:end);


for h=0:H
   
% adjust for forecast horizon h   
    z = Z(:,1:end-h);
    x = W(:,h+1:end);
    y = Y(h+1:end);
    n=length(y);

% F-statistic
[F(h+1)] = FS_Fstat(y,z,x);


 r1(h+1) = Rsquared(y,x); % R^2 without tax measures, just controls

 r2(h+1) = Rsquared(y,[x;z]); % R^2 with tax measures and controls

end

% Precentage point change in the coefficient of determination when
% including instruments in first stage regressions
RR=(r2-r1)*100; 

function[F] = FS_Fstat(y,x,W)

%Computing the F-statistic:

% y: variable we want to instrument
% x: Instrument(s)
% W: controls


k=min(size(x));

n=length(y);
%%% project out W -> Frisch-Waugh
if isempty(W) == 0
    W=[ones(1,n);W];
else
    W=ones(1,n);
end

By = y*W'*(W*W')^(-1);
y = y - By*W;

Bx = x*W'*(W*W')^(-1);
x = x - Bx*W;

b = y*x'*(x*x')^(-1);

v = y - b*x;
 
% F-statistic %
%%%%%%%%%%%%%%%
sig_v = v*v'/n;
Qxx=x*x'/n;
F = (n*b*Qxx*b')/(k*sig_v);


function[R2] = Rsquared(y,x)

%Computing the R-squared

n=length(y);
k=min(size(x));

% sum of squared residuals of regrssion model:
x = [ones(1,n);x]; % always include intercept
b = y*x'*(x*x')^(-1);
e = y - b*x;
ss1=e*e';

% sum of squared de-meaned dep. variable
x=ones(1,n);
b = y*x'*(x*x')^(-1);
e = y - b*x;
ss2=e*e';


R2 = 1 - ss1/ss2;

function[R2] = Rsquared2(y,x,z)

%Computing the R-squared

n=length(y);
k=min(size(x));

% sum of squared residuals of regression model under the null:
X = [ones(1,n);x]; % always include intercept
b = y*X'*(X*X')^(-1);
e = y - b*X;
ss1=e*e';

% sum of squared residuals of alternative regression model(with
% instruments)
x=[ones(1,n);x;z];
b = y*x'*(x*x')^(-1);
e = y - b*x;
ss2=e*e';
R2 = 1 - ss2/ss1;
