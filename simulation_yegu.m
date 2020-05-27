clear all; close all;
clc;

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

load elect_price.mat
% price data
% column1 : household / c2 : general/ c3 :educational/c4: industrial /c5:
% agriculture / c6: street light/ c7: night / c8: all


min_cost_ref=10000;min_cost_was=10000;min_cost_tv=10000;
max_night= max(price(:,7));
pbar= max_night+1;

% With dynamic price
smp=xlsread('SMP.csv');
smp_pick= smp(:,1:24);
pr=smp_pick(1:734,:);
pr=flipud(pr);
td= size(pr,1);
%
% price graph

pr_elect=zeros(24,1);
pr_elect(1:8,:)=pbar;
pr_elect(23:24,:)=pbar;
pr_elect(9:22,:)=mean(price(:,1));
pr_dynamic=mean(pr,1)';
ind_time=0:24;
%1163 $/won
figure(1)
pr_elect(end+1)=pr_elect(1);
plot(ind_time,pr_elect/1163);
% plot(ind_time,pr_elect/1163,ind_time,pr_dynamic/1163);
ylim([0,0.15]);
xlim([0,24]);
% title('Electricity price')
xlabel('Time [h]','FontName','Times','FontSize',fsz);
ylabel('Electrical price [$/kWh]','FontName','Times','FontSize',fsz);
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
xlim([0,24]);
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
del2= 0.9;
del1 = 0.9;
x_crate= 0.3;
% grid size
nn=50;
% the vectors to store the results
cost_cal=1000*ones(nn,1);
elec_cal=1000*ones(nn,1);

% appliance_index: the number represents the appliance
% if 1 : refrigerator, 2: washing machine 3: tv

