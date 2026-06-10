% ================================================================
%  CO653 - Heart Disease Risk - LIVE INTERACTIVE DASHBOARD v4
%  Clean Grid Layout — no overlaps
%  ─────────────────────────────────────────────────────────────
%  LAYOUT  (1540 × 900 px):
%   LEFT  col  x=5,   w=290  — inputs, gauge, score, buttons
%   MID-L col  x=300, w=580  — MF row (top) | Rules (mid) | Surface (bot)
%   MID-R col  x=885, w=520  — Radar (top)  | OutMF (mid) | FactorBars (bot)
%   RIGHT col  x=1410,w=120  — History list + mini track
%  No Toolbox Required | MATLAB Desktop
% ================================================================
clc; clear; close all;

% ── MF functions ─────────────────────────────────────────────────
function y = trapmf(x,a,b,c,d)
    if b > a, rise=(x-a)/(b-a); else, rise=double(x>=a); end
    if d > c, fall=(d-x)/(d-c); else, fall=double(x<=d); end
    y = max(0, min([rise,1,fall]));
end
function y = trimf(x,a,b,c)
    if b > a, rise=(x-a)/(b-a); else, rise=double(x>=b); end
    if c > b, fall=(c-x)/(c-b); else, fall=double(x<=b); end
    y = max(0, min(rise,fall));
end
function mf = fuzzify(Age,BP,Chol,HR,BMI)
    mf.age=[trapmf(Age,20,20,35,50), trimf(Age,35,52,70),         trapmf(Age,55,68,90,90)];
    mf.bp =[trapmf(BP,80,80,110,130),trimf(BP,115,135,155),        trapmf(BP,140,160,200,200)];
    mf.ch =[trapmf(Chol,100,100,170,210),trimf(Chol,190,230,270),  trapmf(Chol,250,290,400,400)];
    mf.hr =[trapmf(HR,40,40,65,80),  trimf(HR,68,80,95),           trapmf(HR,88,100,130,130)];
    mf.bmi=[trapmf(BMI,14,14,20,25), trimf(BMI,22,27,32),          trapmf(BMI,29,34,45,45)];
end
function [score,strengths] = fuzzy_infer(Age,BP,Chol,HR,BMI)
    mf=fuzzify(Age,BP,Chol,HR,BMI);
    R=[min(mf.age(3),mf.bp(3)),85;  min(mf.age(3),mf.ch(3)),85;
       min(mf.bp(3),mf.ch(3)),85;   min(mf.age(3),mf.hr(3)),85;
       min(mf.bp(3),mf.bmi(3)),85;  0.9*min(mf.hr(3),mf.bmi(3)),85;
       min(min(mf.age(2),mf.bp(2)),mf.ch(2)),50;
       min(mf.bp(2),mf.hr(2)),50;   0.8*min(mf.ch(2),mf.bmi(2)),50;
       min(min(mf.age(1),mf.bp(1)),mf.ch(1)),15;
       0.9*min(mf.age(1),mf.bmi(1)),15;
       0.9*min(min(mf.bp(1),mf.ch(1)),mf.hr(1)),15];
    strengths=R(:,1); W=sum(strengths);
    score=sum(strengths.*R(:,2))/max(W,1e-9);
end
function lbl=riskLabel(s)
    if s<33,lbl='LOW RISK'; elseif s<66,lbl='MEDIUM RISK'; else,lbl='HIGH RISK'; end
end
function c=riskColor(s)
    if s<33,c=[0.10 0.65 0.42]; elseif s<66,c=[0.94 0.60 0.10]; else,c=[0.85 0.20 0.20]; end
end
function c=inputHintColor(k,val)
    normals={[20 45],[80 120],[100 200],[60 80],[18.5 24.9]};
    borders={[45 60],[120 140],[200 240],[80 100],[25 30]};
    lo=normals{k}(1); hi=normals{k}(2);
    blo=borders{k}(1); bhi=borders{k}(2);
    if val>=lo && val<=hi,      c=[0.08 0.35 0.18];
    elseif val>=blo && val<=bhi,c=[0.40 0.25 0.04];
    else,                       c=[0.40 0.08 0.08];
    end
end

MC = {[0.10 0.65 0.42],[0.94 0.60 0.10],[0.85 0.20 0.20]};

% ================================================================
%  LAYOUT CONSTANTS  (all in pixels, fig = 1540 × 900)
% ================================================================
FW=1540; FH=900;
HDR=36;        % header height
BOT=24;        % status bar height
INNER=FH-HDR-BOT;   % 840 px usable vertical

% Column x-starts and widths
LX=5;   LW=290;   % LEFT  — inputs
MX=300; MW=575;   % MID   — MF/rules/surface
RX=880; RW=520;   % RIGHT — radar/outMF/factors
HX=1405;HW=128;   % HISTORY

% Row y-starts (from bottom) and heights within INNER
% Row 3 (top):    y=BOT+INNER*0.62 → h=INNER*0.36   MF row + Radar
% Row 2 (middle): y=BOT+INNER*0.30 → h=INNER*0.30   Rules + OutMF
% Row 1 (bottom): y=BOT            → h=INNER*0.28   Surface + Factors

R3H=300; R3Y=FH-HDR-R3H;      % top row    y=564, h=300
R2H=260; R2Y=R3Y-R2H-6;       % mid row    y=298, h=260
R1H=270; R1Y=BOT+2;           % bot row    y=26,  h=270

% ================================================================
%  MAIN FIGURE
% ================================================================
fig = figure('Name','CO653 — Heart Disease Risk  |  Live Dashboard v4',...
    'NumberTitle','off','Position',[20 30 FW FH],...
    'Color',[0.10 0.12 0.16],'Resize','off',...
    'MenuBar','none','ToolBar','none');

% ── Header bar ────────────────────────────────────────────────────
uicontrol('Style','text','Position',[0 FH-HDR FW HDR],...
    'String','  ❤  Heart Disease Risk Prediction  |  Mamdani Fuzzy Inference  |  CO653 Dashboard v4',...
    'FontSize',12,'FontWeight','bold','ForegroundColor','w',...
    'BackgroundColor',[0.12 0.22 0.50],'HorizontalAlignment','center');

% ── Status bar ────────────────────────────────────────────────────
hStatusMain=uicontrol('Style','text','Position',[LX 0 FW-LX BOT],...
    'String','Ready — type patient values and press Enter',...
    'FontSize',8,'ForegroundColor',[0.55 0.80 0.55],...
    'BackgroundColor',[0.10 0.12 0.16],'HorizontalAlignment','center');

% ================================================================
%  LEFT COLUMN — Patient inputs + Gauge + Score
% ================================================================
% Section header
uicontrol('Style','text','Position',[LX R3Y+R3H-HDR LW HDR],...
    'String','PATIENT PARAMETERS','FontSize',9,'FontWeight','bold',...
    'ForegroundColor','w','BackgroundColor',[0.18 0.32 0.62],...
    'HorizontalAlignment','center');

% Hint
uicontrol('Style','text','Position',[LX R3Y+R3H-HDR*2 LW 20],...
    'String','⌨ Type value  →  Enter  |  colour = clinical range',...
    'FontSize',7.5,'ForegroundColor',[0.60 0.80 0.60],...
    'BackgroundColor',[0.12 0.14 0.18],'HorizontalAlignment','center');

% Input parameters
pNames={'Age',   'Blood Pressure','Cholesterol','Heart Rate','BMI'};
pUnits={'years', 'mmHg',          'mg/dL',      'bpm',       'kg/m²'};
pMin  =[20,       80,              100,           40,          14  ];
pMax  =[90,      200,              400,          130,          45  ];
pDef  =[45,      120,              200,           72,          24  ];
pFmt  ={'%.0f',  '%.0f',           '%.0f',        '%.0f',      '%.1f'};
normTx={'20–45','80–120','100–200','60–80','18.5–24.9'};

% 5 input cards — evenly spaced in the top-row left column
cardH=50; cardGap=4;
cardTop=R3Y+R3H-HDR*2-4;
editBoxes=cell(1,5);
mfLow=gobjects(1,5); mfMed=gobjects(1,5); mfHi=gobjects(1,5);

