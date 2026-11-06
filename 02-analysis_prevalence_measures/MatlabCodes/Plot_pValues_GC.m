% This file takes the p-values from Granger Causaility tests in high-dimensional VARs 
% (obtained using the R-package from Hecq et al, 2023) and creates the
% plots in Figure 5 and Figure A.1 in the online Appendix.

addpath('DataCopy') 

max_alph = 0.1;
addA = 0.001;
rr=100;

pp=1;
Taxes = {'R&R''s Tax Changes','R&R''s exog. Tax Changes','R&R''s Tax News','R&R''s exog. Tax News.',...
         'M&R''s unanticip. Tax Shock','Impl. Tax Rate',...
         'Income Tax','Payroll Tax','Corp. Tax','Tax Receipts','Cycl. Adj. Rev.'};
Macro = {'GDP','Consumption','Investment','Gov. Spend.','Gov. Debt',...
         '3M T-Bill','Unempl. Rate','Inflation','S&P 500','Ramey''s Spend. News'};

Topics = {'Social Services';
    'Legislative Process';
    'Persuasive Rhetoric';
    'Public Administration';
    'Natural Resources, Energy & Technology';
    'Health Care';
    'Proclamations of Unity & Patriotism';
    'Cold War';
    'Nature & Environment';
    'Tradition and Conservative Values';
    'Middle East';
    'Informal Speech';
    'Executive Orders';
    'War on Terror';
    'Interviews';
    'Crime';
    'American Values';
    'Paying Respect to Armed Forces';
    'National Security & Emergencies';
    'Economic Development';
    'International Relations/Diplomacy';
    'Freedom & Patriotism';
    'Expressing Gratitude in Speeches';
    'International Economics & Trade​'};

% p values:

pv=xlsread('GC_pvalues.xlsx'); % This is the output file from the R analysis only transformed from csv to xlsx

%%%% TAX TOPICS GC XYZ

% Tax Topics -> Tax Measures

pM2T = pv([3:9 11 10 1 2]); %order in excel file doesn't match order in the string array "Taxes" used for the plots
    
% Tax Topics -> Macro Variables

pM2Macro = pv(36:46); 
pM2Macro(7)=[];% don't display FFrate (p-value 0.13) if 3m-Tbill is included
    
% Tax Topics -> Other Topics

pM2otherTopics = pv(12:35);
        
%%%% XYZ GC TAX TOPICS        

% Tax Measures -> Tax Topics

pT2M = pv([49:55 57 56 47 48]);

%Macro Variables -> Tax Topics

pMacro2M = pv(82:92);

pMacro2M(7) = []; 
        
% Other Topics -> Tax Measures

potherTopics2M = pv(58:81);

cm=1/100:1/100:1;

aa=100*(addA/max_alph);
cm = cm.^(1/2);
CM=[cm(:) cm(:) ones(100,1)];

warning('off');

%%% GC: Measures on Taxes and Taxes on Measures

figure('Name','Figure 5 (Main Text)','NumberTitle','off')

pm2t=round(pM2T(:,pp)*rr)/rr;
pm2t(pm2t>=max_alph)=max_alph+addA;

subplot(1,4,1,'Position',[0.166458333333333 0.113393665158371 0.156648936170213 0.815000000000001])
im=imagesc(pm2t);
caxis manual
caxis([0 max_alph+addA]);

set(gca, 'Ytick',1:length(Taxes),'YTickLabel',Taxes,'FontSize',10,'FontName','DejaVu Sans')

set(gca,'xtick',[])
colormap(CM)
hold on

title({'Predictive Ability';'Tax Topics'},'FontSize',12,'FontName','DejaVu Sans')

pt2m=round(pT2M(:,pp)*rr)/rr;
pt2m(pt2m>=max_alph)=max_alph+addA;
subplot(1,4,2,'Position',[0.322575354609929 0.113393665158371 0.156648936170213 0.815000000000001])
im=imagesc(pt2m);
caxis manual
caxis([0 max_alph+addA]);
set(gca,'xtick',[])
set(gca,'yTickLabel',[])
title({'Endogeneity';'Tax Topics'},'FontSize',12,'FontName','DejaVu Sans')
hold on
colormap(CM)


%%% GC: Measures on Macro and Macro on Measures

pm2t=round(pM2Macro(:,pp)*rr)/rr;
pm2t(pm2t>=max_alph)=max_alph+addA;

subplot(1,4,3,'Position',[0.520879875886525 0.113393665158371 0.156648936170213 0.815000000000001])
im=imagesc(pm2t);
caxis manual
caxis([0 max_alph+addA]);

set(gca,'yTickLabel',[])

set(gca,'xtick',[])
title({'Predictive Ability';'Tax Topics'},'FontSize',12,'FontName','DejaVu Sans')

colormap(CM)
hold on

pt2m=round(pMacro2M(:,pp)*rr)/rr;
pt2m(pt2m>=max_alph)=max_alph+addA;
subplot(1,4,4,'Position',[0.67699689716312 0.113393665158372 0.156648936170213 0.815000000000001])
im=imagesc(pt2m);
caxis manual
caxis([0 max_alph+addA]);
set(gca,'xtick',[])
%set(gca,'ytick',[])
set(gca, 'Ytick',1:length(Macro),'YTickLabel',Macro,...
    'YAxisLocation','right','FontSize',10,'FontName','DejaVu Sans')
title({'Endogeneity';'Tax Topics'},'FontSize',12,'FontName','DejaVu Sans')

hold on
colormap(CM)
colorbar('Position',...
    [0.421875 0.0442942512935069 0.156770833333333 0.0225035161744023],'Orientation','horizontal')

fig5 = gcf;

%%% GC: Other Topics on Measures and other Topics on Measures

figure('Name','Figure A.1 (Online Appendix)','NumberTitle','off')

pm2t=round(pM2otherTopics(:,pp)*rr)/rr;
pm2t(pm2t>=max_alph)=max_alph+addA;


subplot(1,2,1,'Position',[0.210069441515952 0.114524886877828 0.268686874543852 0.815000000000001]);
im=imagesc(pm2t);
caxis manual
caxis([0 max_alph+addA]);

set(gca, 'Ytick',1:length(Topics),'YTickLabel',Topics,'FontSize',10,'FontName','DejaVu Sans')

set(gca,'xtick',[])
title({'Predictive Ability';'Tax Topics'},'FontSize',12,'FontName','DejaVu Sans')

colormap(CM)
hold on

pt2m=round(potherTopics2M(:,pp)*rr)/rr;
pt2m(pt2m>=max_alph)=max_alph+addA;

subplot(1,2,2,'Position',[0.478153409090909 0.114524886877828 0.284172984216588 0.815000000000001])
im=imagesc(pt2m);
caxis manual
caxis([0 max_alph+addA]);
set(gca,'xtick',[])
%set(gca,'ytick',[])
set(gca, 'Ytick',1:length(Topics),'YTickLabel',Topics,'YAxisLocation','right','FontSize',10,'FontName','DejaVu Sans')
title({'Endogeneity';'Tax Topics'},'FontSize',12,'FontName','DejaVu Sans')

hold on
colormap(CM)
colorbar('Position',...
    [0.338020833333333 0.0654819863680628 0.284375 0.0225035161744024],'Orientation','horizontal')

figA1 = gcf;
orient(fig5,'landscape')
print(fig5, 'Output/Figures/Figure5.pdf', '-dpdf', '-fillpage')
orient(figA1,'landscape')
print(figA1, 'Output/Figures/FigureA1.pdf', '-dpdf', '-fillpage')