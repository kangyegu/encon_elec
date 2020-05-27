
% Dynamic Electricity price 
pp = xlsread('SMP.csv');
year=floor(pp(:,1)/10000);
month=floor((pp(:,1)-year*10000)/100);
season=zeros(size(pp,1),1);
for kk=1:12
    if (kk>=1 & kk<=2) | (kk>11 & kk<=12);
    season(month==kk,1)=1;
    elseif (kk>=3 & kk<=5) | (kk>=9 & kk<= 11);
    season(month==kk,1)=2;
    elseif (kk>= 6 & kk<=8);
    season(month==kk,1)=3;
    end
end
pp = [pp,year,month,season];

save('smp_mat.mat','pp');

%%
% price data
% column1 : household / c2 : general/ c3 :educational/c4: industrial /c5:
% agriculture / c6: street light/ c7: night / c8: all

clear all; close all;
clc;

%elec price
0.05897/0.1028*100
%best you can get
0.05897/0.1028/0.9/0.9*100

no_battery=0.05897*10/24+0.1028*14/24
with_battery=0.05897*10/24+0.05897/0.9/0.9*14/24
with_battery/no_battery

battery_capacity=800*14/24/0.9
battery_capacity=560*14/24/0.9

%referigerator
0.05085/0.06405*100
530/800*100
%washing machine
0.04617/0.06169*100
668/600*100
%TV
0.03555/0.04419*100
306/560*100

width = 4.5;     % Width in inches
height = 2;    % Height in inches
alw = 0.75;    % AxesLineWidth
fsz = 11;      % Fontsize
lw = 2;      % LineWidth
msz = 10;       % MarkerSize
% The properties we've been using in the figures
set(0,'defaultLineLineWidth',lw);   % set the default line width to lw
set(0,'defaultLineMarkerSize',msz); % set the default line marker size to msz
defpos = get(0,'defaultFigurePosition');
set(0,'defaultFigurePosition', [defpos(1) defpos(2) width*100, height*100]);
set(gca,...
    'Units','normalized',...
    'FontUnits','points',...
    'FontWeight','normal',...
    'FontSize',10,...
    'FontName','Times')

% This price is discrete price schedule : (peak / off peak price)
% discrete price 
load elect_price.mat

min_cost_ref=10000;min_cost_was=10000;min_cost_tv=10000;
max_night= max(price(:,7));
pbar= max_night+1;

load smp_mat.mat
% With dynamic price
smp_pick= pp(:,2:25);
year= pp(:,29);
month=pp(:,30);
season=pp(:,31);

% price graph

pr_elect=zeros(24,1);
pr_elect(1:8,:)=pbar;
pr_elect(23:24,:)=pbar;
pr_elect(9:22,:)=mean(price(:,1));
%pr_dynamic=mean(pr,1)';
ind_time=0:24;
%1163 $/won
figure(1)
pr_elect(end+1)=pr_elect(1);
stairs(ind_time,pr_elect/1163,'linewidth',lw);
% plot(ind_time,pr_elect/1163,ind_time,pr_dynamic/1163);
set(gca,'FontName','Times','FontSize',fsz);

ylim([0,0.15]);
xlim([0,25]);
% title('Electricity price')
xlabel('Time [h]','FontName','Times','FontSize',fsz);
ylabel('[$/kWh]','FontName','Times','FontSize',fsz);
set(gca,'FontName','Times','FontSize',fsz);
saveas(gcf,'fig1.png')

% refrigerator
pd = makedist('Normal','mu',33.3,'sigma',4);
y_ref = random(pd,24,1);
% Washing Machine
y_was = zeros(24,1);
y_was(20)=600;
% TV
pd1 = makedist('Normal','mu',70,'sigma',10);
y_tv=zeros(24,1);
watch = random(pd1,8,1);
y_tv(7:8)= watch(1:2,1);
y_tv(19:24)=watch(3:8,1);
% usage distribution in graph