for k=1:5
    yy = cardTop - (k-1)*(cardH+cardGap);
    % card background
    uicontrol('Style','frame','Position',[LX yy LW cardH],...
        'BackgroundColor',[0.15 0.18 0.26],'ForegroundColor',[0.22 0.28 0.40]);
    % parameter label  (left)
    uicontrol('Style','text','Position',[LX+4 yy+cardH-17 160 14],...
        'String',sprintf('%s  (%s)',pNames{k},pUnits{k}),...
        'FontSize',7,'FontWeight','bold','ForegroundColor',[0.65 0.80 1.0],...
        'BackgroundColor',[0.15 0.18 0.26],'HorizontalAlignment','left');
    % normal range hint (right)
    uicontrol('Style','text','Position',[LX+160 yy+cardH-17 124 14],...
        'String',sprintf('Normal: %s',normTx{k}),...
        'FontSize',6.5,'ForegroundColor',[0.45 0.75 0.45],...
        'BackgroundColor',[0.15 0.18 0.26],'HorizontalAlignment','right');
    % edit box
    editBoxes{k}=uicontrol('Style','edit','Position',[LX+4 yy+19 LW-8 22],...
        'String',sprintf(pFmt{k},pDef(k)),...
        'FontSize',14,'FontWeight','bold','ForegroundColor','w',...
        'BackgroundColor',[0.08 0.35 0.18],...
        'HorizontalAlignment','center',...
        'Callback',{@inputCB,fig});
    % MF degree labels
    mfLow(k)=uicontrol('Style','text','Position',[LX+4   yy+3 88 14],...
        'String','Low: —','FontSize',6.5,'FontWeight','bold',...
        'ForegroundColor',[0.15 0.90 0.60],'BackgroundColor',[0.15 0.18 0.26]);
    mfMed(k)=uicontrol('Style','text','Position',[LX+96  yy+3 88 14],...
        'String','Med: —','FontSize',6.5,'FontWeight','bold',...
        'ForegroundColor',[0.98 0.78 0.20],'BackgroundColor',[0.15 0.18 0.26]);
    mfHi(k) =uicontrol('Style','text','Position',[LX+188 yy+3 96 14],...
        'String','High: —','FontSize',6.5,'FontWeight','bold',...
        'ForegroundColor',[1.0 0.40 0.40],'BackgroundColor',[0.15 0.18 0.26]);
end

% ── Action buttons ─────────────────────────────────────────────
btnY = cardTop - 5*(cardH+cardGap) - 4;
btnW = (LW-8)/3;
uicontrol('Style','pushbutton','Position',[LX+2        btnY btnW-2 26],...
    'String','↺ Reset','FontSize',8.5,'FontWeight','bold',...
    'ForegroundColor','w','BackgroundColor',[0.28 0.15 0.42],...
    'Callback',{@resetCB,fig});
uicontrol('Style','pushbutton','Position',[LX+2+btnW   btnY btnW-2 26],...
    'String','💾 Save','FontSize',8.5,'FontWeight','bold',...
    'ForegroundColor','w','BackgroundColor',[0.10 0.35 0.25],...
    'Callback',{@saveCB,fig});
uicontrol('Style','pushbutton','Position',[LX+2+btnW*2 btnY btnW-2 26],...
    'String','📄 Export','FontSize',8.5,'FontWeight','bold',...
    'ForegroundColor','w','BackgroundColor',[0.35 0.25 0.08],...
    'Callback',{@exportCB,fig});

% ── Risk Gauge (speedometer) ───────────────────────────────────
gaugeH = btnY - R2Y - 8;          % fills space between buttons and mid-row
gaugeY = R2Y + 4;
ax_gauge=axes('Position',[LX/FW, (gaugeY+gaugeH*0.30)/FH, LW/FW, (gaugeH*0.65)/FH]);
ax_gauge.Color=[0.10 0.12 0.16]; axis(ax_gauge,'off');
hold(ax_gauge,'on');
% arc zones
zones={[pi, 2*pi/3],[2*pi/3, pi/3],[pi/3, 0]};
r1=0.82; r2=1.0;
for z=1:3
    t=linspace(zones{z}(1),zones{z}(2),60);
    xo=r2*cos(t); yo=r2*sin(t);
    xi=r1*cos(t); yi=r1*sin(t);
    fill(ax_gauge,[xo fliplr(xi)],[yo fliplr(yi)],MC{z},...
        'EdgeColor','none','FaceAlpha',0.88);
end
% tick marks & labels
tickVals=0:20:100;
for tv=1:numel(tickVals)
    ang=pi*(1-tickVals(tv)/100);
    plot(ax_gauge,[0.79*cos(ang),1.04*cos(ang)],[0.79*sin(ang),1.04*sin(ang)],...
        'w-','LineWidth',1.0);
    text(ax_gauge,1.16*cos(ang),1.16*sin(ang),num2str(tickVals(tv)),...
        'Color',[0.60 0.68 0.82],'FontSize',6.5,'HorizontalAlignment','center',...
        'VerticalAlignment','middle');
end
text(ax_gauge,-0.98,0.06,'LOW', 'Color',MC{1},'FontSize',7,'FontWeight','bold');
text(ax_gauge, 0.00,1.08,'MED', 'Color',MC{2},'FontSize',7,'FontWeight','bold','HorizontalAlignment','center');
text(ax_gauge, 0.80,0.06,'HIGH','Color',MC{3},'FontSize',7,'FontWeight','bold','HorizontalAlignment','right');
% needle
ang0=pi; hNeedle=plot(ax_gauge,[0, 0.73*cos(ang0)],[0, 0.73*sin(ang0)],...
    'w-','LineWidth',3);
plot(ax_gauge,0,0,'wo','MarkerSize',7,'MarkerFaceColor','w');
hGaugeScore=text(ax_gauge,0,-0.22,'—',...
    'Color','w','FontSize',16,'FontWeight','bold','HorizontalAlignment','center');
hGaugeLbl  =text(ax_gauge,0,-0.44,'',...
    'Color',[0.7 0.7 0.8],'FontSize',8,'FontWeight','bold','HorizontalAlignment','center');
xlim(ax_gauge,[-1.25 1.25]); ylim(ax_gauge,[-0.55 1.25]);

% ── Top-risk warning & advice ──────────────────────────────────
hTopRisk=uicontrol('Style','text',...
    'Position',[LX gaugeY+gaugeH*0.20 LW gaugeH*0.10],...
    'String','','FontSize',7.5,'FontWeight','bold',...
    'ForegroundColor',[1 0.85 0.35],'BackgroundColor',[0.20 0.14 0.04],...
    'HorizontalAlignment','center');
hStatus=uicontrol('Style','text',...
    'Position',[LX gaugeY LW gaugeH*0.18],...
    'String','Adjust values above','FontSize',7.5,...
    'ForegroundColor',[0.65 0.80 0.65],'BackgroundColor',[0.12 0.15 0.12],...
    'HorizontalAlignment','center');

% ── Gauge also covers bottom part (score in R1 area) ───────────
% Score big display in bottom-row left
ax_score=axes('Position',[LX/FW, R1Y/FH, LW/FW, R1H/FH]);
ax_score.Color=[0.12 0.15 0.20]; axis(ax_score,'off');
hold(ax_score,'on');
% border rectangle
rectangle(ax_score,'Position',[0.02 0.02 0.96 0.96],'Curvature',[0.12 0.12],...
    'EdgeColor',[0.30 0.35 0.50],'LineWidth',2,'FaceColor',[0.14 0.17 0.24]);
hScoreNum=text(ax_score,0.5,0.62,'—%','Units','normalized',...
    'Color','w','FontSize',30,'FontWeight','bold','HorizontalAlignment','center',...
    'VerticalAlignment','middle');
hScoreLbl=text(ax_score,0.5,0.32,'—','Units','normalized',...
    'Color',[0.70 0.75 0.85],'FontSize',11,'FontWeight','bold','HorizontalAlignment','center');
hScoreAdv=text(ax_score,0.5,0.12,'Enter patient values','Units','normalized',...
    'Color',[0.55 0.65 0.55],'FontSize',7,'HorizontalAlignment','center',...
    'VerticalAlignment','middle');
xlim(ax_score,[0 1]); ylim(ax_score,[0 1]);

% ================================================================
%  MID COLUMN — TOP ROW: MF overview (5 mini plots)
% ================================================================
uicontrol('Style','text','Position',[MX R3Y+R3H-HDR MW HDR],...
    'String','LIVE MEMBERSHIP FUNCTIONS  —  white line = patient value',...
    'FontSize',9,'FontWeight','bold','ForegroundColor',[0.75 0.88 1.0],...
    'BackgroundColor',[0.16 0.26 0.48],'HorizontalAlignment','center');
