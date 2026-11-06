function [IR,CIs_dm] = IR_LP(y,x,z,h,ict,trd,qtrd,alph,SEs)

% This codes estimates impulse responses via local projections

% This code borrows substantially from the replication files of
% Plagborg-Moller and Montiel Olea (2021)

% INPUT:
%
% y response variable 
% x contemp. regressor of interest ("shock variable")
% z controls 
% itc - intercept in LP regression (itc=0 for no, itc=1 for yes)
% trd - linear trend in LP regression (trd=0 for no, trd=1 for yes)
% qtrd - quadratic linear trend in LP regression
%        (qtrd=0 for no, qtrd=1 for yes)
%
% h - impulse response horizon
%
% alph - confidence level for intervals. E.g. alph=[0.32 0.1]
%        for both 68% and 90% intervals
%
% SE - choice of std errors to construct intervals
%      SE = 0 Standard 2SLS IV inference (default)
%      SE = 1 EHW Standard Errors
%      SE = 2 get sandwich from EWC estimator and use rule-of-thumb
%           as in Lazarus, Lewis, Stock, an Watson (2018)

%%% OUTPUT:

% IR - impulse responses of y to a shock in x1 (instrumented by z1)
% CIs_dm - confidence intervals for impulse responses

if nargout>1
    
    if alph(1) >1
        alph=alph/100;
    end
    
end

x=[x;z];

% Crit Values:

if nargout > 1
    
    if isempty(SEs)==1 || SEs==1 || SEs == 0
        cvs = repmat(norminv(1-alph/2),1, h+1);
    elseif SEs==2
        cvs = tinv(1-alph/2,0.4*length(y)^(2/3));
    end
    
else
    
    SEs = 1;
    
end



IR=zeros(1,h+1);
se=zeros(1,h+1);

for i = 1:h+1
    
    clear Y X XX
    
    Y=y(i:end);
    X=x(:,1:end-i+1);
    
    if ict==1 || trd==1 || qtrd==1
        XX=[ones(1,size(Y,2))*ict;(1:size(Y,2))*trd;((1:size(Y,2)).^2)*qtrd];
        XX(~any(XX,2),:)=[];
        
    else
        
        XX = [];
    end
    

    if nargout > 1
        
        [IR(i),~, se(i)] = linreg(Y, X, XX, SEs);
        
    else
        
        [IR(i)] = linreg(Y, X, XX, SEs);
    end
    
    
    
end


if nargout > 1
    % delta method CIs (with EW robust std errors)
    CIs_dm = [IR;IR] + [-(cvs.*se);(cvs.*se)];
end


end




function [IR, betahat, se, varcov, res, X_expand] = linreg(Y, X, XX, SEs)

% System linear regression
% Y_t = beta*X_t + epsilon_t
% dim(Y_t) = n, dim(beta) = n x k

% Intputs:
% Y         T x n   dependent variable data matrix
% X         T x k   covariate data matrix
% se_setting        EITHER bool: if true, homoskedastic s.e.; if false, EHW s.e.
%                   OR function handle: function that returns HAC/HAR sandwich matrix
% no_const  bool    true: omit intercept

% Outputs:
% betahat   n x (k+~no_const)       estimated coefficients
% varcov    (n(k+~no_const)) x      var-cov of vec(betahat)
%           (n(k+~no_const))
% res       T x n                   residual matrix
% X_expand  T x (k+~no_const)       covariate data matrix (if no_const)expanded covariate data matrix with intercept


[n,T] = size(Y);

% Include intercept if desired
X_expand = [X;XX]';
Y=Y';
k = size(X_expand,2);
l=[1; zeros(k-1,1)];

% OLS
betahat = (X_expand\Y)';


% Standard errors

if nargout > 2
    
    res = Y-X_expand*betahat';
    XpX = X_expand'*X_expand;
    scores = kron(X_expand,ones(1,n)).*repmat(res,1,k);
    %         if islogical(se_setting)
    if isempty(SEs)==1 || SEs==0
        varcov = kron(inv(XpX),(res'*res)/T);
    elseif SEs==1 % If EHW s.e.
        varcov = kron_fast(inv(XpX),kron_fast(inv(XpX),scores'*scores,0)',0)'; % EHW var-cov matrix
    elseif SEs==2 % If HAC/HAR s.e.
        %         get sandwich from EWC estimator and use rule-of-thumb as in
        %         Lazarus, Lewis, Stock, an Watson 2018
        Omega = ewcHAR(diag(res)*X_expand);
        varcov = kron_fast(inv(XpX),kron_fast(inv(XpX),Omega,0)',0)'; % HAC/HAR var-cov matrix
    end
    
    varcov = T/(T-k)*varcov; % Finite sample adjustment as in Stata
    
    se=sqrt(l'*varcov*l);
end

IR=betahat*l;

end


function C = kron_fast(A,B,type)

% Efficient computation of
% C = kron(A, eye(n))*B (type=0)
% or
% C = kron(eye(n), A)*B (type=1)

% From "MATLAB array manipulation tips and tricks"
% by Peter J. Acklam (2002), section 10.8


% Matrix dimensions
[p,q] = size(A);
[qn,m] = size(B);
n = qn/q;

% Compute
switch type
    case 0
        C = reshape(reshape(B.', [n*m q])*A.', [m p*n]).';
    case 1
        C = reshape(A*reshape(B, [q n*m]), [p*n m]);
end

end




function[Z]=regressor_matrix(y,p)

n=size(y,2);
k=size(y,1);

Z=zeros(k*p,n);

for i=1:p
    Z(((i-1)*k+1):(i*k),(1+i):n) = y(:,1:(n-i));
end
Z=Z(:,(1+p):n);

end

function Omega = ewcHAR(Y)

% Equal-Weighted Cosine HAR estimator
% See Lazarus, Lewis, Stock & Watson (JBES 2018), p. 545

% Here calculated equivalently using Fast Fourier Transform for speed

% Inputs:
% Y         T x n   data matrix
% bw        1 x 1   integer bandwidth

% Outputs:
% Omega     n x n   HAR var-cov matrix

T = size(Y,1);

% bandwidth
bw = round(0.4*T.^(2/3));

[T,n] = size(Y);
rffts = zeros(bw,n);

for j=1:n
    the_Yt = reshape([zeros(T,1) Y(:,j)]',2*T,1); % Insert 0s before every obs.
    the_rfft = real(fft(the_Yt,4*T)); % Compute real part of FFT, padding with T trailing 0s
    rffts(:,j) = the_rfft(2:bw+1,:);
end

Omega = (2/bw)*(rffts'*rffts);

end