figure(2)
y_ref(end+1)=y_ref(1);y_was(end+1)=y_was(1);y_tv(end+1)=y_tv(1);
% plot(ind_time,y_ref,ind_time,y_was,ind_time,y_tv);
stairs(ind_time,y_ref,'linewidth',lw);
hold on
stairs(ind_time,y_was,':','linewidth',lw);
stairs(ind_time,y_tv,'-.','linewidth',lw);
ylim([0,800]);
xlim([0,25]);
legend('Refrigerator','Washing machine','TV','Orientation','horizontal','location','North')
% title('Electricity usage profile')
xlabel('Time [h]');
ylabel('[W]');
set(gca,'FontName','Times','FontSize',fsz);
% set(gca,'FontSize',fsz,'XTickLabelRotation',45,'XTick',1:24, 'XTickLabel',{'1' '1' '2' '3' '4' '5' '6' '7' '8' '9' '10' '11' '12' '1' '2' '3' '4' '5' '6' '7' '8' '9' '10' '11'});

saveas(gcf,'fig2.png')

%
% battery efficiency is determined by del1, del2
% in this case, it's 90% efficient
%% Discrete price calculation
% 
% pr_elect : discrete price
del1=0.9;
del2 = 0.9;
x_crate=0.3;

nn=10;
[cost_cal,bat_cal]=discrete_price(del1,del2,x_crate,nn,y_ref,y_was,y_tv,pr_elect);
cost_ref = cost_cal{1,1};
cost_was = cost_cal{2,1};
cost_tv = cost_cal{3,1};

bat_ref=bat_cal{1,1};
bat_was=bat_cal{2,1};
bat_tv=bat_cal{3,1};
% plotting the electricity cost
figure(3);
% plot(cost_ref(:,2), cost_ref(:,1),cost_was(:,2), cost_was(:,1),':',cost_tv(:,2), cost_tv(:,1),'-.');

plot(cost_ref(:,2), cost_ref(:,1)/1163,cost_was(:,2), cost_was(:,1)/1163,':',cost_tv(:,2), cost_tv(:,1)/1163,'-.');
legend('Refrigerator','Washing machine','TV','Orientation','horizontal','location','North')
% title('Electricity cost and battery capacity: 2 price')
xlabel('Battery capacity [Wh]','FontName','Times','FontSize',fsz);
ylabel('[$/day]','FontName','Times','FontSize',fsz);
ylim([0.033 0.08])
set(gca,'FontName','Times','FontSize',fsz);
saveas(gcf,'fig3.png')

bat_ref_pick=bat_ref(:,10);
bat_was_pick=bat_was(:,10);
bat_tv_pick=bat_tv(:,10);

figure(4);
bat_ref_pick(25)=bat_ref_pick(1);bat_was_pick(25)=bat_was_pick(1);bat_tv_pick(25)=bat_tv_pick(1);
plot(ind_time,bat_ref_pick,ind_time,bat_was_pick,':',ind_time,bat_tv_pick,'-.');
legend('Refrigerator','Washing machine','TV','Orientation','horizontal','location','North')
% title('Battery changes: 2 price, maximum capacity')
xlabel('Time [h]','FontName','Times','FontSize',fsz);
ylabel('[Wh]','FontName','Times','FontSize',fsz);
%ylim([0 800])
xlim([0 25])
set(gca,'FontName','Times','FontSize',fsz);
saveas(gcf,'fig4.png')

% ylabel('Total electricity charged in the battery [Wh]');
%% Dynamic Price
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nn=10;
eff=[0.9,0.97,1];
marg=0.4;

global bat ht zt x_input y_use