uicontrol('Style','pushbutton','Position',[MX+MW-92 R3Y+R3H-HDR 90 HDR],...
    'String','⤢ MF Plots','FontSize',8,'FontWeight','bold',...
    'ForegroundColor','w','BackgroundColor',[0.30 0.15 0.50],...
    'Callback',{@popupMF,fig});

mfPlotH = R3H - HDR - 6;
mfPlotY = R3Y + 3;
mfPlotW = floor((MW-6)/5);

mf_xR={linspace(20,90,200),linspace(80,200,200),linspace(100,400,200),...
       linspace(40,130,200),linspace(14,45,200)};
mf_defs={
    {@(x)trapmf(x,20,20,35,50),@(x)trimf(x,35,52,70),@(x)trapmf(x,55,68,90,90)};
    {@(x)trapmf(x,80,80,110,130),@(x)trimf(x,115,135,155),@(x)trapmf(x,140,160,200,200)};
    {@(x)trapmf(x,100,100,170,210),@(x)trimf(x,190,230,270),@(x)trapmf(x,250,290,400,400)};
    {@(x)trapmf(x,40,40,65,80),@(x)trimf(x,68,80,95),@(x)trapmf(x,88,100,130,130)};
    {@(x)trapmf(x,14,14,20,25),@(x)trimf(x,22,27,32),@(x)trapmf(x,29,34,45,45)};
};
mf_names={'Age','BP','Chol','HR','BMI'};
mf_vlines=gobjects(1,5); ax_mf=gobjects(1,5);

for k=1:5
    xpx = MX + (k-1)*mfPlotW + 2;
    ax=axes('Position',[(xpx)/FW, (mfPlotY)/FH, (mfPlotW-4)/FW, (mfPlotH)/FH]);
    ax.Color=[0.14 0.17 0.25];
    ax.XColor=[0.45 0.55 0.68]; ax.YColor=[0.45 0.55 0.68];
    hold(ax,'on'); ax.XTick=[]; ax.YTick=[];
    xlim(ax,mf_xR{k}([1 end])); ylim(ax,[0 1.15]);
    title(ax,mf_names{k},'Color',[0.80 0.90 1.0],'FontSize',8,'FontWeight','bold');
    x=mf_xR{k};
    for m=1:3
        y=arrayfun(mf_defs{k}{m},x);
        fill(ax,x,y,MC{m},'FaceAlpha',0.28,'EdgeColor','none');
        plot(ax,x,y,'Color',MC{m},'LineWidth',1.8);
    end
    mf_vlines(k)=xline(ax,pDef(k),'w-','LineWidth',2);
    ax_mf(k)=ax;
end

% ================================================================
%  MID COLUMN — MIDDLE ROW: Rule activation bars
% ================================================================
uicontrol('Style','text','Position',[MX R2Y+R2H-HDR MW-94 HDR],...
    'String','RULE ACTIVATION STRENGTHS  (12 rules)',...
    'FontSize',9,'FontWeight','bold','ForegroundColor',[0.75 0.88 1.0],...
    'BackgroundColor',[0.12 0.14 0.18],'HorizontalAlignment','left');
uicontrol('Style','pushbutton','Position',[MX+MW-92 R2Y+R2H-HDR 90 HDR],...
    'String','⤢ Open','FontSize',8,'FontWeight','bold',...
    'ForegroundColor','w','BackgroundColor',[0.48 0.25 0.06],...
    'Callback',{@popupRules,fig});

ax_rules=axes('Position',[MX/FW, R2Y/FH, (MW-2)/FW, (R2H-HDR-4)/FH]);
ax_rules.Color=[0.14 0.17 0.25];
ax_rules.XColor=[0.45 0.55 0.68]; ax_rules.YColor=[0.50 0.62 0.78];
hold(ax_rules,'on');
rule_names={'R1:Age↑&BP↑','R2:Age↑&Ch↑','R3:BP↑&Ch↑','R4:Age↑&HR↑',...
            'R5:BP↑&BMI↑','R6:HR↑&BMI↑','R7:MedCombo','R8:BP✓&HR✓',...
            'R9:Ch✓&BMI✓','R10:AllLow','R11:Age↓BMI↓','R12:AllNrm'};
rule_cols=[repmat([0.85 0.20 0.20],6,1); repmat([0.94 0.60 0.10],3,1); repmat([0.10 0.65 0.42],3,1)];
hRuleBars=barh(ax_rules,1:12,zeros(12,1),'FaceColor','flat');
hRuleBars.CData=rule_cols;
xlim(ax_rules,[0 1]); ylim(ax_rules,[0.4 12.6]);
set(ax_rules,'YTick',1:12,'YTickLabel',rule_names,'FontSize',7,...
    'TickLabelInterpreter','none');
xlabel(ax_rules,'Strength','Color',[0.5 0.6 0.7],'FontSize',7.5);
grid(ax_rules,'on'); ax_rules.GridColor=[0.25 0.30 0.38]; ax_rules.GridAlpha=0.4;
xline(ax_rules,0.5,'w--','LineWidth',1.0);
hRuleTxt=gobjects(1,12);
for r=1:12
    hRuleTxt(r)=text(ax_rules,0.01,r,'',...
        'Color','w','FontSize',6,'VerticalAlignment','middle');
end

% ================================================================
%  MID COLUMN — BOTTOM ROW: Surface plot
% ================================================================
uicontrol('Style','text','Position',[MX R1Y+R1H-HDR MW-94 HDR],...
    'String','SURFACE: Age vs Blood Pressure',...
    'FontSize',9,'FontWeight','bold','ForegroundColor',[0.75 0.88 1.0],...
    'BackgroundColor',[0.12 0.14 0.18],'HorizontalAlignment','left');
uicontrol('Style','pushbutton','Position',[MX+MW-92 R1Y+R1H-HDR 90 HDR],...
    'String','⤢ Open','FontSize',8,'FontWeight','bold',...
    'ForegroundColor','w','BackgroundColor',[0.06 0.35 0.28],...
    'Callback',{@popupSurface,fig});

ax_surf=axes('Position',[MX/FW, R1Y/FH, (MW-2)/FW, (R1H-HDR-4)/FH]);
ax_surf.Color=[0.10 0.12 0.16];
fprintf('⏳ Building surface...\n');
N=28; ages_s=linspace(20,90,N); bps_s=linspace(80,200,N); Zs=zeros(N,N);
for ri=1:N
    for ci=1:N, Zs(ri,ci)=fuzzy_infer(ages_s(ci),bps_s(ri),200,72,25)/100; end
end
[As,Bs]=meshgrid(ages_s,bps_s);
surf(ax_surf,As,Bs,Zs,'EdgeColor','none','FaceColor','interp','FaceAlpha',0.90);
colormap(ax_surf,jet); clim(ax_surf,[0 1]);
hold(ax_surf,'on');
hDot=plot3(ax_surf,45,120,fuzzy_infer(45,120,200,72,25)/100,...
    'wo','MarkerSize',12,'MarkerFaceColor','w','LineWidth',1.8);
xlabel(ax_surf,'Age (years)','Color',[0.65 0.75 0.90],'FontSize',7.5);
ylabel(ax_surf,'BP (mmHg)',  'Color',[0.65 0.75 0.90],'FontSize',7.5);
zlabel(ax_surf,'Risk',       'Color',[0.65 0.75 0.90],'FontSize',7.5);
ax_surf.XColor=[0.55 0.65 0.80]; ax_surf.YColor=[0.55 0.65 0.80]; ax_surf.ZColor=[0.55 0.65 0.80];
zlim(ax_surf,[0 1]); view(ax_surf,-42,26); grid(ax_surf,'on');
title(ax_surf,'⚪ = patient position','Color',[0.65 0.75 0.88],'FontSize',7.5);

% ================================================================
%  RIGHT COLUMN — TOP ROW: Radar chart
% ================================================================
uicontrol('Style','text','Position',[RX R3Y+R3H-HDR RW-94 HDR],...
    'String','RISK RADAR — factor contributions',...
    'FontSize',9,'FontWeight','bold','ForegroundColor',[0.75 0.88 1.0],...
    'BackgroundColor',[0.16 0.26 0.48],'HorizontalAlignment','left');
uicontrol('Style','pushbutton','Position',[RX+RW-92 R3Y+R3H-HDR 90 HDR],...
    'String','⤢ Radar','FontSize',8,'FontWeight','bold',...
    'ForegroundColor','w','BackgroundColor',[0.14 0.30 0.50],...
    'Callback',{@popupRadar,fig});

