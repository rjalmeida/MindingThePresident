%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This code reproduces the impulse response analysis in the paper and the
% appendix.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all

addpath('DataCopy')     % A copy of the folder with the excel data files is added
addpath('AuxFunctions') % to the folder MatlabCodes such that everything can be
                        % run out of this folder.


%IR horizon:
H=20;

% alpha level for CIs:
alph=[0.32 0.1];


% Std errors for inference
SE=1;
% SE - choice of std errors to construct intervals
%      SE = 0 Standard 2SLS IV inference (default)
%      SE = 1 EHW Standard Errors
%      SE = 2 get sandwich from EWC estimator and use rule-of-thumb as in Lazarus, Lewis, Stock, an Watson 2018


%%% specification of LP regression

% lags of control variables
p=12;

% autoregressive lags in LP regression:
p1=12;

% lags of instrument to be included in first-stage
p2 = 8;

% Note: All the M and N combinations below are used in some specifications
% in the paper/appendix. Estimation of IRs works for other choices of
% MBench and NBench (resp. Mrest and Nrest) but the plots may casuse errors

% Below are the combinations of M and N which are studied for the benchmark
% specification of regressors. That is: M=0,N=1, and M=0,N=3, etc
MBench=[0 0 0 1 2 2 2 4 4 4 5 6 6 6 3 7];
NBench=[1 3 7 4 3 5 9 5 7 11 8 7 9 13 6 10];

% Below are the combinations of M and N which are used to study robustness,
% i.e. for changing specifications of regressors (see appendix).
Mrest = [1 5];
Nrest = [4 8];

% deterministic terms in LP regressions:
% intercept:
itc=1;
% linear trend:
trd=1;
% quadratic trend:
qtrd=1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% Load Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Prevalence Measures %%%

PM=xlsread('PrevalenceMeasures.xlsx');
% Adjust time span from 1949-2007
PM(end-36+1:end,:)=[];

% tax cuts/hikes -> IV
z1 = PM(:,[1 2])'; % (1) tax hike and (2) tax cut measures used as IV
pmlag = PM(:,[7 16])'; % lagged topic controls "War on Terror" + Resources&Energy
pmcontemp = PM(:,[6 22])'; % contemp. topic controls "Public Admin." + "Econ. Developm."

%%%%%%%%%%%%%%%%%%
%%% Other Data %%%
%%%%%%%%%%%%%%%%%%

Data = xlsread('Data.xlsx');

%%% Macro Variables %%%

MV = Data(:,[1 4 5 6 11]); % Macro variables used in IR analysis: (1) GDP, (2) Gov. Spending, (3) Tax Receipts, (4) Debt, (5) TBill rate
% log transformation:
lt=[1:4];
MV(:,lt)=log(MV(:,lt));

resp = 1; % Output
resp2 = 3;% Gov Tax receipts

% All LP-IV regressions include the following macro controls:
% log real GDP, log real government spending, log real government debt, and the 3-month Treasury Bill
% lags of the dependent variable are included as well

% Macro regressors and dep. variable for output regressions (p1 lags of dep.
% variable are always included and must thus not be included in the set of
% other macro controls)
Xmacro1 = MV(:,[2 4 5])';
y1 = MV(:,resp)'; % response variable output

% Macro regressors and response variable for tax responses
Xmacro2 = MV(:,[1 2 4 5])';
y2 = MV(:,resp2)'; % response variable tax receipts

%%% RR tax series %%%

RR = Data(:,17:20);

x1 = RR(:,1)'; % RR's series of all legislated federal tax liability changes to construct endog. measure of futire tax changes
x1b = Data(:,16)'; % RR's cycl. adjusted revenue as alternative

%%% Additionl polictical control variables: %%%

% (1) Republican Dummy; (2) Election Year Dummy;
% (3) Gallup Polls; (4) H+S Concurrence;
polit = Data(:,[23 24 26 27]);
polit = polit(:,1:4)';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First, results for BENCHMARK set of controls and for a variety of choices
% for M and N
% Controls: 12 lags of Macro Variables, lagged topics, lagged RR's tax
% changes (all), conetmp. values of topic "Public Admin." + "Econ. Developm."
%(Fig.6 in main text and Fig.A.5 in appendix)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

CIsBenchY = zeros(2,H+1,length(alph),length(MBench));
CIsBenchT = zeros(2,H+1,length(alph),length(MBench));

IRBenchY = zeros(length(MBench),H+1);
IRBenchT = zeros(length(MBench),H+1);