p_sampick=smp_pick(year==2019 & month==1,:);
p_pick=(1+marg)*p_sampick;
% 1 col: cost / 2 col: battery status / 3 col: plbar 
% 1 row : refrigerator / 2 row : Washing machine/ 3 row : TV 
% result 1 : 90% efficiency / result2:97%eff/result3: 100% efficiency
[costbat_result1,costbat_result2, costbat_result3]=dynamic_price(eff,nn,p_pick,y_ref,y_was,y_tv,x_crate);

 cost_ref_dyn1=costbat_result1{1,1};
 bat_ref_dyn1=costbat_result1{1,2};
 cost_was_dyn1=costbat_result1{2,1};
 bat_was_dyn1=costbat_result1{2,2};
 cost_tv_dyn1=costbat_result1{3,1};
 bat_tv_dyn1=costbat_result1{3,2}; 

 
 cost_ref_dyn2=costbat_result2{1,1};
 bat_ref_dyn2=costbat_result2{1,2};
 cost_was_dyn2=costbat_result2{2,1};
 bat_was_dyn2=costbat_result2{2,2};
 cost_tv_dyn2=costbat_result2{3,1};
 bat_tv_dyn2=costbat_result2{3,2}; 
 
 
 
 cost_ref_dyn3=costbat_result3{1,1};
 bat_ref_dyn3=costbat_result3{1,2};
 cost_was_dyn3=costbat_result3{2,1};
 bat_was_dyn3=costbat_result3{2,2};
 cost_tv_dyn3=costbat_result3{3,1};
 bat_tv_dyn3=costbat_result3{3,2}; 
 
%%
figure(5);
plot(cost_ref_dyn3(:,2), cost_ref_dyn3(:,1)/1163,cost_was_dyn3(:,2), cost_was_dyn3(:,1)/1163,':',cost_tv_dyn3(:,2), cost_tv_dyn3(:,1)/1163,'-.');
legend('Refrigerator','Washing machine','TV')
xlabel('Battery capacity [Wh]','FontName','Times','FontSize',fsz);
ylabel('[$/day]','FontName','Times','FontSize',fsz);
set(gca,'FontName','Times','FontSize',fsz);
saveas(gcf,'fig5.png')

figure(6);
plot(cost_ref_dyn1(:,2), cost_ref_dyn1(:,1)/1163,cost_was_dyn1(:,2), cost_was_dyn1(:,1)/1163,':',cost_tv_dyn1(:,2), cost_tv_dyn1(:,1)/1163,'-.');
legend('Refrigerator','Washing machine','TV')
ylim([0.033,0.15])
xlabel('Battery capacity [Wh]','FontName','Times','FontSize',fsz);
ylabel('[$/day]','FontName','Times','FontSize',fsz);
set(gca,'FontName','Times','FontSize',fsz);
saveas(gcf,'fig6.png')

ind_time=ind_time(1:24);
figure(7);
plot(ind_time,bat_ref_dyn3(10,:),ind_time,bat_was_dyn3(10,:),':',ind_time,bat_tv_dyn3(10,:),'-.');
legend({'Refrigerator','Washing machine','TV'},'Orientation','horizontal','Location','southwest')
% title('Battery changes: 2 price, maximum capacity')
xlabel('Time [h]','FontName','Times','FontSize',fsz);
ylabel('[Wh]','FontName','Times','FontSize',fsz);
ylim([0 800])
xlim([0 25])
set(gca,'FontName','Times','FontSize',fsz);
saveas(gcf,'fig7.png')


figure(8);
plot(ind_time,bat_ref_dyn1(1,:),ind_time,bat_was_dyn1(1,:),':',ind_time,bat_tv_dyn1(1,:),'-.');
legend({'Refrigerator','Washing machine','TV'},'Orientation','horizontal','location','South')
% title('Battery changes: 2 price, maximum capacity')
xlabel('Time [h]','FontName','Times','FontSize',fsz);
ylabel('[Wh]','FontName','Times','FontSize',fsz);
ylim([0 800])
xlim([0 25])
set(gca,'FontName','Times','FontSize',fsz);
saveas(gcf,'fig8.png')


%% New optimization / price threshold finding 
% Comparison between old dynamic price /this method 

p_sampick=smp_pick(year==2019 & month==1,:);

p_pick=(1+marg)*p_sampick;
eff=[0.9,0.97,1];



Y = [y_ref(1:24,1),y_was(1:24,1),y_tv(1:24,1)];

lbar_result=select_price_mat(Y,nn,eff,p_pick,x_crate);
% row is efficiency / column is appliance 
lbar_new = [lbar_result{1,1}(:,1),lbar_result{1,2}(:,1),lbar_result{1,3}(:,1),lbar_result{2,1}(:,1),lbar_result{2,2}(:,1),lbar_result{2,3}(:,1),lbar_result{3,1}(:,1),lbar_result{3,2}(:,1),lbar_result{3,3}(:,1)];
lbar_new=lbar_new/1163;