ax_radar=axes('Position',[(RX+10)/FW, (mfPlotY)/FH, (RW-20)/FW, (mfPlotH)/FH]);
ax_radar.Color=[0.13 0.16 0.23]; axis(ax_radar,'off');
hold(ax_radar,'on');
N_ax=5; angles_r=linspace(pi/2,pi/2+2*pi,N_ax+1); angles_r=angles_r(1:end-1);
radarLbls={'Age','BP','Chol','HR','BMI'};
for ring=[0.25 0.5 0.75 1.0]
    xr=ring*cos(angles_r); yr=ring*sin(angles_r);
    fill(ax_radar,[xr xr(1)],[yr yr(1)],[0.16 0.20 0.30],...
        'FaceAlpha',0,'EdgeColor',[0.28 0.34 0.46],'LineWidth',0.8);
    if ring<1
        text(ax_radar,0,ring+0.04,sprintf('%d%%',round(ring*100)),...
            'Color',[0.38 0.48 0.62],'FontSize',6,'HorizontalAlignment','center');
    end
end
for aa=1:N_ax
    plot(ax_radar,[0 cos(angles_r(aa))],[0 sin(angles_r(aa))],...
        'Color',[0.32 0.38 0.52],'LineWidth',0.8);
    text(ax_radar,1.22*cos(angles_r(aa)),1.22*sin(angles_r(aa)),radarLbls{aa},...
        'Color',[0.78 0.88 1.0],'FontSize',8,'FontWeight','bold',...
        'HorizontalAlignment','center','VerticalAlignment','middle');
end
hRadarPatch=fill(ax_radar,zeros(1,N_ax),zeros(1,N_ax),[0.85 0.20 0.20],...
    'FaceAlpha',0.35,'EdgeColor',[1 0.4 0.4],'LineWidth',2);
hRadarDots=plot(ax_radar,zeros(1,N_ax),zeros(1,N_ax),'o',...
    'MarkerSize',5,'MarkerFaceColor','w','MarkerEdgeColor','w');
hRadarPct=gobjects(1,5);
for aa=1:N_ax
    hRadarPct(aa)=text(ax_radar,...
        1.45*cos(angles_r(aa)), 1.45*sin(angles_r(aa)),'—%',...
        'Color',[0.80 0.80 0.80],'FontSize',7,'HorizontalAlignment','center');
end
xlim(ax_radar,[-1.55 1.55]); ylim(ax_radar,[-1.55 1.55]);

% ================================================================
%  RIGHT COLUMN — MIDDLE ROW: Output MF
% ================================================================
uicontrol('Style','text','Position',[RX R2Y+R2H-HDR RW-94 HDR],...
    'String','OUTPUT MEMBERSHIP FUNCTION',...
    'FontSize',9,'FontWeight','bold','ForegroundColor',[0.75 0.88 1.0],...
    'BackgroundColor',[0.12 0.14 0.18],'HorizontalAlignment','left');
uicontrol('Style','pushbutton','Position',[RX+RW-92 R2Y+R2H-HDR 90 HDR],...
    'String','⤢ Open','FontSize',8,'FontWeight','bold',...
    'ForegroundColor','w','BackgroundColor',[0.06 0.28 0.48],...
    'Callback',{@popupOutputMF,fig});

ax_out=axes('Position',[RX/FW, R2Y/FH, RW/FW, (R2H-HDR-4)/FH]);
ax_out.Color=[0.14 0.17 0.25];
ax_out.XColor=[0.45 0.55 0.68]; ax_out.YColor=[0.45 0.55 0.68];
hold(ax_out,'on');
x_out=linspace(0,100,300);
out_defs={@(x)trapmf(x,0,0,20,40),@(x)trimf(x,30,50,70),@(x)trapmf(x,60,80,100,100)};
out_lbls={'Low Risk','Medium Risk','High Risk'};
for m=1:3
    y=arrayfun(out_defs{m},x_out);
    fill(ax_out,x_out,y,MC{m},'FaceAlpha',0.28,'EdgeColor','none');
    plot(ax_out,x_out,y,'Color',MC{m},'LineWidth',2.0);
end
% zone background shading
patch(ax_out,[0 33 33 0],[0 0 1.1 1.1],MC{1},'FaceAlpha',0.06,'EdgeColor','none');
patch(ax_out,[33 66 66 33],[0 0 1.1 1.1],MC{2},'FaceAlpha',0.06,'EdgeColor','none');
patch(ax_out,[66 100 100 66],[0 0 1.1 1.1],MC{3},'FaceAlpha',0.06,'EdgeColor','none');
text(ax_out,16,1.05,'LOW',   'Color',MC{1},'FontSize',8,'FontWeight','bold','HorizontalAlignment','center');
text(ax_out,49,1.05,'MEDIUM','Color',MC{2},'FontSize',8,'FontWeight','bold','HorizontalAlignment','center');
text(ax_out,83,1.05,'HIGH',  'Color',MC{3},'FontSize',8,'FontWeight','bold','HorizontalAlignment','center');
hOutLine=xline(ax_out,45,'w-','LineWidth',2.5);
xlim(ax_out,[0 100]); ylim(ax_out,[0 1.12]);
xlabel(ax_out,'Risk Score (%)','Color',[0.5 0.6 0.7],'FontSize',8);
ylabel(ax_out,'Membership',    'Color',[0.5 0.6 0.7],'FontSize',8);
% NO legend — eliminates the "data1/data2" garbage labels

% ================================================================
%  RIGHT COLUMN — BOTTOM ROW: Factor contribution bars
% ================================================================
uicontrol('Style','text','Position',[RX R1Y+R1H-HDR RW-94 HDR],...
    'String','FACTOR RISK CONTRIBUTIONS',...
    'FontSize',9,'FontWeight','bold','ForegroundColor',[0.75 0.88 1.0],...
    'BackgroundColor',[0.12 0.14 0.18],'HorizontalAlignment','left');
uicontrol('Style','pushbutton','Position',[RX+RW-92 R1Y+R1H-HDR 90 HDR],...
    'String','⤢ Open','FontSize',8,'FontWeight','bold',...
    'ForegroundColor','w','BackgroundColor',[0.35 0.10 0.10],...
    'Callback',{@popupFactors,fig});

ax_fac=axes('Position',[RX/FW, R1Y/FH, RW/FW, (R1H-HDR-4)/FH]);
ax_fac.Color=[0.14 0.17 0.25];
ax_fac.XColor=[0.45 0.55 0.68]; ax_fac.YColor=[0.45 0.55 0.68];
hold(ax_fac,'on');
hFacBar=bar(ax_fac,1:5,zeros(1,5),'FaceColor','flat','BarWidth',0.60);
hFacBar.CData=repmat([0.28 0.42 0.68],5,1);
ylim(ax_fac,[0 105]); xlim(ax_fac,[0.3 5.7]);
set(ax_fac,'XTick',1:5,'XTickLabel',{'Age','BP','Chol','HR','BMI'},'FontSize',8.5);
ylabel(ax_fac,'Risk Contribution (%)','Color',[0.5 0.6 0.7],'FontSize',8);
yline(ax_fac,33,'--','Color',MC{1},'LineWidth',1.5,'Label','33%',...
    'LabelColor',MC{1},'FontSize',7);
yline(ax_fac,66,'--','Color',MC{3},'LineWidth',1.5,'Label','66%',...
    'LabelColor',MC{3},'FontSize',7);
grid(ax_fac,'on'); ax_fac.GridColor=[0.25 0.30 0.38]; ax_fac.GridAlpha=0.4;
hFacTxt=gobjects(1,5);
for f=1:5
    hFacTxt(f)=text(ax_fac,f,8,'—',...
        'HorizontalAlignment','center','FontSize',9,'FontWeight','bold','Color','w');
end

% ================================================================
%  HISTORY COLUMN  (far right, x=1405)
% ================================================================
uicontrol('Style','text','Position',[HX R3Y+R3H-HDR HW HDR],...
    'String','HISTORY','FontSize',8,'FontWeight','bold',...
    'ForegroundColor','w','BackgroundColor',[0.18 0.26 0.18],...
    'HorizontalAlignment','center');

hHistBox=uicontrol('Style','listbox',...
    'Position',[HX R1Y+R1H HW R3Y+R3H-HDR-(R1Y+R1H)-2],...
    'String',{},'FontSize',7,'ForegroundColor',[0.85 0.95 0.75],...
    'BackgroundColor',[0.11 0.15 0.11],'Callback',{@historyCB,fig});