for j = 1:length(MBench)
    [IR,CIs,FStats(j)] = Compute_IRs(y1,z1,x1,[Xmacro1;pmlag;RR(:,1)'],pmcontemp,MBench(j),NBench(j),p,p1,p2,itc,trd,qtrd,H,alph,SE,1,[],1); %output responses
    [IR2,CIs2] = Compute_IRs(y2,z1,x1,[Xmacro2;pmlag;RR(:,1)'],pmcontemp,MBench(j),NBench(j),p,p1,p2,itc,trd,qtrd,H,alph,SE); %tax receipts responses
    
    % normalise resppnses such that max response of gov. revenue is 1
    m1 = max((IR2));
    
    %collect results
    CIsBenchY(:,:,:,j) = CIs/m1;
    CIsBenchT(:,:,:,j) = CIs2/m1;
    
    IRBenchY(j,:) = IR/m1;
    IRBenchT(j,:) = IR2/m1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Second, different sets of controls (Fig.A.3 and Fig.A.4 in appendix)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

CIsY = zeros(2,H+1,length(alph),length(MBench),3);
CIsT = zeros(2,H+1,length(alph),length(MBench),3);

IRY = zeros(length(MBench),H+1,3);
IRT = zeros(length(MBench),H+1,3);

for j=1:length(Mrest)
    
    % First specification:
    % Controls: lagged macro variables
    
    [IR,CIs] = Compute_IRs(y1,z1,x1,Xmacro1,[],Mrest(j),Nrest(j),p,p1,p2,itc,trd,qtrd,H,alph,SE); %output responses
    [IR2,CIs2] = Compute_IRs(y2,z1,x1,Xmacro2,[],Mrest(j),Nrest(j),p,p1,p2,itc,trd,qtrd,H,alph,SE); %tax receipts responses
    
    % normalise resppnses such that max response of gov. revenue is 1
    m1 = max((IR2));
    
    %collect results
    CIsRestY(:,:,:,j,1) = CIs/m1;
    CIsRestT(:,:,:,j,1) = CIs2/m1;
    
    IRRestY(j,:,1) = IR/m1;
    IRRestT(j,:,1) = IR2/m1;
    
    % Second specification:
    % Controls: lagged macro variables, lagged topics
    
    [IR,CIs] = Compute_IRs(y1,z1,x1,[Xmacro1;pmlag],[],Mrest(j),Nrest(j),p,p1,p2,itc,trd,qtrd,H,alph,SE); %output responses
    [IR2,CIs2] = Compute_IRs(y2,z1,x1,[Xmacro2;pmlag],[],Mrest(j),Nrest(j),p,p1,p2,itc,trd,qtrd,H,alph,SE); %tax receipts responses
    
    % normalise resppnses such that max response of gov. revenue is 1
    m1 = max((IR2));
    
    %collect results
    CIsRestY(:,:,:,j,2) = CIs/m1;
    CIsRestT(:,:,:,j,2) = CIs2/m1;
    
    IRRestY(j,:,2) = IR/m1;
    IRRestT(j,:,2) = IR2/m1;
    
    % Third specification:
    % Controls: lagged macro variables, lagged topics, contemp. topics
    
    [IR,CIs] = Compute_IRs(y1,z1,x1,[Xmacro1;pmlag],pmcontemp,Mrest(j),Nrest(j),p,p1,p2,itc,trd,qtrd,H,alph,SE); %output responses
    [IR2,CIs2] = Compute_IRs(y2,z1,x1,[Xmacro2;pmlag],pmcontemp,Mrest(j),Nrest(j),p,p1,p2,itc,trd,qtrd,H,alph,SE); %tax receipts responses
    
    % normalise resppnses such that max response of gov. revenue is 1
    m1 = max((IR2));
    
    %collect results
    CIsRestY(:,:,:,j,3) = CIs/m1;
    CIsRestT(:,:,:,j,3) = CIs2/m1;
    
    IRRestY(j,:,3) = IR/m1;
    IRRestT(j,:,3) = IR2/m1;
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Further robustness checks, all for M=1, N=4 and M=5, N=8 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


for mn = 1:2
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Estimate responses using LP with RR's exog. tax measure as shock variable
    % using benchmark specification of regressors (and determ. components).
    % Fig. A7.
    
    for j=1:length(alph)
        [IR,CIs] = Compute_IRs(y1,z1,RR(:,2)',[Xmacro1;pmlag;RR(:,1)'],pmcontemp,Mrest(mn),Nrest(mn),p,p1,p2,itc,trd,qtrd,H,alph,SE,0); %output responses
        [IR2,CIs2] = Compute_IRs(y2,z1,RR(:,2)',[Xmacro2;pmlag;RR(:,1)'],pmcontemp,Mrest(mn),Nrest(mn),p,p1,p2,itc,trd,qtrd,H,alph,SE,0); %tax receipts responses
    end
    
    % normalise resppnses such that max response of gov. revenue is 1
    m1 = max((IR2));
    
    %collect results
    CIsrrY(:,:,:,mn) = CIs/m1;
    CIsrrT(:,:,:,mn) = CIs2/m1;
    
    IRrrY(mn,:) = IR/m1;
    IRrrT(mn,:) = IR2/m1;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Tax cuts vs. Tax hikes: Estimate benchmark LP-IV but with tax cut
    % (resp. tax hike) as only instrument (to instrument constructed endog. measure
    % of future tax decreases, resp. increases).
    % Fig. A8
    
    
    [IRcut,CIscut] = Compute_IRs(y1,z1(2,:),x1,[Xmacro1;pmlag;RR(:,1)'],pmcontemp,Mrest(mn),Nrest(mn),p,p1,p2,itc,trd,qtrd,H,alph,SE,1,-1); %output responses
    [IR2cut,CIs2cut] = Compute_IRs(y2,z1(2,:),x1,[Xmacro2;pmlag;RR(:,1)'],pmcontemp,Mrest(mn),Nrest(mn),p,p1,p2,itc,trd,qtrd,H,alph,SE,1,-1); %tax receipts responses
    
    [IRhike,CIshike] = Compute_IRs(y1,z1(1,:),x1,[Xmacro1;pmlag;RR(:,1)'],pmcontemp,Mrest(mn),Nrest(mn),p,p1,p2,itc,trd,qtrd,H,alph,SE,1,1); %output responses
    [IR2hike,CIs2hike] = Compute_IRs(y2,z1(1,:),x1,[Xmacro2;pmlag;RR(:,1)'],pmcontemp,Mrest(mn),Nrest(mn),p,p1,p2,itc,trd,qtrd,H,alph,SE,1,1); %tax receipts responses
    
    % normalise resppnses such that max response of gov. revenue is 1
    m1cut = max((IR2cut));
    m1hike = min((IR2hike));
    
    %collect results
    CIscutY(:,:,:,mn) = CIscut/m1cut;
    CIscutT(:,:,:,mn) = CIs2cut/m1cut;
    
    IRcutY(mn,:) = IRcut/m1cut;
    IRcutT(mn,:) = IR2cut/m1cut;
    
    CIshikeY(:,:,:,mn) = CIshike/m1hike;
    CIshikeT(:,:,:,mn) = CIs2hike/m1hike;
    
    IRhikeY(mn,:) = IRhike/m1hike;
    IRhikeT(mn,:) = IR2hike/m1hike;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Additional polictical controls:
    % (1) Republican Dummy; (2) Election Year Dummy;
    % (3) Gallup Polls; (4) H+S COncurrence;
    % Fig. 7 and Fig. A6 panel (a)
    
    for i = 1:4
        
        dd = polit(i,:); % for some controls only data available from mid 1950s, thus we need to take out some intial observations to have a balance set of time series
        fNaN = find(~isnan(dd));
        xx1 = [Xmacro1;pmlag;RR(:,1)'];
        xx2 = [Xmacro2;pmlag;RR(:,1)'];
        dd = dd(fNaN);
        [IR] = Compute_IRs(y1(fNaN),z1(:,fNaN),x1(fNaN),xx1(:,fNaN),[pmcontemp(fNaN);dd],Mrest(mn),Nrest(mn),p,p1,p2,itc,trd,qtrd,H,alph(1),SE); %output responses
        [IR2] = Compute_IRs(y2(fNaN),z1(:,fNaN),x1(fNaN),xx2(:,fNaN),[pmcontemp(fNaN);dd],Mrest(mn),Nrest(mn),p,p1,p2,itc,trd,qtrd,H,alph(1),SE); %tax receipts responses
        
        % normalise resppnses such that max response of gov. revenue is 1
        m1 = max((IR2));
        
        %collect results
        
        IRpolitY(mn,:,i) = IR/m1;
        IRpolitT(mn,:,i) = IR2/m1;
        
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Use RR's cycl. adjust. revenue as alternative variable to construct
    % endog. measure of future tax changes
    % Fig. 7 and Fig. A6 panel (b)
    
    [IR] = Compute_IRs(y1,z1,x1b,[Xmacro1;pmlag;RR(:,1)'],pmcontemp,Mrest(mn),Nrest(mn),p,p1,p2,itc,trd,qtrd,H,alph(1),SE); %output responses
    [IR2] = Compute_IRs(y2,z1,x1b,[Xmacro2;pmlag;RR(:,1)'],pmcontemp,Mrest(mn),Nrest(mn),p,p1,p2,itc,trd,qtrd,H,alph(1),SE); %tax receipts responses
    
    % normalise resppnses such that max response of gov. revenue is 1
    m1 = max((IR2));
    
    %collect results
    
    IRaltY(mn,:) = IR/m1;
    IRaltT(mn,:) = IR2/m1;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % All possible "orderings":
    % Fig. 7 and Fig. A6 panel (c)
    
    % collect all regressors included in benchmark specification and sequentially add contemp. values, always keep
    % all controls as lags:
    
    xx1 = [Xmacro1;pmlag;RR(:,1)';pmcontemp];
    xx2 = [Xmacro2;pmlag;RR(:,1)';pmcontemp];
    
    for i = 1:size(xx1,1)+1
        
        if i == 1
            pmcontemp1 = [];
            pmcontemp2 = [];
        else
            pmcontemp1 = xx1(1:(i-1),:);
            pmcontemp2 = xx2(1:(i-1),:);
        end
        
        
        [IR] = Compute_IRs(y1,z1,x1,[Xmacro1;pmlag;RR(:,1)'],pmcontemp1,Mrest(mn),Nrest(mn),p,p1,p2,itc,trd,qtrd,H,alph(1),SE); %output responses
        [IR2] = Compute_IRs(y2,z1,x1,[Xmacro2;pmlag;RR(:,1)'],pmcontemp2,Mrest(mn),Nrest(mn),p,p1,p2,itc,trd,qtrd,H,alph(1),SE); %tax receipts responses
        
        % normalise resppnses such that max response of gov. revenue is 1
        m1 = max((IR2));
        
        %collect results
        
        IRorderY(:,i,mn) = IR/m1;
        IRorderT(:,i,mn) = IR2/m1;
        
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Varying deterministc components
    % Fig. 7 and Fig. A6 panel (d)
    
    %%% 1. No quadratic trend, only linear trend
    
    [IR] = Compute_IRs(y1,z1,x1,[Xmacro1;pmlag;RR(:,1)'],pmcontemp,Mrest(mn),Nrest(mn),p,p1,p2,itc,trd,0,H,alph(1),SE); %output responses
    [IR2] = Compute_IRs(y2,z1,x1,[Xmacro2;pmlag;RR(:,1)'],pmcontemp,Mrest(mn),Nrest(mn),p,p1,p2,itc,trd,0,H,alph(1),SE); %tax receipts responses
    
    % normalise resppnses such that max response of gov. revenue is 1
    m1 = max((IR2));
    
    %collect results
    
    IRdetY(:,1,mn) = IR/m1;
    IRdetT(:,1,mn) = IR2/m1;
    
    %%% 2. No trend at all
    
    [IR] = Compute_IRs(y1,z1,x1,[Xmacro1;pmlag;RR(:,1)'],pmcontemp,Mrest(mn),Nrest(mn),p,p1,p2,itc,0,0,H,alph(1),SE); %output responses
    [IR2] = Compute_IRs(y2,z1,x1,[Xmacro2;pmlag;RR(:,1)'],pmcontemp,Mrest(mn),Nrest(mn),p,p1,p2,itc,0,0,H,alph(1),SE); %tax receipts responses
    
    % normalise resppnses such that max response of gov. revenue is 1
    m1 = max((IR2));
    
    %collect results
    
    IRdetY(:,2,mn) = IR/m1;
    IRdetT(:,2,mn) = IR2/m1;
    
    %%% 3. include only 8 lags (instead of 12) - in all regression stages
    
    [IR] = Compute_IRs(y1,z1,x1,[Xmacro1;pmlag;RR(:,1)'],pmcontemp,Mrest(mn),Nrest(mn),8,8,8,itc,trd,qtrd,H,alph(1),SE); %output responses
    [IR2] = Compute_IRs(y2,z1,x1,[Xmacro2;pmlag;RR(:,1)'],pmcontemp,Mrest(mn),Nrest(mn),8,8,8,itc,trd,qtrd,H,alph(1),SE); %tax receipts responses
    
    % normalise resppnses such that max response of gov. revenue is 1
    m1 = max((IR2));
    
    %collect results
    
    IRdetY(:,3,mn) = IR/m1;
    IRdetT(:,3,mn) = IR2/m1;
    
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PLOTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%
% Figure 6 in main Text
%%%%%%%%%%%%%%%%%%%%%%%

figure('Name','Figure 6 (Main Text)','NumberTitle','off')

pos=[1 3 5;2 4 6];
a={'a','c','e';'b','d','f'};
% which M and N pairs to compare? Benchmark M=1,N=4 and M=5,N=8
MN=[1 4;5 8];
% find position in stored array of benchmark IRs and CIs
[~,plots] = ismember(MN,[MBench' NBench'],'rows');
plots = [plots(:)';fliplr(plots(:)')];
colour = [20 20 20]/255;%
gg=0:H;

L = {'-';'--';':';'-.'};
c = autumn(5);
c(1,:) = [0.84 0.11 0.12];

for i = 1:3
    
    if i < 3
        
        % plot output responses
        subplot(3,2,pos(1,i))
        
        for j = 1:length(alph)
            
            plotCIs(gg,-CIsBenchY(:,:,j,plots(i,1)),colour,1/(j*5))
            hold on
            
        end
        
        plot(gg,zeros(1,H+1),'-k')
        hold on
        
        plot(gg,-IRBenchY(plots(i,1),:),'-k','linewidth',1.75)
        hold on
        
        plot(gg,-IRBenchY(plots(i,2),:),'--k','linewidth',1)
        hold on
        
        title({['(',char(a(1,i)),') Output'];['M=',num2str(MN(i,1)),', N=',num2str(MN(i,2))]},'FontSize',10,'FontName','DejaVu Sans','FontWeight','Bold')
        ylabel('Percent','FontSize',10,'FontName','DejaVu Sans','FontWeight','Normal')
        xlabel('Quarters','FontSize',10,'FontName','DejaVu Sans','FontWeight','Normal')
        box on
        ylim([-0.4 0.6])
        
        % plot tax responses
        subplot(3,2,pos(2,i))
        
        for j = 1:length(alph)
            
            plotCIs(gg,-CIsBenchT(:,:,j,plots(i,1)),colour,1/(j*5))
            hold on
            
        end
        
        plot(gg,zeros(1,H+1),'-k')
        hold on
        
        plot(gg,-IRBenchT(plots(i,1),:),'-k','linewidth',1.75)
        hold on
        
        plot(gg,-IRBenchT(plots(i,2),:),'--k','linewidth',1)
        hold on
        
        title({['(',char(a(2,i)),') Tax Receipts'];['M=',num2str(MN(i,1)),', N=',num2str(MN(i,2))]},'FontSize',10,'FontName','DejaVu Sans','FontWeight','Bold')
        ylabel('Percent','FontSize',10,'FontName','DejaVu Sans','FontWeight','Normal')
        xlabel('Quarters','FontSize',10,'FontName','DejaVu Sans','FontWeight','Normal')
        box on
        ylim([-1.5 1.5]);
        
    end
    
    if i == 3
        MN=[2 6 9 13];
        subplot(3,2,5)
        for j = 1:4
            pl = plot(gg,-IRBenchY(MN(j),:),string(L(j)),'linewidth',1.75,'color',c(j,:));
            pl.MarkerFaceColor = c(j,:);
            pl.MarkerEdgeColor = c(j,:);
            hold on
        end
        ylim([-0.4 0.6])
        plot(gg,zeros(1,H+1),'-k')
        hold on
        
        title('(e) Output','FontSize',10,'FontName','DejaVu Sans','FontWeight','Bold')
        ylabel('Percent','FontSize',10,'FontName','DejaVu Sans','FontWeight','Normal')
        xlabel('Quarters','FontSize',10,'FontName','DejaVu Sans','FontWeight','Normal')
        box on
        
        subplot(3,2,6)
        for j = 1:4
            pl = plot(gg,-IRBenchT(MN(j),:),string(L(j)),'linewidth',1.75,'color',c(j,:));
            pl.MarkerFaceColor = c(j,:);
            pl.MarkerEdgeColor = c(j,:);
            hold on
        end
        ylim([-1.5 1.5]);
        plot(gg,zeros(1,H+1),'-k')
        hold on
        
        title('(f) Tax Receipts','FontSize',10,'FontName','DejaVu Sans','FontWeight','Bold')
        ylabel('Percent','FontSize',10,'FontName','DejaVu Sans','FontWeight','Normal')
        xlabel('Quarters','FontSize',10,'FontName','DejaVu Sans','FontWeight','Normal')
        box on
        
        l1=legend('M=0, N=3','M=2, N=5','M=4, N=7','M=6, N=9');
        
        set(l1,...
            'Position',[0.407812504392737 0.0373971117214266 0.220312496460974 0.0322123959186412],...
            'Orientation','horizontal','EdgeColor',[1 1 1]);
        legend('boxoff')
        
    end
    
end

fig6 = gcf;

%%%%%%%%%%%%%%%%%%%%%%%
% Fig.A.5 in Appendix
%%%%%%%%%%%%%%%%%%%%%%%

figure('Name','Figure A.5 (Appendix)','NumberTitle','off')

% M and N combinations
clear MN mn plots
% 1.)
mn(1,:) = {'M=0, N=1','M=2, N=3','M=4, N=5','M=6, N=7'};
MN(:,:,1) = [0 1;2 3;4 5;6 7];
% 2.)
mn(2,:) = {'M=0, N=3','M=2, N=5','M=4, N=7','M=6, N=9'};
MN(:,:,2) = [0 3;2 5;4 7;6 9];
% 3.)
mn(3,:) ={'M=0, N=7','M=2, N=9','M=4, N=11','M=6, N=13'};
MN(:,:,3) = [0 7;2 9;4 11;6 13];

% find position in stored array of benchmark IRs and CIs
%plots=zeros(4,3);
j1=[];

for i = 1:3
    [~,plots(:,i)] = ismember(MN(:,:,i),[MBench' NBench'],'rows');
end

for j = 1:3
    
    % plot output responses
    subplot(3,2,pos(1,j))
    for i = 1:4
        pl = plot(gg,-IRBenchY(plots(i,j),:),string(L(i)),'linewidth',1.75,'color',c(i,:));
        pl.MarkerFaceColor = c(i,:);
        pl.MarkerEdgeColor = c(i,:);
        hold on
    end
    ylim([-0.4 0.6])
    title(['(',char(a(1,j)),') Output'],'FontSize',10,'FontName','DejaVu Sans','FontWeight','Bold')
    ylabel('Percent','FontSize',10,'FontName','DejaVu Sans','FontWeight','Normal')
    xlabel('Quarters','FontSize',10,'FontName','DejaVu Sans','FontWeight','Normal')
    box on
    
    plot(gg,zeros(1,H+1),'-k')
    hold on
    l1 = legend(mn(j,:));
    if j == 1
        set(l1,'Position',[0.420486115022666 0.652250357244672 0.232812496088445 0.0200421936212712],'Orientation','horizontal','EdgeColor',[1 1 1])
    elseif j == 2
        set(l1,'Position',[0.420486115022666 0.356891707455643 0.232812496088445 0.0200421936212712],'Orientation','horizontal','EdgeColor',[1 1 1])
    elseif j == 3
        set(l1,'Position',[0.420486115022666 0.057313648383912 0.232812496088445 0.0200421936212712],'Orientation','horizontal','EdgeColor',[1 1 1])
    end
    legend('boxoff')
    
    % plot tax responses
    subplot(3,2,pos(2,j))
    for i = 1:4
        pl = plot(gg,-IRBenchT(plots(i,j),:),string(L(i)),'linewidth',1.75,'color',c(i,:));
        pl.MarkerFaceColor = c(i,:);
        pl.MarkerEdgeColor = c(i,:);
        hold on
    end
    ylim([-1.5 1.5]);
    title(['(',char(a(2,j)),') Tax Receipts'],'FontSize',10,'FontName','DejaVu Sans','FontWeight','Bold')
    ylabel('Percent','FontSize',10,'FontName','DejaVu Sans','FontWeight','Normal')
    xlabel('Quarters','FontSize',10,'FontName','DejaVu Sans','FontWeight','Normal')
    box on
    
    plot(gg,zeros(1,H+1),'-k')
    hold on
    
end

figA5 = gcf;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figure A.3 and Figure A.4 in Appendix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

MN = [1 4;5 8];
output_titles2{1} = {'Controls: Macro Variables'};
output_titles2{2} = {'Controls: Macro Variables,';'"War on Terror" and "Nat. Resources" (Topics)'};
output_titles2{3} = {'Controls: Macro Variables,';'"War on Terror" and "Nat. Resources" (Topics),';'"Regulatory Policies" and "Long-run Developm." (Topics)'};

for f = 1:2
    
    if f == 1
        figure('Name','Figure A.3 (Appendix)','NumberTitle','off')
        [~,plotsB] = ismember(MN(f,:),[MBench' NBench'],'rows');
        [~,plots] = ismember(MN(f,:),[Mrest' Nrest'],'rows');
    elseif f ==2
        figure('Name','Figure A.4 (Appendix)','NumberTitle','off')
        [~,plotsB] = ismember(MN(f,:),[MBench' NBench'],'rows');
        [~,plots] = ismember(MN(f,:),[Mrest' Nrest'],'rows');
    end
    
    for i = 1:3
        
        % plot output responses
        subplot(3,2,pos(1,i))
        
        for j = 1:length(alph)
            
            plotCIs(gg,-CIsRestY(:,:,j,plots,i),colour,1/(j*5))
            hold on
            
        end
        
        plot(gg,zeros(1,H+1),'-k')
        hold on
        
        plot(gg,-IRRestY(plots,:,i),'-k','linewidth',1.75)
        hold on
        
        plot(gg,-IRBenchY(plotsB,:),'--r','linewidth',1.75)
        hold on
        
        title({['(',char(a(1,i)),') Output'];['M=',num2str(MN(f,1)),', N=',num2str(MN(f,2))]},'FontSize',10,'FontName','DejaVu Sans','FontWeight','Bold')
        ylabel('Percent','FontSize',10,'FontName','DejaVu Sans','FontWeight','Normal')
        xlabel(output_titles2{i},'FontSize',8,'FontName','DejaVu Sans','FontWeight','Normal')
        box on
        
        % plot tax responses
        subplot(3,2,pos(2,i))
        
        for j = 1:length(alph)
            
            plotCIs(gg,-CIsRestT(:,:,j,plots,i),colour,1/(j*5))
            hold on
            
        end
        
        plot(gg,zeros(1,H+1),'-k')
        hold on
        
        plot(gg,-IRRestT(plots,:,i),'-k','linewidth',1.75)
        hold on
        
        plot(gg,-IRBenchT(plotsB,:),'--r','linewidth',1.75)
        hold on
        
        title({['(',char(a(2,i)),') Tax Receipts'];['M=',num2str(MN(f,1)),', N=',num2str(MN(f,2))]},'FontSize',10,'FontName','DejaVu Sans','FontWeight','Bold')
        ylabel('Percent','FontSize',10,'FontName','DejaVu Sans','FontWeight','Normal')
        xlabel(output_titles2{i},'FontSize',8,'FontName','DejaVu Sans','FontWeight','Normal')
        box on
        
    end

    if f == 1
        figA3 = gcf;
    elseif f == 2
        figA4 = gcf;
    end
    
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figure 7 and Figure A.6 in Appendix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for mn = 1:2
    
    if mn==1
        figure('Name','Figure A.6 (Online Appendix)','NumberTitle','off')
        [~,plotsB] = ismember(MN(mn,:),[MBench' NBench'],'rows');
    else
        figure('Name','Figure 7 (Main Text)','NumberTitle','off')
        [~,plotsB] = ismember(MN(mn,:),[MBench' NBench'],'rows');
    end
    
    % different political controls:
    subplot(2,2,1)
    
    for j = 1:length(alph)
        
        plotCIs(gg,-CIsBenchY(:,:,j,plotsB),colour,1/(j*5))
        hold on
        
    end
    
    plot(gg,zeros(1,H+1),'-k')
    hold on
    
    p0=plot(gg,-IRBenchY(plotsB,:),'-k','linewidth',1.75);
    hold on
    
    Pa=plot(gg,-IRpolitY(mn,:,1),'-s','linewidth',1.75);
    hold on
    
    Pb=plot(gg,-IRpolitY(mn,:,2),'-d','linewidth',1.75);
    hold on
    
    Pc=plot(gg,-IRpolitY(mn,:,3),'-^','linewidth',1.75);
    hold on
    
    Pd=plot(gg,-IRpolitY(mn,:,4),'-v','linewidth',1.75);
    hold on
    
    legend1 = legend([Pa(1),Pb(1),Pc(1),Pd(1)],{'Republican Dummy','Election Year Dummy','Approval Ratings','Congress Concurrence'},'FontSize',7,'FontName','DejaVu Sans','FontWeight','Normal','EdgeColor',[1 1 1]);
    title('(a) Different Political Controls','FontSize',10,'FontName','DejaVu Sans','FontWeight','Bold')
    ylabel('Percent','FontSize',10,'FontName','DejaVu Sans','FontWeight','Normal')
    xlabel('Quarters','FontSize',10,'FontName','DejaVu Sans','FontWeight','Normal')
    box on
    xlim([0 20])
    set(legend1,...
        'Position',[0.138802084156001 0.845881512867988 0.0817708316879968 0.0591160205187719],...
        'FontSize',7,...
        'FontName','DejaVu Sans');
    legend('boxoff')
    
    if mn == 1
        ylim([-0.2 0.6])
    end
    
    % using cycl. adj revenu to construct measure of future tax changes
    
    subplot(2,2,2)
    
    for j = 1:length(alph)
        
        plotCIs(gg,-CIsBenchY(:,:,j,plotsB),colour,1/(j*5))
        hold on
        
    end
    
    plot(gg,zeros(1,H+1),'-k')
    hold on
    
    p0=plot(gg,-IRBenchY(plotsB,:),'-k','linewidth',1.75);
    hold on
    
    Pb=plot(gg,-IRaltY(mn,:),'-d','linewidth',1.75);
    hold on
    
    legend1 = legend([Pb(1)],{'Cycl. adj. Revenue'},'FontSize',7,'FontName','DejaVu Sans','FontWeight','Normal','EdgeColor',[1 1 1]);
    title('(b) Alternative endog. Variable','FontSize',10,'FontName','DejaVu Sans','FontWeight','Bold')
    ylabel('Percent','FontSize',10,'FontName','DejaVu Sans','FontWeight','Normal')
    xlabel('Quarters','FontSize',10,'FontName','DejaVu Sans','FontWeight','Normal')
    box on
    xlim([0 20])
    set(legend1,...
        'Position',[0.579947917341875 0.881948820655003 0.0718749986495822 0.0180995471067558],...
        'FontSize',7,...
        'FontName','DejaVu Sans');
    legend('boxoff')
    
    if mn == 1
        ylim([-0.2 0.6])
    end
    
    % all possible orderings
    
    subplot(2,2,3)
    
    for j = 1:length(alph)
        
        plotCIs(gg,-CIsBenchY(:,:,j,plotsB),colour,1/(j*5))
        hold on
        
    end
    
    plot(gg,zeros(1,H+1),'-k')
    hold on
    
    p0=plot(gg,-IRBenchY(plotsB,:),'-k','linewidth',1.75);
    hold on
    
    plot(gg,-IRorderY(:,:,mn))
    
    title('(c) Varying contemp. Controls','FontSize',10,'FontName','DejaVu Sans','FontWeight','Bold')
    ylabel('Percent','FontSize',10,'FontName','DejaVu Sans','FontWeight','Normal')
    xlabel('Quarters','FontSize',10,'FontName','DejaVu Sans','FontWeight','Normal')
    box on
    xlim([0 20])
    
    if mn == 1
        ylim([-0.2 0.6])
    end
    
    % different determ. specifications
    
    subplot(2,2,4)
    
    for j = 1:length(alph)
        
        plotCIs(gg,-CIsBenchY(:,:,j,plotsB),colour,1/(j*5))
        hold on
        
    end
    
    plot(gg,zeros(1,H+1),'-k')
    hold on
    
    p0=plot(gg,-IRBenchY(plotsB,:),'-k','linewidth',1.75);
    hold on
    
    Pa=plot(gg,-IRdetY(:,1,mn),'-s','linewidth',1.75);
    hold on
    
    Pb=plot(gg,-IRdetY(:,2,mn),'-d','linewidth',1.75);
    hold on
    
    Pc=plot(gg,-IRdetY(:,3,mn),'-^','linewidth',1.75);
    
    legend1 = legend([Pa(1),Pb(1),Pc(1)],{'Linear Trend only','No Trend','8 lags of Regressors'},'FontSize',7,'FontName','DejaVu Sans','FontWeight','Normal','EdgeColor',[1 1 1]);
    title('(d) Different Model Specifications','FontSize',10,'FontName','DejaVu Sans','FontWeight','Bold')
    ylabel('Percent','FontSize',10,'FontName','DejaVu Sans','FontWeight','Normal')
    xlabel('Quarters','FontSize',10,'FontName','DejaVu Sans','FontWeight','Normal')
    box on
    xlim([0 20])
    set(legend1,...
        'Position',[0.580468750737297 0.384158760970193 0.0760416651920726 0.0463800892840683],...
        'FontSize',7,...
        'FontName','DejaVu Sans');
    legend('boxoff')
    
    if mn == 1
        ylim([-0.2 0.6])
    end

    if mn == 1
        figA6 = gcf;
    elseif mn == 2
        fig7 = gcf;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figure A.7 and Figure A.8 in Appendix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

colour2 = [1 0 0];

plots=[1 2;3 4];

figure('Name','Figure A.7 (Online Appendix)','NumberTitle','off')

for mn = 1:2
    
    [~,plotsB] = ismember(MN(mn,:),[MBench' NBench'],'rows');
    
    % output responses
    subplot(2,2,plots(mn,1))
    
    for j = 1:length(alph)
        
        plotCIs(gg,-CIsBenchY(:,:,j,plotsB),colour,1/(j*5))
        hold on
        
        plotCIs(gg,-CIsrrY(:,:,j,mn),colour2,1/(j*5))
        hold on
        
    end
    
    plot(gg,zeros(1,H+1),'-k')
    hold on
    
    plot(gg,-IRBenchY(plotsB,:),'--k','linewidth',1.75)
    hold on
    
    plot(gg,-IRrrY(mn,:),'-r','linewidth',1.75);
    hold on
    
    title({['(',char(a(1,mn)),') Output'];['M=',num2str(MN(mn,1)),', N=',num2str(MN(mn,2))]},'FontSize',10,'FontName','DejaVu Sans','FontWeight','Bold')
    ylabel('Percent','FontSize',10,'FontName','DejaVu Sans','FontWeight','Normal')
    xlabel('Quarters','FontSize',10,'FontName','DejaVu Sans','FontWeight','Normal')
    box on
    
    % tax receipts responses
    
    subplot(2,2,plots(mn,2))
    
    for j = 1:length(alph)
        
        plotCIs(gg,-CIsBenchT(:,:,j,plotsB),colour,1/(j*5))
        hold on
        
        plotCIs(gg,-CIsrrT(:,:,j,mn),colour2,1/(j*5))
        hold on
        
    end
    
    plot(gg,zeros(1,H+1),'-k')
    hold on
    
    P0 = plot(gg,-IRBenchT(plotsB,:),'--k','linewidth',1.75);
    hold on
    
    P1 = plot(gg,-IRrrT(mn,:),'-r','linewidth',1.75);
    hold on
    
    title({['(',char(a(2,mn)),') Tax Receipts'];['M=',num2str(MN(mn,1)),', N=',num2str(MN(mn,2))]},'FontSize',10,'FontName','DejaVu Sans','FontWeight','Bold')
    ylabel('Percent','FontSize',10,'FontName','DejaVu Sans','FontWeight','Normal')
    xlabel('Quarters','FontSize',10,'FontName','DejaVu Sans','FontWeight','Normal')
    box on
    if mn == 2
        legend([P0(1),P1(1)],{'Benchmark','LP with acc. future RR Tax News'},'FontSize',7,'FontName','DejaVu Sans','FontWeight','Normal',...
            'Position',[0.448437501257285 0.0346386948406869 0.135937497485429 0.0180995471067558],...
            'Orientation','horizontal','EdgeColor',[1 1 1])
        legend('boxoff')
    end
    xlim([0 20])
    
end

figA7 = gcf;

figure('Name','Figure A.8 (Online Appendix)','NumberTitle','off')

for mn = 1:2
    
    [~,plotsB] = ismember(MN(mn,:),[MBench' NBench'],'rows');
    
    % Tax Cut News Responses
    subplot(2,2,plots(mn,1))
    
    for j = 1:length(alph)
        
        plotCIs(gg,-CIsBenchY(:,:,j,plotsB),colour,1/(j*5))
        hold on
        
        plotCIs(gg,-CIscutY(:,:,j,mn),colour2,1/(j*5))
        hold on
        
    end
    
    plot(gg,zeros(1,H+1),'-k')
    hold on
    
    plot(gg,-IRBenchY(plotsB,:),'--k','linewidth',1.75)
    hold on
    
    plot(gg,-IRcutY(mn,:),'-r','linewidth',1.75);
    hold on
    
    title({['(',char(a(1,mn)),') Tax Cut News'];['M=',num2str(MN(mn,1)),', N=',num2str(MN(mn,2))]},'FontSize',10,'FontName','DejaVu Sans','FontWeight','Bold')
    ylabel('Percent','FontSize',10,'FontName','DejaVu Sans','FontWeight','Normal')
    xlabel('Quarters','FontSize',10,'FontName','DejaVu Sans','FontWeight','Normal')
    box on
    ylim([-1 1])
    
    % Tax Hike News Responses
    subplot(2,2,plots(mn,2))
    
    for j = 1:length(alph)
        
        plotCIs(gg,CIsBenchY(:,:,j,plotsB),colour,1/(j*5))
        hold on
        
        plotCIs(gg,-CIshikeY(:,:,j,mn),colour2,1/(j*5))
        hold on
        
    end
    
    plot(gg,zeros(1,H+1),'-k')
    hold on
    
    P0 = plot(gg,IRBenchY(plotsB,:),'--k','linewidth',1.75);
    hold on
    
    P1 = plot(gg,-IRhikeY(mn,:),'-r','linewidth',1.75);
    hold on
    
    title({['(',char(a(2,mn)),') Tax Hike News'];['M=',num2str(MN(mn,1)),', N=',num2str(MN(mn,2))]},'FontSize',10,'FontName','DejaVu Sans','FontWeight','Bold')
    ylabel('Percent','FontSize',10,'FontName','DejaVu Sans','FontWeight','Normal')
    xlabel('Quarters','FontSize',10,'FontName','DejaVu Sans','FontWeight','Normal')
    box on
    if mn == 2
        legend([P0(1),P1(1)],{'Benchmark','Tax Cut/Tax Hike News'},'FontSize',7,'FontName','DejaVu Sans','FontWeight','Normal',...
            'Position',[0.448437501257285 0.0346386948406869 0.135937497485429 0.0180995471067558],...
            'Orientation','horizontal','EdgeColor',[1 1 1])
        legend('boxoff')
    end
    xlim([0 20])
    ylim([-1 1])
    h = gca;  % Handle to currently active axes
    set(h, 'YDir', 'reverse');
    
end

figA8 = gcf;

print(fig6, 'Output/Figures/Figure6.pdf', '-dpdf', '-fillpage')
print(fig7, 'Output/Figures/Figure7.pdf', '-dpdf')
print(figA3, 'Output/Figures/FigureA3.pdf', '-dpdf', '-fillpage')
print(figA4, 'Output/Figures/FigureA4.pdf', '-dpdf', '-fillpage')
print(figA5, 'Output/Figures/FigureA5.pdf', '-dpdf', '-fillpage')
print(figA6, 'Output/Figures/FigureA6.pdf', '-dpdf', '-fillpage')
print(figA7, 'Output/Figures/FigureA7.pdf', '-dpdf')
print(figA8, 'Output/Figures/FigureA8.pdf', '-dpdf')


