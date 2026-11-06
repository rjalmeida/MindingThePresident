function [IR,CIs]= IR_LP_IV(y, x1, z, x2, H, itc, trd, qtrd, alph, SE)

% This codes estimates impulse responses via LP-IV 

% This code borrows substantially from the replication files of
% Plagborg-Moller and Montiel Olea (2021)

% INPUT:
% y  - response variable
% x1 - variable to be instrumented
% z  - instrumental variable(s)
% x2 - control variables 
%
% itc - intercept in LP regression (itc=0 for no, itc=1 for yes)
% trd - linear trend in LP regression (trd=0 for no, trd=1 for yes)
% qtrd - quadratic linear trend in LP regression
%        (qtrd=0 for no, qtrd=1 for yes)
%
% H - impulse response horizon
% alph - confidence level for intervals. E.g. alph=[0.32 0.1]
%        for both 68% and 90% intervals
%
% SE - choice of std errors to construct intervals
%      SE = 0 Standard 2SLS IV inference (default)
%      SE = 1 EHW Standard Errors
%      SE = 2 get sandwich from EWC estimator and use rule-of-thumb
%           as in Lazarus, Lewis, Stock, an Watson (2018)



if exist('SE') == 0
    SE = 0;
end

%%%%%%% Standard Two Stage LS: %%%%%%%%%%%

% 2SLS notation:


if itc==1 || trd==1 || qtrd==1
    XX=[ones(1,length(y))*itc;(1:length(y))*trd;((1:length(y)).^2)*qtrd];
    XX(~any(XX,2),:)=[];
end

x = [x1;x2;XX];

w = [z;x2;XX];

for h = 1:H+1
    
    Y = y(h:end)';
    
    X = x(:,1:end-(h-1))';
    
    W = w(:,1:end-(h-1))';
    
    PW = W*((W'*W)^(-1))*W';
    
    B = ((X'*PW*X)^(-1))*X'*PW*Y;
    
    res = Y - X*B;
    
    xx1 = X(:,1);
    xx2 = X(:,2:end);
    
    Xhat = [PW*xx1 xx2];
    
    T = length(Y);
    k = size(X,2);
    l = [1; zeros(k-1,1)];
    
    XhatpXhat = Xhat'*Xhat;
    
    % the following is in part borrowed from Plagborg-Moller and Montiel
    % Olea (2021)
    
    if isempty(SE) || SE == 0
        % Standard 2SLS IV inference (default)
        Xhatu = Xhat.* repmat(res,1,k);%.*res;
        XhatupXhatu = Xhatu'*Xhatu;
        varcov = ((inv(XhatpXhat))*(XhatupXhatu)*(inv(XhatpXhat)));
        
    elseif SE == 1
        % EHW Standard Errors
        score = Xhat .* repmat(res,1,k);
        varcov = kron_fast(inv(XhatpXhat),kron_fast(inv(XhatpXhat),score'*score,0)',0)';
        
    elseif SE == 2
        % get sandwich from EWC estimator and use rule-of-thumb as in
        % Lazarus, Lewis, Stock, an Watson 2018
        Omega = ewcHAR(diag(res)*Xhat);
        varcov = kron_fast(inv(XhatpXhat),kron_fast(inv(XhatpXhat),Omega,0)',0)'; % HAC/HAR var-cov matrix
        
    end
    
    
    IR(h) = B(1);
    se_IR(h) = sqrt(l'*varcov*l);
    
end

cvs = repmat(norminv(1-alph/2),1, H+1);

CIs = [IR;IR] + [-(cvs.*se_IR);(cvs.*se_IR)];

end


function Omega = ewcHAR(Y)
    
    % Borrowed from Plagborg-Moller and Montiel Olea (2021)
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