uicontrol('Style','pushbutton','Position',[HX R1Y+R1H-26 HW 24],...
    'String','🗑  Clear','FontSize',7.5,'FontWeight','bold',...
    'ForegroundColor','w','BackgroundColor',[0.28 0.10 0.10],...
    'Callback',{@clearHistCB,fig});

uicontrol('Style','text','Position',[HX R1Y+R1H-46 HW 18],...
    'String','Score Track','FontSize',7,'ForegroundColor',[0.55 0.72 0.55],...
    'BackgroundColor',[0.10 0.12 0.10],'HorizontalAlignment','center');

ax_hist=axes('Position',[(HX+2)/FW, (R1Y+4)/FH, (HW-4)/FW, (R1H-56)/FH]);
ax_hist.Color=[0.09 0.13 0.09];
ax_hist.XColor=[0.38 0.50 0.38]; ax_hist.YColor=[0.38 0.50 0.38];
hold(ax_hist,'on'); grid(ax_hist,'on');
ax_hist.GridColor=[0.18 0.26 0.18]; ax_hist.GridAlpha=0.5;
ylim(ax_hist,[0 100]); xlim(ax_hist,[0.5 10.5]);
yline(ax_hist,33,'--','Color',MC{1},'LineWidth',1.0);
yline(ax_hist,66,'--','Color',MC{3},'LineWidth',1.0);
hHistPlot=plot(ax_hist,nan,nan,'w-o','MarkerSize',4,'MarkerFaceColor','w','LineWidth',1.2);
set(ax_hist,'XTick',[],'FontSize',6);
ylabel(ax_hist,'%','Color',[0.45 0.62 0.45],'FontSize',7);

% ================================================================
%  Store ALL handles in guidata
% ================================================================
H.editBoxes=editBoxes;
H.mfLow=mfLow; H.mfMed=mfMed; H.mfHi=mfHi;
H.hNeedle=hNeedle; H.hGaugeScore=hGaugeScore; H.hGaugeLbl=hGaugeLbl;
H.hScoreNum=hScoreNum; H.hScoreLbl=hScoreLbl; H.hScoreAdv=hScoreAdv;
H.hTopRisk=hTopRisk; H.hStatus=hStatus; H.hStatusMain=hStatusMain;
H.mf_vlines=mf_vlines; H.mf_xR=mf_xR; H.mf_defs=mf_defs;
H.mf_names=mf_names;
H.hRuleBars=hRuleBars; H.hRuleTxt=hRuleTxt;
H.hOutLine=hOutLine;
H.hRadarPatch=hRadarPatch; H.hRadarDots=hRadarDots;
H.hRadarPct=hRadarPct; H.angles_r=angles_r;
H.hDot=hDot; H.Zs=Zs; H.ages_s=ages_s; H.bps_s=bps_s; H.As=As; H.Bs=Bs;
H.ax_surf=ax_surf; H.ax_out=ax_out; H.ax_rules=ax_rules;
H.ax_mf=ax_mf; H.ax_gauge=ax_gauge;
H.hFacBar=hFacBar; H.hFacTxt=hFacTxt;
H.hHistBox=hHistBox; H.hHistPlot=hHistPlot;
H.pFmt=pFmt; H.pMin=pMin; H.pMax=pMax; H.pDef=pDef;
H.pNames=pNames; H.pUnits=pUnits;
H.MC=MC; H.out_defs=out_defs; H.out_lbls=out_lbls;
H.rule_names=rule_names; H.rule_cols=rule_cols;
H.history=struct('vals',{},'score',{},'label',{});
guidata(fig,H);

doUpdate(fig);
fprintf('✅  Dashboard v4 (clean layout) ready!\n');

% ================================================================
%  CALLBACKS
% ================================================================
function inputCB(src,~,fig)
    H=guidata(fig);
    k=0; for kk=1:5, if H.editBoxes{kk}==src, k=kk; break; end; end
    if k==0, return; end
    raw=strtrim(get(src,'String'));
    val=str2double(raw);
    if isnan(val)
        set(src,'BackgroundColor',[0.50 0.10 0.10]);
        set(H.hStatusMain,'String',...
            sprintf('⚠  Invalid input for %s — type a number',H.pNames{k}),...
            'ForegroundColor',[1 0.4 0.4]);
        pause(0.05); drawnow;
        set(src,'BackgroundColor',[0.08 0.35 0.18]);
        return;
    end
    val=max(H.pMin(k),min(H.pMax(k),val));
    set(src,'String',sprintf(H.pFmt{k},val));
    hc=inputHintColor(k,val);
    set(src,'BackgroundColor',hc+[0.04 0.04 0.04]);
    pause(0.04); drawnow;
    set(src,'BackgroundColor',hc);
    doUpdate(fig);
end

function resetCB(~,~,fig)
    H=guidata(fig);
    for k=1:5
        set(H.editBoxes{k},'String',sprintf(H.pFmt{k},H.pDef(k)),...
            'BackgroundColor',[0.08 0.35 0.18]);
    end
    doUpdate(fig);
end

function saveCB(~,~,fig)
    H=guidata(fig);
    vals=readVals(H);
    [score,~]=fuzzy_infer(vals(1),vals(2),vals(3),vals(4),vals(5));
    lbl=riskLabel(score);
    entry.vals=vals; entry.score=score; entry.label=lbl;
    if numel(H.history)>=10, H.history=H.history(2:end); end
    H.history(end+1)=entry;
    n=numel(H.history);
    listStr=cell(n,1);
    for i=1:n
        listStr{i}=sprintf('P%02d | %.0f%% | %s',i,...
            H.history(i).score, H.history(i).label(1:3));
    end
    set(H.hHistBox,'String',listStr,'Value',n);
    scores=arrayfun(@(e)e.score,H.history);
    set(H.hHistPlot,'XData',1:n,'YData',scores);
    guidata(fig,H);
    set(H.hStatusMain,'String',...
        sprintf('✅  Patient %d saved  |  Score=%.1f%%  |  %s',n,score,lbl),...
        'ForegroundColor',[0.4 1 0.4]);
end

function clearHistCB(~,~,fig)
    H=guidata(fig);
    H.history=struct('vals',{},'score',{},'label',{});
    set(H.hHistBox,'String',{},'Value',1);
    set(H.hHistPlot,'XData',nan,'YData',nan);
    guidata(fig,H);
end

function historyCB(~,~,fig)
    H=guidata(fig);
    idx=get(H.hHistBox,'Value');
    if isempty(H.history)||idx>numel(H.history), return; end
    v=H.history(idx).vals;
    for k=1:5
        set(H.editBoxes{k},'String',sprintf(H.pFmt{k},v(k)));
    end
    doUpdate(fig);
    set(H.hStatusMain,'String',...
        sprintf('↩  Loaded Patient %d from history',idx),...
        'ForegroundColor',[0.8 0.8 0.4]);
end

function exportCB(~,~,fig)
    H=guidata(fig);
    vals=readVals(H);
    [score,strengths]=fuzzy_infer(vals(1),vals(2),vals(3),vals(4),vals(5));
    lbl=riskLabel(score);
    mf=fuzzify(vals(1),vals(2),vals(3),vals(4),vals(5));
    mfAll=[mf.age;mf.bp;mf.ch;mf.hr;mf.bmi];
    fname=sprintf('HeartRisk_Report_%s.txt',datestr(now,'yyyymmdd_HHMMSS'));
    fid=fopen(fname,'w');
    fprintf(fid,'=================================================\n');
    fprintf(fid,'  HEART DISEASE RISK ASSESSMENT REPORT\n');
    fprintf(fid,'  Generated: %s\n',datestr(now));
    fprintf(fid,'=================================================\n\n');
    fprintf(fid,'PATIENT PARAMETERS:\n');
    nms={'Age','Blood Pressure','Cholesterol','Heart Rate','BMI'};
    uts={'years','mmHg','mg/dL','bpm','kg/m2'};
    for k=1:5
        fprintf(fid,'  %-20s: %6.1f %s\n',nms{k},vals(k),uts{k});
    end
    fprintf(fid,'\nFUZZY MEMBERSHIP DEGREES:\n');
    rows={'Age','Blood Pres','Cholesterol','Heart Rate','BMI'};
    for k=1:5
        fprintf(fid,'  %-12s  Low=%.3f  Med=%.3f  High=%.3f\n',...
            rows{k},mfAll(k,1),mfAll(k,2),mfAll(k,3));
    end
    fprintf(fid,'\nRULE ACTIVATION STRENGTHS:\n');
    for r=1:12
        fprintf(fid,'  R%02d: %.4f\n',r,strengths(r));
    end
    fprintf(fid,'\n=================================================\n');
    fprintf(fid,'  RISK SCORE  :  %.2f%%\n',score);
    fprintf(fid,'  RISK LEVEL  :  %s\n',lbl);
    fprintf(fid,'=================================================\n');
    fclose(fid);
    set(H.hStatusMain,'String',sprintf('📄  Report saved: %s',fname),...
        'ForegroundColor',[0.8 0.9 0.4]);
