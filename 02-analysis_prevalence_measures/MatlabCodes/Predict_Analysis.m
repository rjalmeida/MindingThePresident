% This code performs F-tests reprorted in the appendix and gives out the
% Tables in the command window

addpath('DataCopy') 
addpath('AuxFunctions') 

% number of lags of regressors included in equation A.1
p=12;

% maximum prediction horizon
H=6;

%%%%%%%%%%%%%%%%%%%%
%%% Read in data %%%
%%%%%%%%%%%%%%%%%%%%

%%% Prevalence Measures %%%
PM=xlsread('PrevalenceMeasures.xlsx');
% Adjust time span to 1949-2007
PM(end-36+1:end,:)=[];

%%% Other Data %%%
Data = xlsread('Data.xlsx');


%dependent variables:
NAMES = {'Gov Spending',...        % 1
    'Cycl. Adj. Revenue',...       % 2
    'Gov Receipts',...             % 3
    'Income Tax',...               % 4
    'Corporate Tax',...            % 5
    'Payroll Tax',...              % 6
    'RR All Impl.',...             % 7
    'RR All Impl. Exo',...         % 8
    'RR All PV',...                % 9
    'RR All PV Exo',...            % 10
    'MR unanticpt.',...            % 11
    'Ramey Spending News'};        % 12

% Transform data to match specification in Section A.1 in appendix
Y(1,:) = log(Data(2:end,[4])') - log(Data(1:end-1,[4])');
Y(2,:) = Data(2:end,16)';
Y(3,:) = log(Data(2:end,5)') - log(Data(1:end-1,5)');
Y(4,:) = log(Data(2:end,8)') - log(Data(1:end-1,8)');
Y(5,:) = log(Data(2:end,9)') - log(Data(1:end-1,9)');
Y(6,:) = log(Data(2:end,10)') - log(Data(1:end-1,10)');
Y(7,:) = Data(2:end,17)';
Y(8,:) = Data(2:end,18)';
Y(9,:) = Data(2:end,19)';
Y(10,:) = Data(2:end,20)';
Y(11,:) = Data(2:end,21)';
Y(12,:) = Data(2:end,15)';

% Standard set of regressor variables

x([1 2],:) = log(Data(2:end,[1 4])') - log(Data(1:end-1,[1 4])'); % gdp, gov spending,
x(3,:) = Data(2:end,11)'; % 3month TBill 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% Now run F-tests for all specifications reported %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% F-statistics assc. with main IV regression %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if exist('FStats') == 0
disp('--------------------------------------------------------------------------')
disp('To obtain Table 3, run IRs_Analysis.m first and then run this script again')
disp('--------------------------------------------------------------------------')
disp(' ')
disp(' ')
else
    Mf = [0 1 2 3 4 5 6 7];
    Nf = [3 4 5 6 7 8 9 10];
    
    % find relevant entries in vector FStats:
    MNf = [Mf' Nf'];
    for i = 1:length(Mf)
        [~,Fpos(i)] = ismember(MNf(i,:),[MBench' NBench'],'rows');
    end
    
    FStatsLPIV = FStats(Fpos);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% First-stage LDA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

NewsLDA1=PM(2:end,27)';%-mean(PM(2:end,27));
fNaN1 = find(~isnan(NewsLDA1));

NewsLDA1 = NewsLDA1(fNaN1);

if isempty(x)~=1
    Xx1 = x(:,fNaN1);
else
    Xx1=[];
end

%%% Gov Spending:
% Gov spending
[F,R]=TestWeakInstrument(NewsLDA1,Y(1,fNaN1),Xx1([1 3],:),H,p);
F1(5,:) = [F find(F==max(F))-1 max(F)];
R1(5,:) = [R find(R==max(R))-1 max(R)];

% Ramey News:
[F,R]=TestWeakInstrument(NewsLDA1,Y(12,fNaN1),Xx1,H,p);
F1(6,:) = [F find(F==max(F))-1 max(F)];
R1(6,:) = [R find(R==max(R))-1 max(R)];

%%% Tax Variables:

% Change Gov Receipts:
[F,R]=TestWeakInstrument(NewsLDA1,Y(3,fNaN1),Xx1,H,p);
F1(1,:) = [F find(F==max(F))-1 max(F)];
R1(1,:) = [R find(R==max(R))-1 max(R)];