for appliance_index=1:1:3
    if appliance_index==1
        y=y_ref(1:24);
    elseif appliance_index==2
        y=y_was(1:24);
    elseif appliance_index==3
        y=y_tv(1:24);
    end
    max_bat=ceil(sum(y)/10)*10*1.1;
    K_grid=linspace(0,max_bat,nn);
    batterycost=zeros(nn,1);
    
    x_input=zeros(24,1);
    for j=1:nn
        K= K_grid(j);
        x=x_crate*K;
        loop=1;
        bat_bef=0;
        while loop<=100;
            
            bat = zeros(24,1);
            zt = zeros(24,1);
            ht= zeros(24,1);
            y_use=zeros(24,1);
            bat(1)=bat_bef;
            x_input=zeros(24,1);
            for i=1:24
                % off peak
                if (i>=1 & i< 9)||(i>= 23)
                    if (bat(i) >= 0 & bat(i) <K)
                        ht(i)=1;
                        zt(i)=1;
                        y_use(i)=y(i);
                        if bat(i)+x < K
                            x_input(i)=x;
                        else
                            x_input(i)=K-bat(i);
                        end
                    elseif  (bat(i)<0)
                        bat(i)=0;
                        ht(i)=1;
                        zt(i)=1;
                        y_use(i)=y(i);
                        x_input(i)=x;
                    else
                        ht(i)=0;
                        zt(i)=1;
                        y_use(i)=y(i);
                    end
                else
                    % peak hours
                    if (bat(i) > 0 & bat(i) <=K)
                        ht(i) =-1;
                        if (bat(i)<y(i))
                            zt(i)=1;
                            y_use(i)=y(i)-bat(i);
                        else
                            zt(i)=0;
                        end
                        
                    elseif (bat(i)<=0)
                        ht(i)=0;
                        zt(i)=1;
                        y_use(i)=y(i);
                        bat(i)=0;
                    else
                        bat(i)=K;
                        ht(i)=-1;
                        zt(i)=0;
                    end
                end
                if i<=23
                    bat(i+1) = bat(i)+(ht(i)==1)*x_input(i)-(ht(i)==-1)*y(i)*1/(del2);
                    if bat(i+1) >= K
                        bat(i+1)=K;
                    end
                else
                    bat_bef=bat(i)+(ht(i)==1)*x_input(i)-(ht(i)==-1)*y(i)*1/(del2);
                end
            end
            % electricity cost calculation
            before_cost=sum(pr_elect(1:24)/1000.*y);
            if K==0;
                after_cost=before_cost;
                total_elect=sum(y);
            else
                after_cost=sum((zt==1).*(y_use.*pr_elect(1:24)/1000)+(1/(del1))*(x_input.*(pr_elect(1:24)/1000)));
                total_elect=sum((zt==1).*y_use+(1/(del1))*x_input);
            end
            loop=loop+1;
        end
        batterycost(j)=133.6/1000*K;
        cost_cal(j)=after_cost;
        elec_cal(j)=total_elect;
        
        
        if appliance_index==1;
            cost_ref=[cost_cal,K_grid',batterycost];
            if min_cost_ref>min(cost_cal)
                min_cost_ref=min(cost_cal)
                bat_ref=bat;                
            end
        elseif appliance_index==2;
            cost_was=[cost_cal,K_grid',batterycost];
            if min_cost_was>min(cost_cal)
                min_cost_was=min(cost_cal);
                bat_was=bat;
            end
        elseif appliance_index==3;
            cost_tv=[cost_cal,K_grid',batterycost];
            if min_cost_tv>min(cost_cal)
                min_cost_tv=min(cost_cal);
                bat_tv=bat;
            end
        end
    end
end

%
% plotting the electricity cost
figure(3);
% plot(cost_ref(:,2), cost_ref(:,1),cost_was(:,2), cost_was(:,1),':',cost_tv(:,2), cost_tv(:,1),'-.');

plot(cost_ref(:,2), cost_ref(:,1)/1163,cost_was(:,2), cost_was(:,1)/1163,':',cost_tv(:,2), cost_tv(:,1)/1163,'-.');
legend('Refrigerator','Washing machine','TV','Orientation','horizontal','location','North')
% title('Electricity cost and battery capacity: 2 price')
xlabel('Battery capacity [Wh]','FontName','Times','FontSize',fsz);
ylabel('Electricity cost [$]','FontName','Times','FontSize',fsz);
ylim([0.035 0.08])
set(gca,'FontName','Times','FontSize',fsz);
saveas(gcf,'fig3.png')
figure(4);
bat_ref(end+1)=bat_ref(1);bat_was(end+1)=bat_was(1);bat_tv(end+1)=bat_tv(1);
plot(ind_time,bat_ref,ind_time,bat_was,':',ind_time,bat_tv,'-.');
legend('Refrigerator','Washing machine','TV','Orientation','horizontal','location','North')
% title('Battery changes: 2 price, maximum capacity')
xlabel('Time [h]','FontName','Times','FontSize',fsz);
ylabel('[Wh]','FontName','Times','FontSize',fsz);
ylim([0 800])
set(gca,'FontName','Times','FontSize',fsz);
saveas(gcf,'fig4.png')

% ylabel('Total electricity charged in the battery [Wh]');
%% Dynamic Price
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nn=10;
% the vectors to store the results
cost_cal=zeros(nn,1);
elec_cal=zeros(nn,1);
% update length
m=15;

pr=smp_pick(1:m,:);
pr=flipud(pr);
td= size(pr,1);
% appliance_index: the number represents the appliance
% if 1 : refrigerator, 2: washing machine 3: tv

appliance_index='1';

switch(appliance_index)
    case '1'
        y=y_ref;
    case '2'
        y=y_was;
    case '3'
        y=y_tv;
end
max_bat=ceil(sum(y)/10)*10;
K_grid=linspace(0,max_bat,nn);
batterycost=zeros(nn,1);
global bat

for j=1:nn
    K= K_grid(j);
    bat=zeros(24,1);
    before_cost=sum(pr*y/1000)/td;
    x=x_crate*K;
    cost_opt=@(plbar)price_opt(plbar,K,pr,del1,del2,x,y);
    options = optimset('Display','iter','MaxIter',99999999999999999);
    x0=mean(mean(pr));
    lb=min(min(pr));
    ub=max(max(pr));
    [x_param2,ff]=simulannealbnd(cost_opt,x0,lb,ub,options);
    cost_cal(j,1)=x_param2;
    cost_cal(j,2)=price_opt(x_param2,K,pr,del1,del2,x,y);
    if j==1
        cost_cal(j,2)=before_cost;
    end
    
    batterycost(j)=133.6/1000*K;
end


if appliance_index=='1';
    cost_ref_dyn=[cost_cal,K_grid',batterycost];
    bat_ref_dyn=bat;
elseif appliance_index=='2';
    cost_was_dyn=[cost_cal,K_grid',batterycost];
    bat_was_dyn=bat;
else
    cost_tv_dyn=[cost_cal,K_grid',batterycost];
    bat_tv_dyn=bat;
end



figure(5);
plot(cost_ref_dyn(:,3), cost_ref_dyn(:,2),'--',cost_was_dyn(:,3), cost_was_dyn(:,2),'-o',cost_tv_dyn(:,3), cost_tv_dyn(:,2));
legend('Refrigerator','Washing machine','TV')
title('Electricity cost and battery capacity: dynamic price')
xlabel('Battery capacity(Wh)');
ylabel('Electricity cost(Daily mean/won)');

figure(6);
plot(ind_time,bat_ref_dyn,'o',ind_time,bat_was_dyn,'--',ind_time,bat_tv_dyn,'-o');
legend('Refrigerator','Washing machine','TV')
title('Battery changes: dynamic price, maximum capacity')
xlabel('Time');
ylabel('Total electricity charged in the battery');