end

function vals=readVals(H)
    vals=H.pDef;
    for k=1:5
        v=str2double(strtrim(get(H.editBoxes{k},'String')));
        if ~isnan(v), vals(k)=max(H.pMin(k),min(H.pMax(k),v)); end
    end
end

% ================================================================
%  MASTER UPDATE
% ================================================================
function doUpdate(fig)
    H=guidata(fig);
    vals=readVals(H);
    Age=vals(1); BP=vals(2); Chol=vals(3); HR=vals(4); BMI=vals(5);

    [score,strengths]=fuzzy_infer(Age,BP,Chol,HR,BMI);
    col=riskColor(score); lbl=riskLabel(score);
    mf=fuzzify(Age,BP,Chol,HR,BMI);
    mfAll=[mf.age;mf.bp;mf.ch;mf.hr;mf.bmi];

    % 1. Input box clinical colours
    for k=1:5
        set(H.editBoxes{k},'BackgroundColor',inputHintColor(k,vals(k)));
    end

    % 2. MF vertical lines + degree labels
    for k=1:5
        set(H.mf_vlines(k),'Value',vals(k));
        set(H.mfLow(k),'String',sprintf('L:%.2f',mfAll(k,1)));
        set(H.mfMed(k),'String',sprintf('M:%.2f',mfAll(k,2)));
        set(H.mfHi(k), 'String',sprintf('H:%.2f',mfAll(k,3)));
    end

    % 3. Gauge needle
    ang=pi*(1-score/100);
    set(H.hNeedle,'XData',[0, 0.73*cos(ang)],'YData',[0, 0.73*sin(ang)],'Color',col);
    set(H.hGaugeScore,'String',sprintf('%.1f%%',score),'Color',col);
    set(H.hGaugeLbl,  'String',lbl,'Color',col);

    % 4. Score box
    set(H.hScoreNum,'String',sprintf('%.1f%%',score),'Color',col);
    set(H.hScoreLbl,'String',lbl,'Color',col);

    % 5. Advice text
    if score<33
        adv='✅ Low risk — maintain healthy lifestyle';
        advC=[0.30 0.92 0.52];
    elseif score<66
        adv='⚠ Medium risk — consult a physician';
        advC=[1.00 0.80 0.20];
    else
        adv='🚨 High risk — urgent referral recommended';
        advC=[1.00 0.45 0.45];
    end
    set(H.hScoreAdv,'String',adv,'Color',advC);

    % 6. Rule bars + inline text
    set(H.hRuleBars,'YData',strengths');
    for r=1:12
        if strengths(r)>0.02
            set(H.hRuleTxt(r),'String',sprintf('%.3f',strengths(r)),...
                'Position',[strengths(r)+0.01, r, 0]);
        else
            set(H.hRuleTxt(r),'String','');
        end
    end

    % 7. Output MF score line
    set(H.hOutLine,'Value',score);

    % 8. Surface dot
    dotZ=interp2(H.ages_s,H.bps_s',H.Zs,Age,BP,'linear',0);
    set(H.hDot,'XData',Age,'YData',BP,'ZData',dotZ+0.015);

    % 9. Factor bars + radar
    facScores=zeros(1,5);
    for f=1:5
        lo=mfAll(f,1); me=mfAll(f,2); hi=mfAll(f,3);
        facScores(f)=(lo*15+me*50+hi*85)/max(lo+me+hi,1e-9);
    end
    newCData=zeros(5,3);
    for f=1:5, newCData(f,:)=riskColor(facScores(f)); end
    set(H.hFacBar,'YData',facScores,'CData',newCData);
    for f=1:5
        set(H.hFacTxt(f),'Position',[f, facScores(f)+4, 0],...
            'String',sprintf('%.0f%%',facScores(f)),'Color',riskColor(facScores(f)));
    end

    % 10. Radar update
    rv=facScores/100;
    a=H.angles_r;
    set(H.hRadarPatch,'XData',rv.*cos(a),'YData',rv.*sin(a),...
        'FaceColor',col,'EdgeColor',col);
    set(H.hRadarDots,'XData',rv.*cos(a),'YData',rv.*sin(a));
    for aa=1:5
        set(H.hRadarPct(aa),'String',sprintf('%.0f%%',facScores(aa)),...
            'Color',riskColor(facScores(aa)));
    end

    % 11. Top-risk warning
    [maxFac,maxIdx]=max(facScores);
    facNamesShort={'Age','BP','Cholesterol','Heart Rate','BMI'};
    if maxFac>60
        set(H.hTopRisk,'String',...
            sprintf('⚠  Top factor: %s  (%.0f%%)',facNamesShort{maxIdx},maxFac),...
            'BackgroundColor',[0.24 0.14 0.04],'ForegroundColor',[1 0.85 0.3]);
    elseif score>65
        set(H.hTopRisk,'String','🚨  Multiple factors elevated',...
            'BackgroundColor',[0.28 0.06 0.06],'ForegroundColor',[1 0.45 0.45]);
    else
        set(H.hTopRisk,'String','',...
            'BackgroundColor',[0.12 0.15 0.12]);
    end

    % 12. Status bar
    set(H.hStatusMain,'String',...
        sprintf('Age=%.0f  |  BP=%.0f  |  Chol=%.0f  |  HR=%.0f  |  BMI=%.1f   →   Score = %.1f%%   |   %s   |   click ⤢ to expand any panel',...
        Age,BP,Chol,HR,BMI,score,lbl),...
        'ForegroundColor',[0.55 0.80 0.55]);

    guidata(fig,H);
    drawnow limitrate;
end

% ================================================================
%  POPUP WINDOWS
% ================================================================
function popupMF(~,~,fig)
    H=guidata(fig); vals=readVals(H);
    Age=vals(1); BP=vals(2); Chol=vals(3); HR=vals(4); BMI=vals(5);
    mf=fuzzify(Age,BP,Chol,HR,BMI);
    mfAll=[mf.age;mf.bp;mf.ch;mf.hr;mf.bmi];
    MC_=H.MC; mf_xR_=H.mf_xR; mf_defs_=H.mf_defs;
    units_={'years','mmHg','mg/dL','bpm','kg/m²'};
    pf=figure('Name','MF Plots','NumberTitle','off',...
        'Position',[80 80 1200 700],'Color',[0.12 0.14 0.18],...
        'MenuBar','none','ToolBar','figure');
    uicontrol(pf,'Style','text','Position',[0 665 1200 35],...
        'String',sprintf('MEMBERSHIP FUNCTIONS  |  Age=%.0f  BP=%.0f  Chol=%.0f  HR=%.0f  BMI=%.1f',...
        Age,BP,Chol,HR,BMI),...
        'FontSize',12,'FontWeight','bold','ForegroundColor','w',...
        'BackgroundColor',[0.18 0.28 0.58],'HorizontalAlignment','center');
    pos={[0.05 0.54 0.26 0.38],[0.38 0.54 0.26 0.38],[0.71 0.54 0.26 0.38],...
         [0.18 0.06 0.26 0.38],[0.56 0.06 0.26 0.38]};
    names_={'Age','Blood Pressure','Cholesterol','Heart Rate','BMI'};
    for k=1:5
        ax=axes(pf,'Position',pos{k});
        ax.Color=[0.16 0.19 0.26]; ax.XColor=[0.6 0.7 0.8]; ax.YColor=[0.6 0.7 0.8];
        hold(ax,'on'); grid(ax,'on'); ax.GridColor=[0.3 0.35 0.4]; ax.GridAlpha=0.35;
        x=mf_xR_{k};
        for m=1:3
            y=arrayfun(mf_defs_{k}{m},x);
            fill(ax,x,y,MC_{m},'FaceAlpha',0.28,'EdgeColor','none');
            plot(ax,x,y,'Color',MC_{m},'LineWidth',2.2);
        end
        xl=xline(ax,vals(k),'w-','LineWidth',2.5,'Label',sprintf('%.1f',vals(k)));
        xl.LabelColor='w'; xl.FontSize=9; xl.FontWeight='bold';
        xlim(ax,mf_xR_{k}([1 end])); ylim(ax,[0 1.18]);
        title(ax,sprintf('%s (%s)',names_{k},units_{k}),...
            'Color',[0.82 0.92 1.0],'FontSize',11,'FontWeight','bold');
        xlabel(ax,units_{k},'Color',[0.6 0.7 0.8],'FontSize',9);
        ylabel(ax,'Membership','Color',[0.6 0.7 0.8],'FontSize',9);
        deg=mfAll(k,:);
        annotation(pf,'textbox',...
            [pos{k}(1), pos{k}(2)-0.046, pos{k}(3), 0.04],...
            'String',sprintf('Low: %.3f   Med: %.3f   High: %.3f',deg(1),deg(2),deg(3)),...
            'Color',[0.85 0.95 0.75],'FontSize',9,'FontWeight','bold',...
            'BackgroundColor',[0.20 0.23 0.30],'EdgeColor','none',...
            'HorizontalAlignment','center');
        legend(ax,'Low','Medium','High','Location','northeast','FontSize',8,...
            'TextColor','w','Color',[0.18 0.22 0.30],'EdgeColor',[0.4 0.5 0.6]);
    end
end

function popupRules(~,~,fig)
    H=guidata(fig); vals=readVals(H);
    [score,strengths]=fuzzy_infer(vals(1),vals(2),vals(3),vals(4),vals(5));
    lbl=riskLabel(score);
    rn={'R01: Age↑ & BP↑ → HIGH',    'R02: Age↑ & Chol↑ → HIGH',...
        'R03: BP↑ & Chol↑ → HIGH',   'R04: Age↑ & HR↑ → HIGH',...
        'R05: BP↑ & BMI↑ → HIGH',    'R06: HR↑ & BMI↑ → HIGH (×0.9)',...
        'R07: Age✓ & BP✓ & Chol✓ → MED','R08: BP✓ & HR✓ → MED',...
        'R09: Chol✓ & BMI✓ → MED (×0.8)',...
        'R10: Age↓ & BP↓ & Chol↓ → LOW','R11: Age↓ & BMI↓ → LOW (×0.9)',...
        'R12: BP↓ & Chol↓ & HR↓ → LOW (×0.9)'};
    rc=[repmat([0.85 0.20 0.20],6,1);repmat([0.94 0.60 0.10],3,1);repmat([0.10 0.65 0.42],3,1)];
    pf=figure('Name','Rule Activation','NumberTitle','off','Position',[100 80 920 680],...
        'Color',[0.12 0.14 0.18],'MenuBar','none','ToolBar','figure');
    uicontrol(pf,'Style','text','Position',[0 645 920 35],...
        'String',sprintf('RULE ACTIVATION  |  Score=%.1f%%  |  %s',score,lbl),...
        'FontSize',12,'FontWeight','bold','ForegroundColor','w',...
        'BackgroundColor',[0.18 0.28 0.58],'HorizontalAlignment','center');
    ax=axes(pf,'Position',[0.29 0.06 0.68 0.88]);
    ax.Color=[0.16 0.19 0.26]; ax.XColor=[0.6 0.7 0.8]; ax.YColor=[0.7 0.8 0.9];
    hold(ax,'on'); grid(ax,'on'); ax.GridColor=[0.3 0.35 0.4]; ax.GridAlpha=0.4;
    bh=barh(ax,1:12,strengths','FaceColor','flat'); bh.CData=rc;
    xlim(ax,[0 1]); ylim(ax,[0.3 12.7]);
    set(ax,'YTick',1:12,'YTickLabel',rn,'FontSize',9,'TickLabelInterpreter','none');
    xlabel(ax,'Activation Strength','Color',[0.7 0.8 0.9],'FontSize',11,'FontWeight','bold');
    xline(ax,0.5,'w--','LineWidth',1.5,'Label','0.5','LabelColor','w','FontSize',8);
    for r=1:12
        if strengths(r)>0.01
            text(ax,strengths(r)+0.01,r,sprintf('%.4f',strengths(r)),...
                'Color','w','FontSize',9,'FontWeight','bold','VerticalAlignment','middle');
        end
    end
end

function popupOutputMF(~,~,fig)
    H=guidata(fig); vals=readVals(H);
    [score,~]=fuzzy_infer(vals(1),vals(2),vals(3),vals(4),vals(5));
    lbl=riskLabel(score); col=riskColor(score);
    MC_=H.MC; od=H.out_defs;
    pf=figure('Name','Output MF','NumberTitle','off','Position',[120 100 920 560],...
        'Color',[0.12 0.14 0.18],'MenuBar','none','ToolBar','figure');
    uicontrol(pf,'Style','text','Position',[0 525 920 35],...
        'String',sprintf('OUTPUT MF  |  Score=%.1f%%  |  %s',score,lbl),...
        'FontSize',12,'FontWeight','bold','ForegroundColor','w',...
        'BackgroundColor',[0.18 0.28 0.58],'HorizontalAlignment','center');
    ax=axes(pf,'Position',[0.09 0.12 0.87 0.76]);
    ax.Color=[0.16 0.19 0.26]; ax.XColor=[0.6 0.7 0.8]; ax.YColor=[0.6 0.7 0.8];
    hold(ax,'on'); grid(ax,'on'); ax.GridColor=[0.3 0.35 0.4]; ax.GridAlpha=0.4;
    x_out=linspace(0,100,400); lbls={'Low Risk','Medium Risk','High Risk'};
    for m=1:3
        y=arrayfun(od{m},x_out);
        fill(ax,x_out,y,MC_{m},'FaceAlpha',0.30,'EdgeColor','none');
        plot(ax,x_out,y,'Color',MC_{m},'LineWidth',2.5,'DisplayName',lbls{m});
    end
    xl=xline(ax,score,'LineWidth',3.5,'Label',sprintf('%.1f%%  %s',score,lbl));
    xl.Color=col; xl.LabelColor=col; xl.FontSize=11; xl.FontWeight='bold';
    patch(ax,[0 33 33 0],[0 0 1.2 1.2],MC_{1},'FaceAlpha',0.07,'EdgeColor','none');
    patch(ax,[33 66 66 33],[0 0 1.2 1.2],MC_{2},'FaceAlpha',0.07,'EdgeColor','none');
    patch(ax,[66 100 100 66],[0 0 1.2 1.2],MC_{3},'FaceAlpha',0.07,'EdgeColor','none');
    text(ax,16,1.12,'LOW',   'Color',MC_{1},'FontSize',11,'FontWeight','bold','HorizontalAlignment','center');
    text(ax,49,1.12,'MEDIUM','Color',MC_{2},'FontSize',11,'FontWeight','bold','HorizontalAlignment','center');
    text(ax,83,1.12,'HIGH',  'Color',MC_{3},'FontSize',11,'FontWeight','bold','HorizontalAlignment','center');
    xlim(ax,[0 100]); ylim(ax,[0 1.2]);
    xlabel(ax,'Risk Score (%)','Color',[0.7 0.8 0.9],'FontSize',12,'FontWeight','bold');
    ylabel(ax,'Membership Degree','Color',[0.7 0.8 0.9],'FontSize',12,'FontWeight','bold');
    legend(ax,'Low Risk','Medium Risk','High Risk','Location','north','FontSize',10,...
        'TextColor','w','Color',[0.18 0.22 0.30],'EdgeColor',[0.4 0.5 0.6]);
end

function popupSurface(~,~,fig)
    H=guidata(fig); vals=readVals(H);
    Age=vals(1); BP=vals(2); Chol=vals(3); HR=vals(4); BMI=vals(5);
    [score,~]=fuzzy_infer(Age,BP,Chol,HR,BMI); lbl=riskLabel(score);
    pf=figure('Name','Surface — Age vs BP','NumberTitle','off',...
        'Position',[100 60 1020 720],'Color',[0.10 0.12 0.16],...
        'MenuBar','none','ToolBar','figure');
    uicontrol(pf,'Style','text','Position',[0 688 1020 32],...
        'String',sprintf('SURFACE  |  Chol=%.0f  HR=%.0f  BMI=%.1f  |  Score=%.1f%%  |  %s',...
        Chol,HR,BMI,score,lbl),...
        'FontSize',11,'FontWeight','bold','ForegroundColor','w',...
        'BackgroundColor',[0.18 0.28 0.58],'HorizontalAlignment','center');
    ax=axes(pf,'Position',[0.08 0.08 0.80 0.84]);
    ax.Color=[0.10 0.12 0.16];
    ax.XColor=[0.7 0.8 0.9]; ax.YColor=[0.7 0.8 0.9]; ax.ZColor=[0.7 0.8 0.9];
    surf(ax,H.As,H.Bs,H.Zs,'EdgeColor','none','FaceColor','interp','FaceAlpha',0.90);
    colormap(ax,jet); clim(ax,[0 1]);
    cb=colorbar(ax); cb.Color=[0.7 0.8 0.9];
    cb.Label.String='Risk (0–1)'; cb.Label.Color=[0.7 0.8 0.9];
    hold(ax,'on');
    dotZ=interp2(H.ages_s,H.bps_s',H.Zs,Age,BP,'linear',0);
    plot3(ax,Age,BP,dotZ+0.02,'wo','MarkerSize',20,'MarkerFaceColor','w','LineWidth',2);
    text(ax,Age+1,BP+3,dotZ+0.06,...
        sprintf('  Patient\n  (%.0f yr, %.0f mmHg)\n  %.1f%%',Age,BP,score),...
        'Color','w','FontSize',10,'FontWeight','bold');
    xlabel(ax,'Age (years)','Color',[0.8 0.9 1.0],'FontSize',11,'FontWeight','bold');
    ylabel(ax,'Blood Pressure (mmHg)','Color',[0.8 0.9 1.0],'FontSize',11,'FontWeight','bold');
    zlabel(ax,'Risk Score (0–1)','Color',[0.8 0.9 1.0],'FontSize',11,'FontWeight','bold');
    title(ax,'Drag to rotate  |  scroll to zoom',...
        'Color',[0.85 0.92 1.0],'FontSize',11,'FontWeight','bold');
    zlim(ax,[0 1]); view(ax,-42,26); grid(ax,'on'); rotate3d(ax,'on');
end

function popupRadar(~,~,fig)
    H=guidata(fig); vals=readVals(H);
    [score,~]=fuzzy_infer(vals(1),vals(2),vals(3),vals(4),vals(5));
    mf=fuzzify(vals(1),vals(2),vals(3),vals(4),vals(5));
    mfAll=[mf.age;mf.bp;mf.ch;mf.hr;mf.bmi];
    facScores=zeros(1,5);
    for f=1:5
        lo=mfAll(f,1); me=mfAll(f,2); hi=mfAll(f,3);
        facScores(f)=(lo*15+me*50+hi*85)/max(lo+me+hi,1e-9);
    end
    col=riskColor(score); lbl=riskLabel(score);
    pf=figure('Name','Risk Radar','NumberTitle','off','Position',[200 150 640 620],...
        'Color',[0.10 0.12 0.16],'MenuBar','none','ToolBar','figure');
    uicontrol(pf,'Style','text','Position',[0 585 640 35],...
        'String',sprintf('RISK RADAR  |  Score=%.1f%%  |  %s',score,lbl),...
        'FontSize',13,'FontWeight','bold','ForegroundColor','w',...
        'BackgroundColor',[0.18 0.28 0.58],'HorizontalAlignment','center');
    ax=axes(pf,'Position',[0.05 0.06 0.90 0.85]);
    ax.Color=[0.12 0.15 0.22]; axis(ax,'off'); hold(ax,'on');
    N_ax=5; a=linspace(pi/2,pi/2+2*pi,N_ax+1); a=a(1:end-1);
    rlbls={'Age','Blood Pressure','Cholesterol','Heart Rate','BMI'};
    for ri=[0.25 0.5 0.75 1.0]
        xr=ri*cos(a); yr=ri*sin(a);
        fill(ax,[xr xr(1)],[yr yr(1)],[0.18 0.22 0.32],...
            'FaceAlpha',0,'EdgeColor',[0.30 0.36 0.48],'LineWidth',1.0);
        text(ax,0,ri+0.04,sprintf('%d%%',round(ri*100)),...
            'Color',[0.40 0.50 0.65],'FontSize',8,'HorizontalAlignment','center');
    end
    for aa=1:N_ax
        plot(ax,[0 cos(a(aa))],[0 sin(a(aa))],'Color',[0.35 0.42 0.55],'LineWidth',1.0);
        text(ax,1.22*cos(a(aa)),1.22*sin(a(aa)),rlbls{aa},...
            'Color',[0.82 0.90 1.0],'FontSize',11,'FontWeight','bold',...
            'HorizontalAlignment','center','VerticalAlignment','middle');
        text(ax,1.22*cos(a(aa)),1.22*sin(a(aa))-0.14,...
            sprintf('%.0f%%',facScores(aa)),...
            'Color',riskColor(facScores(aa)),'FontSize',9,'HorizontalAlignment','center');
    end
    rv=facScores/100;
    fill(ax,rv.*cos(a),rv.*sin(a),col,'FaceAlpha',0.35,'EdgeColor',col,'LineWidth',2.5);
    plot(ax,rv.*cos(a),rv.*sin(a),'o','MarkerSize',10,...
        'MarkerFaceColor',col,'MarkerEdgeColor','w','LineWidth',1.5);
    xlim(ax,[-1.45 1.45]); ylim(ax,[-1.45 1.45]);
end

function popupFactors(~,~,fig)
    H=guidata(fig); vals=readVals(H);
    [score,~]=fuzzy_infer(vals(1),vals(2),vals(3),vals(4),vals(5));
    lbl=riskLabel(score);
    mf=fuzzify(vals(1),vals(2),vals(3),vals(4),vals(5));
    mfAll=[mf.age;mf.bp;mf.ch;mf.hr;mf.bmi];
    facScores=zeros(1,5);
    for f=1:5
        lo=mfAll(f,1); me=mfAll(f,2); hi=mfAll(f,3);
        facScores(f)=(lo*15+me*50+hi*85)/max(lo+me+hi,1e-9);
    end
    facNames={'Age','Blood Pressure','Cholesterol','Heart Rate','BMI'};
    facUnits={'years','mmHg','mg/dL','bpm','kg/m²'};
    pf=figure('Name','Factor Contributions','NumberTitle','off','Position',[120 80 920 620],...
        'Color',[0.12 0.14 0.18],'MenuBar','none','ToolBar','figure');
    uicontrol(pf,'Style','text','Position',[0 588 920 32],...
        'String',sprintf('FACTOR CONTRIBUTIONS  |  Score=%.1f%%  |  %s',score,lbl),...
        'FontSize',12,'FontWeight','bold','ForegroundColor','w',...
        'BackgroundColor',[0.18 0.28 0.58],'HorizontalAlignment','center');
    ax=axes(pf,'Position',[0.10 0.16 0.82 0.66]);
    ax.Color=[0.16 0.19 0.26]; ax.XColor=[0.6 0.7 0.8]; ax.YColor=[0.6 0.7 0.8];
    hold(ax,'on'); grid(ax,'on'); ax.GridColor=[0.3 0.35 0.4]; ax.GridAlpha=0.4;
    newCData=zeros(5,3);
    for f=1:5, newCData(f,:)=riskColor(facScores(f)); end
    bh=bar(ax,1:5,facScores,'FaceColor','flat','BarWidth',0.55); bh.CData=newCData;
    yline(ax,33,'--','LineWidth',2,'Color',[0.10 0.75 0.45],...
        'Label','Low/Med','LabelColor',[0.10 0.75 0.45],'FontSize',9);
    yline(ax,66,'--','LineWidth',2,'Color',[0.90 0.25 0.25],...
        'Label','Med/High','LabelColor',[0.90 0.25 0.25],'FontSize',9);
    for f=1:5
        text(ax,f,facScores(f)+1.5,sprintf('%.1f%%',facScores(f)),...
            'HorizontalAlignment','center','FontSize',12,'FontWeight','bold','Color','w');
        text(ax,f,-6,sprintf('%.0f %s',vals(f),facUnits{f}),...
            'HorizontalAlignment','center','FontSize',9,'Color',[0.75 0.85 1.0]);
    end
    ylim(ax,[-10 108]); xlim(ax,[0.3 5.7]);
    set(ax,'XTick',1:5,'XTickLabel',facNames,'FontSize',10,'XTickLabelRotation',10);
    ylabel(ax,'Risk Contribution (%)','Color',[0.7 0.8 0.9],'FontSize',11,'FontWeight','bold');
    title(ax,'Per-Factor Cardiovascular Risk Contribution',...
        'Color',[0.85 0.92 1.0],'FontSize',12);
end