% Change cycl adj revenue:
[F,R]=TestWeakInstrument(NewsLDA1,Y(2,fNaN1),Xx1,H,p);
F1(2,:) = [F find(F==max(F))-1 max(F)];
R1(2,:) = [R find(R==max(R))-1 max(R)];

% RR time of impl.
[F,R]=TestWeakInstrument(NewsLDA1,Y(7,fNaN1),Xx1,H,p);
F1(3,:) = [F find(F==max(F))-1 max(F)];
R1(3,:) = [R find(R==max(R))-1 max(R)];

% RR time of enactment (RR News)
[F,R]=TestWeakInstrument(NewsLDA1,Y(9,fNaN1),Xx1,H,p);
F1(4,:) = [F find(F==max(F))-1 max(F)];
R1(4,:) = [R find(R==max(R))-1 max(R)];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% 2nd-stage LDA (two instruments) %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% tax cut topic
z1=PM(2:end,1)';%-mean(PM(2:end,1));
% tax hike topic:
z2=PM(2:end,2)';%-mean(PM(2:end,2));

NewsLDA2 = [z1;z2];

fNaN2 = find(~isnan(NewsLDA2(1,:)));

NewsLDA2 = NewsLDA2(:,fNaN2);

if isempty(x)~=1
    Xx2 = x(:,fNaN2);
else
    Xx2=[];
end

%%% Gov Spending:

% Gov spending
[F,R]=TestWeakInstrument(NewsLDA2,Y(1,fNaN2),Xx2([1 3],:),H,p);
F2(5,:) = [F find(F==max(F))-1 max(F)];
R2(5,:) = [R find(R==max(R))-1 max(R)];

% Ramey News:
[F,R]=TestWeakInstrument(NewsLDA2,Y(12,fNaN2),Xx2,H,p);
F2(6,:) = [F find(F==max(F))-1 max(F)];
R2(6,:) = [R find(R==max(R))-1 max(R)];

%%% Tax Variables:

% Change Gov Receipts:
[F,R]=TestWeakInstrument(NewsLDA2,Y(3,fNaN2),Xx2,H,p);
F2(1,:) = [F find(F==max(F))-1 max(F)];
R2(1,:) = [R find(R==max(R))-1 max(R)];

% Change cycl adj revenue:
[F,R]=TestWeakInstrument(NewsLDA2,Y(2,fNaN2),Xx2,H,p);
F2(2,:) = [F find(F==max(F))-1 max(F)];
R2(2,:) = [R find(R==max(R))-1 max(R)];

% RR time of impl.
[F,R]=TestWeakInstrument(NewsLDA2,Y(7,fNaN2),Xx2,H,p);
F2(3,:) = [F find(F==max(F))-1 max(F)];
R2(3,:) = [R find(R==max(R))-1 max(R)];

