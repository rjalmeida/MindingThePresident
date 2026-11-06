function [IR,CIs,Fstat] = Compute_IRs(y,z1,x1,x2,x4,M,N,p,p1,p2,itc,trd,qtrd,H,alph,SE,lpiv,nl,FTest)

% This function estimates impulse responses


%%% INPUT:

% y - response variable
% z1 - variable(s) used as intruments
% x1 - endog. variable used to construct endog. measure of tax changes
% x2 - control variables included with p lags
% x4 - variable to be included as contemp. regressors
%
% M - starting point of aggregation window to construct endog. tax variable
% NminusM - length of aggregation window in quarters
%
% p - lags of controls in x2
% p1 - number of autoregressive lags
% p2 - number of lags of instrument(s) included in the 1st stage
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
%
% set lpiv = 0 if IRs should be estimated by "standard" LP regressions.
% That is, responses of y to a shock in x1.
%
% For non-linear/piece-wise linear IRs for tax cut/tax hike: set nl = -1
% to estimate LP-IV for tax cuts and nl = 1 to estimate LP-IV IRs for tax
% hikes. Linear model/LP-IV is estimated if nl is not specified. Leave nl
% unspecified or empty (nl =[]) to estimate a linear model.

%%% OUTPUT:

% IR - impulse responses of y to a shock in x1 (instrumented by z1)
% CIs - confidence intervals for impulse responses

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

NminusM = N-M+1; % length of aggregation window
pM=max([p p1 p2]);

% response variable
y = y(1:end-NminusM);
y(end-M+1:end) = [];

%%%%% construct endog. variable aggregated over window %%%%%

l=length(x1);

for i = 1:l
    m = min([i+NminusM-1,l]);
    x1x(i) = sum(x1(i:m));
end

x1x = x1x(1:end-NminusM);
x1x(1:M) = [];
x1 = x1x(pM+1:end);

if exist('nl') == 1 && isempty(nl) == 0
    % distinguish news about future tax cuts (-1) and future tax hikes (1)
    if nl == -1
        x1(x1>0) = 0;
    elseif nl == 1
        x1(x1<1) = 0;
    end
    
end


%%%%%% Control Variables: %%%%%%

% p lagged regressors
if size(x2,1)>1
    x2 = x2(:,1:end-NminusM);
    x2(:,end-M+1:end) = [];
else
    x2 = x2(1:end-NminusM);
    x2(end-M+1:end) = [];
end
x2 = regressor_matrix(x2,p);
if max([p1 p2]) > p
    if size(x2,1)>1
        x2 = x2(:,(max([p1 p2])-p)+1:end);
    else
        x2 = x2((max([p1 p2])-p)+1:end);
    end
end

% p1 autoregresive lags
x3 = regressor_matrix(y,p1);
if max([p p2]) > p1
    if size (x3,1)>1
        x3 = x3(:,(max([p p2])-p1)+1:end);
    else
        x3 = x3((max([p p2])-p1)+1:end);
    end
end

% contemp. regressors
if isempty(x4) == 0
    if size(x4,1)>1
        x4 = x4(:,1:end-NminusM);
        x4(:,end-M+1:end) = [];
        x4 = x4(:,pM+1:end);
    else
        x4 = x4(1:end-NminusM);
        x4(end-M+1:end) = [];
        x4 = x4(pM+1:end);
    end
end

% Set of all Controls:
X = [x2;x3;x4];
y = y(pM+1:end);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if exist('lpiv') == 0 || lpiv == 1
    % Do LP-IV use prev. measures to instrument constructed
    % endog. measure of tax changes
    % instrumental variable(s)
    % contemporaneous and p2 lags of chosen exog. variables
    if size(z1,1)>1
        z1 = z1(:,1:end-NminusM);
        z1(:,end-M+1:end) = [];
        z1a=z1(:,pM+1:end);
    else
        z1 = z1(1:end-NminusM);
        z1(end-M+1:end) = [];
        z1a=z1(pM+1:end);
    end
    
    z11 = regressor_matrix(z1,p2);
    if max([p p1]) > p2
        if size(z11,1)>1
            z11 = z11(:,(max([p p1])-p2)+1:end);
        else
            z11 = z11((max([p p1])-p2)+1:end);
        end
    end
    
    z = [z1a;z11];
    
    % compute IRs via LP-IV
    CIs = zeros(2,H+1,length(alph));
    for j=1:length(alph)
        [IR,CIs(:,:,j)]= IR_LP_IV(y, x1, z, X, H, itc, trd, qtrd, alph(j), SE);
    end
    
    if exist('FTest') && FTest == 1
        if trd==1 || qtrd==1
            XX=[(1:length(y))*trd;((1:length(y)).^2)*qtrd];
            XX(~any(XX,2),:)=[];
        end
        
        Fstat = FS_Fstat(x1,z1a,[X;z11;XX]);
        
    else
        Fstat = [];
    end
    
elseif lpiv == 0
    % Do LP with constructed endog. measure of tax changes as shock variable
    CIs = zeros(2,H+1,length(alph));
    for j=1:length(alph)
        [IR,CIs(:,:,j)]= IR_LP(y, x1, X, H, itc, trd, qtrd, alph(j), SE);
    end
end

end

function[F] = FS_Fstat(y,x,W)

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
end