% Comparison with the original simulation
lbar_orig = [costbat_result1{1,3},costbat_result1{2,3},costbat_result1{3,3},costbat_result2{1,3},costbat_result2{2,3},costbat_result2{3,3},costbat_result3{1,3},costbat_result3{2,3},costbat_result3{3,3}];
lbar_orig = lbar_orig/1163;


%% Using Data



% refrigerator
pd = makedist('Normal','mu',80,'sigma',4);
y_ref = random(pd,24,1);
% Washing Machine
y_was = zeros(24,1);
y_was(20)=250;
% TV
pd1 = makedist('Normal','mu',100,'sigma',10);
y_tv=zeros(24,1);
watch = random(pd1,5,1);
y_tv(7:8)= watch(1:2,1);
y_tv(19:21)=watch(3:5,1);


nn=10;
eff=[0.9,0.97,1];
marg=0.4;
p_sampick=smp_pick(year==2019 & month==1,:);
p_pick=(1+marg)*p_sampick;
% 1 col: cost / 2 col: battery status / 3 col: plbar 
% 1 row : refrigerator / 2 row : Washing machine/ 3 row : TV 
% result 1 : 90% efficiency / result2:97%eff/result3: 100% efficiency
[costbat_result1,costbat_result2, costbat_result3]=dynamic_price(eff,nn,p_pick,y_ref,y_was,y_tv,x_crate);

 cost_ref_dyn1=costbat_result1{1,1};
 cost_was_dyn1=costbat_result1{2,1};
 cost_tv_dyn1=costbat_result1{3,1};
 
 % only compare the 90% efficiency case  
 % yearly benefit 
 cost_ref_dyn1 =[ cost_ref_dyn1,(cost_ref_dyn1(1,1)-cost_ref_dyn1(:,1))*365]; 
 cost_was_dyn1 =[ cost_was_dyn1,(cost_was_dyn1(1,1)-cost_was_dyn1(:,1))*365]; 
 cost_tv_dyn1 =[ cost_tv_dyn1,(cost_tv_dyn1(1,1)-cost_tv_dyn1(:,1))*365]; 
 
 

figure(9);
plot(cost_ref_dyn1(:,2),cost_ref_dyn1(:,3)/1163,cost_ref_dyn1(:,2),cost_ref_dyn1(:,4)/1163,':')
legend({'cost','benefit(yearly)'},'Orientation','horizontal','location','North')
% title('Battery changes: 2 price, maximum capacity')
xlabel('Battery Capacity[Wh]','FontName','Times','FontSize',fsz);
ylabel('Cost[$]','FontName','Times','FontSize',fsz);
set(gca,'FontName','Times','FontSize',fsz);
saveas(gcf,'fig9.png')


figure(10);
plot(cost_was_dyn1(:,2),cost_was_dyn1(:,3)/1163,cost_was_dyn1(:,2),cost_was_dyn1(:,4)/1163,':')
legend({'cost','benefit(yearly)'},'Orientation','horizontal','location','North')
% title('Battery changes: 2 price, maximum capacity')
xlabel('Battery Capacity[Wh]','FontName','Times','FontSize',fsz);
ylabel('Cost[$]','FontName','Times','FontSize',fsz);
set(gca,'FontName','Times','FontSize',fsz);
saveas(gcf,'fig10.png')


figure(11);
plot(cost_tv_dyn1(:,2),cost_tv_dyn1(:,3)/1163,cost_tv_dyn1(:,2),cost_tv_dyn1(:,4)/1163,':')
legend({'cost','benefit(yearly)'},'Orientation','horizontal','location','North')
% title('Battery changes: 2 price, maximum capacity')
xlabel('Battery Capacity[Wh]','FontName','Times','FontSize',fsz);
ylabel('Cost[$]','FontName','Times','FontSize',fsz);
set(gca,'FontName','Times','FontSize',fsz);
saveas(gcf,'fig11.png')

 