% RR time of enactment (RR News)
[F,R]=TestWeakInstrument(NewsLDA2,Y(9,fNaN2),Xx2,H,p);
F2(4,:) = [F find(F==max(F))-1 max(F)];
R2(4,:) = [R find(R==max(R))-1 max(R)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% Lexicon-based Approach %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% tax cut lexicon
z1=PM(2:end,29)';%-mean(PM(2:end,29));
% tax hike lexicon:
z2=PM(2:end,28)';%-mean(PM(2:end,28));

NewsLex = [z1;z2];

fNaN3 = find(~isnan(NewsLex(1,:)));

NewsLex = NewsLex(:,fNaN3);

if isempty(x)~=1
    Xx3 = x(:,fNaN3);
else
    Xx3=[];
end

%%% Gov Spending:

% Gov spending
[F,R]=TestWeakInstrument(NewsLex,Y(1,fNaN3),Xx3([1 3],:),H,p);
F3(5,:) = [F find(F==max(F))-1 max(F)];
R3(5,:) = [R find(R==max(R))-1 max(R)];

% Ramey News:
[F,R]=TestWeakInstrument(NewsLex,Y(12,fNaN3),Xx3,H,p);
F3(6,:) = [F find(F==max(F))-1 max(F)];
R3(6,:) = [R find(R==max(R))-1 max(R)];

%%% Tax Variables:

% Change Gov Receipts:
[F,R]=TestWeakInstrument(NewsLex,Y(3,fNaN3),Xx3,H,p);
F3(1,:) = [F find(F==max(F))-1 max(F)];
R3(1,:) = [R find(R==max(R))-1 max(R)];

% Change cycl adj revenue:
[F,R]=TestWeakInstrument(NewsLex,Y(2,fNaN3),Xx3,H,p);
F3(2,:) = [F find(F==max(F))-1 max(F)];
R3(2,:) = [R find(R==max(R))-1 max(R)];

% RR time of impl.
[F,R]=TestWeakInstrument(NewsLex,Y(7,fNaN3),Xx3,H,p);
F3(3,:) = [F find(F==max(F))-1 max(F)];
R3(3,:) = [R find(R==max(R))-1 max(R)];

% RR time of enactment (RR News)
[F,R]=TestWeakInstrument(NewsLex,Y(9,fNaN3),Xx3,H,p);
F3(4,:) = [F find(F==max(F))-1 max(F)];
R3(4,:) = [R find(R==max(R))-1 max(R)];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% Impl. Tax Rates %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ITR = Data(2:end,22)'; %Impl. Tax Rates
ITRx = ITR;

fNaN4 = find(~isnan(ITR));

ITR = ITR(fNaN4);

if isempty(x)~=1
    Xx4 = x(:,fNaN4);
else
    Xx4=[];
end

%%% Gov Spending:

% Gov spending
[F,R]=TestWeakInstrument(ITR,Y(1,fNaN4),Xx4([1 3],:),H,p);
F4(5,:) = [F find(F==max(F))-1 max(F)];
R4(5,:) = [R find(R==max(R))-1 max(R)];

% Ramey News:
[F,R]=TestWeakInstrument(ITR,Y(12,fNaN4),Xx4,H,p);
F4(6,:) = [F find(F==max(F))-1 max(F)];
R4(6,:) = [R find(R==max(R))-1 max(R)];

%%% Tax Variables:

% Change Gov Receipts:
[F,R]=TestWeakInstrument(ITR,Y(3,fNaN4),Xx4,H,p);
F4(1,:) = [F find(F==max(F))-1 max(F)];
R4(1,:) = [R find(R==max(R))-1 max(R)];

% Change cycl adj revenue:
[F,R]=TestWeakInstrument(ITR,Y(2,fNaN4),Xx4,H,p);
F4(2,:) = [F find(F==max(F))-1 max(F)];
R4(2,:) = [R find(R==max(R))-1 max(R)];

% RR time of impl.
[F,R]=TestWeakInstrument(ITR,Y(7,fNaN4),Xx4,H,p);
F4(3,:) = [F find(F==max(F))-1 max(F)];
R4(3,:) = [R find(R==max(R))-1 max(R)];

% RR time of enactment (RR News)
[F,R]=TestWeakInstrument(ITR,Y(9,fNaN4),Xx4,H,p);
F4(4,:) = [F find(F==max(F))-1 max(F)];
R4(4,:) = [R find(R==max(R))-1 max(R)];


%%%%%%%%%%%%% Make Tables %%%%%%%%%%%%%%%%%

Ftests = [3 2 7 9 1 12];
%%% Specify table:
VN=cell(1,H+3);
for i=1:H+1
    VN{i}=['H' num2str(i-1)];
end

VN{H+2} = 'H_Max';
VN{H+3} = 'Max_FStat';

VN2 = VN;
VN2{H+3} = 'Max_R2_Change';

if exist('FStatsLPIV') == 1
disp('--------------------------------------------------------------------')
disp('-------------------- Table 3 in Main Text  -------------------------')
disp('--------------------------------------------------------------------')
T0 = array2table([Mf;Nf;round(FStatsLPIV*100)/100],'RowNames',{'M','N','F-statistics'})

figure('Name','Table 3','NumberTitle','off','units','centimeters','position', [5, 5, 20, 3])
% Get the table in string form.
TString = evalc('disp(T0)');
% Use TeX Markup for bold formatting and underscores.
TString = strrep(TString,'<strong>','\bf');
TString = strrep(TString,'</strong>','\rm');
TString = strrep(TString,'_','\_');
% Get a fixed-width font.
FixedWidth = get(0,'FixedWidthFontName');
% Output the table using the annotation command.
annotation(gcf,'Textbox','String',TString,'Interpreter','Tex',...
    'FontName',FixedWidth,'Units','Normalized','Position',[0 0 1 1]);
tab = gcf;
orient(tab,'landscape')
print(tab, 'Output/Tables/Table3.pdf', '-dpdf')
close(tab)
    
end


disp('--------------------------------------------------------------------')
disp('----------------- Table A.1 in Online Appendix ---------------------')
disp('---------------------- 1st stage LDA -------------------------------')
disp('--------------------------------------------------------------------')
T1 = array2table(round(F1*100)/100,'VariableNames',VN,'RowNames',NAMES(Ftests))

figure('Name','Table A.1','NumberTitle','off','units','centimeters','position', [5, 5, 25, 5])
% Get the table in string form.
TString = evalc('disp(T1)');
% Use TeX Markup for bold formatting and underscores.
TString = strrep(TString,'<strong>','\bf');
TString = strrep(TString,'</strong>','\rm');
TString = strrep(TString,'_','\_');
% Get a fixed-width font.
FixedWidth = get(0,'FixedWidthFontName');
% Output the table using the annotation command.
annotation(gcf,'Textbox','String',TString,'Interpreter','Tex',...
    'FontName',FixedWidth,'Units','Normalized','Position',[0 0 1 1]);
tab = gcf;
orient(tab,'landscape')
print(tab, 'Output/Tables/TableA1.pdf', '-dpdf')
close(tab)

%%% R^2

disp('--------------------------------------------------------------------')
disp('----------------- Table A.2 in Online Appendix ---------------------')
disp('---------------------- 1st stage LDA -------------------------------')
disp('--------------------------------------------------------------------')
T2 = array2table(round(R1*100)/100,'VariableNames',VN2,'RowNames',NAMES(Ftests))

figure('Name','Table A.2','NumberTitle','off','units','centimeters','position', [5, 5, 25, 5])
% Get the table in string form.
TString = evalc('disp(T2)');
% Use TeX Markup for bold formatting and underscores.
TString = strrep(TString,'<strong>','\bf');
TString = strrep(TString,'</strong>','\rm');
TString = strrep(TString,'_','\_');
% Get a fixed-width font.
FixedWidth = get(0,'FixedWidthFontName');
% Output the table using the annotation command.
annotation(gcf,'Textbox','String',TString,'Interpreter','Tex',...
    'FontName',FixedWidth,'Units','Normalized','Position',[0 0 1 1]);
tab = gcf;
orient(tab,'landscape')
print(tab, 'Output/Tables/TableA2.pdf', '-dpdf')
close(tab)

disp('--------------------------------------------------------------------')
disp('----------------- Table A.3 in Online Appendix ---------------------')
disp('----------------------- Lexicon-based ------------------------------')
disp('--------------------------------------------------------------------')
T3 = array2table(round(F3*100)/100,'VariableNames',VN,'RowNames',NAMES(Ftests))

figure('Name','Table A.3','NumberTitle','off','units','centimeters','position', [5, 5, 25, 5])
% Get the table in string form.
TString = evalc('disp(T3)');
% Use TeX Markup for bold formatting and underscores.
TString = strrep(TString,'<strong>','\bf');
TString = strrep(TString,'</strong>','\rm');
TString = strrep(TString,'_','\_');
% Get a fixed-width font.
FixedWidth = get(0,'FixedWidthFontName');
% Output the table using the annotation command.
annotation(gcf,'Textbox','String',TString,'Interpreter','Tex',...
    'FontName',FixedWidth,'Units','Normalized','Position',[0 0 1 1]);
tab = gcf;
orient(tab,'landscape')
print(tab, 'Output/Tables/TableA3.pdf', '-dpdf')
close(tab)

disp('--------------------------------------------------------------------')
disp('----------------- Table A.4 in Online Appendix ---------------------')
disp('----------------------- Lexicon-based ------------------------------')
disp('--------------------------------------------------------------------')
T4 = array2table(round(R2*100)/100,'VariableNames',VN2,'RowNames',NAMES(Ftests))

figure('Name','Table A.4','NumberTitle','off','units','centimeters','position', [5, 5, 25, 5])
% Get the table in string form.
TString = evalc('disp(T4)');
% Use TeX Markup for bold formatting and underscores.
TString = strrep(TString,'<strong>','\bf');
TString = strrep(TString,'</strong>','\rm');
TString = strrep(TString,'_','\_');
% Get a fixed-width font.
FixedWidth = get(0,'FixedWidthFontName');
% Output the table using the annotation command.
annotation(gcf,'Textbox','String',TString,'Interpreter','Tex',...
    'FontName',FixedWidth,'Units','Normalized','Position',[0 0 1 1]);
tab = gcf;
orient(tab,'landscape')
print(tab, 'Output/Tables/TableA4.pdf', '-dpdf')
close(tab)


disp('--------------------------------------------------------------------')
disp('----------------- Table A.5 in Online Appendix ---------------------')
disp('---------------------- 2nd stage LDA -------------------------------')
disp('--------------------------------------------------------------------')
T5 = array2table(round(F2*100)/100,'VariableNames',VN,'RowNames',NAMES(Ftests))

figure('Name','Table A.5','NumberTitle','off','units','centimeters','position', [5, 5, 25, 5])
% Get the table in string form.
TString = evalc('disp(T5)');
% Use TeX Markup for bold formatting and underscores.
TString = strrep(TString,'<strong>','\bf');
TString = strrep(TString,'</strong>','\rm');
TString = strrep(TString,'_','\_');
% Get a fixed-width font.
FixedWidth = get(0,'FixedWidthFontName');
% Output the table using the annotation command.
annotation(gcf,'Textbox','String',TString,'Interpreter','Tex',...
    'FontName',FixedWidth,'Units','Normalized','Position',[0 0 1 1]);
tab = gcf;
orient(tab,'landscape')
print(tab, 'Output/Tables/TableA5.pdf', '-dpdf')
close(tab)

disp('--------------------------------------------------------------------')
disp('----------------- Table A.6 in Online Appendix ---------------------')
disp('---------------------- 2nd stage LDA -------------------------------')
disp('--------------------------------------------------------------------')
T6 = array2table(round(R3*100)/100,'VariableNames',VN2,'RowNames',NAMES(Ftests))

figure('Name','Table A.6','NumberTitle','off','units','centimeters','position', [5, 5, 25, 5])
% Get the table in string form.
TString = evalc('disp(T6)');
% Use TeX Markup for bold formatting and underscores.
TString = strrep(TString,'<strong>','\bf');
TString = strrep(TString,'</strong>','\rm');
TString = strrep(TString,'_','\_');
% Get a fixed-width font.
FixedWidth = get(0,'FixedWidthFontName');
% Output the table using the annotation command.
annotation(gcf,'Textbox','String',TString,'Interpreter','Tex',...
    'FontName',FixedWidth,'Units','Normalized','Position',[0 0 1 1]);
tab = gcf;
orient(tab,'landscape')
print(tab, 'Output/Tables/TableA6.pdf', '-dpdf')
close(tab)


disp('--------------------------------------------------------------------')
disp('----------------- Table A.7 in Online Appendix ---------------------')
disp('-------------------- Implicit Tax Rates ----------------------------')
disp('--------------------------------------------------------------------')
T7 = array2table(round(F4*100)/100,'VariableNames',VN,'RowNames',NAMES(Ftests))

figure('Name','Table A.7','NumberTitle','off','units','centimeters','position', [5, 5, 25, 5])
% Get the table in string form.
TString = evalc('disp(T7)');
% Use TeX Markup for bold formatting and underscores.
TString = strrep(TString,'<strong>','\bf');
TString = strrep(TString,'</strong>','\rm');
TString = strrep(TString,'_','\_');
% Get a fixed-width font.
FixedWidth = get(0,'FixedWidthFontName');
% Output the table using the annotation command.
annotation(gcf,'Textbox','String',TString,'Interpreter','Tex',...
    'FontName',FixedWidth,'Units','Normalized','Position',[0 0 1 1]);
tab = gcf;
orient(tab,'landscape')
print(tab, 'Output/Tables/TableA7.pdf', '-dpdf')
close(tab)


disp('--------------------------------------------------------------------')
disp('----------------- Table A.8 in Online Appendix ---------------------')
disp('-------------------- Implicit Tax Rates ----------------------------')
disp('--------------------------------------------------------------------')
T8 = array2table(round(R4*100)/100,'VariableNames',VN2,'RowNames',NAMES(Ftests))

figure('Name','Table A.8','NumberTitle','off','units','centimeters','position', [5, 5, 25, 5])
% Get the table in string form.
TString = evalc('disp(T8)');
% Use TeX Markup for bold formatting and underscores.
TString = strrep(TString,'<strong>','\bf');
TString = strrep(TString,'</strong>','\rm');
TString = strrep(TString,'_','\_');
% Get a fixed-width font.
FixedWidth = get(0,'FixedWidthFontName');
% Output the table using the annotation command.
annotation(gcf,'Textbox','String',TString,'Interpreter','Tex',...
    'FontName',FixedWidth,'Units','Normalized','Position',[0 0 1 1]);
tab = gcf;
orient(tab,'landscape')
print(tab, 'Output/Tables/TableA8.pdf', '-dpdf')
close(tab)