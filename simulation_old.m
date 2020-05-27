clear all;
clc;

load elect_price.mat
% price data 
% column1 : household / c2 : general/ c3 :educational/c4: industrial /c5:
% agriculture / c6: street light/ c7: night / c8: all 
% 밤 11시~아침 9시
% 원/kWh 


max_night= max(price(:,7));
pbar= max_night+1;

% With dynamic price
smp=xlsread('SMP.csv');
smp_pick= smp(:,1:24);
pr=smp_pick(1:734,:);
pr=flipud(pr);
td= size(pr,1);
%%
% price graph

pr_elect=zeros(24,1);
pr_elect(1:8,:)=pbar;
pr_elect(23:24,:)=pbar;
pr_elect(9:22,:)=mean(price(:,1));
pr_dynamic=mean(pr,1)';
ind_time=1:24;

figure(1)
plot(ind_time,pr_elect,ind_time,pr_dynamic);
ylim([0,140]);
xlim([0,24]);
title('Electricity price')
xlabel('Time');
ylabel('Price');


%% refrigerator
pd = makedist('Normal','mu',33.3,'sigma',4);
y_ref = random(pd,24,1);
%% Washing Machine
y_was = zeros(24,1);
y_was(20)=600;
%% TV
pd1 = makedist('Normal','mu',70,'sigma',10);
y_tv=zeros(24,1);
watch = random(pd1,8,1);
y_tv(7:8)= watch(1:2,1);
y_tv(19:24)=watch(3:8,1);
% usage distribution in graph

figure(2)
plot(ind_time,y_ref,ind_time,y_was,'-o',ind_time,y_tv,'--');
ylim([0,700]);
xlim([0,24]);
legend('Refrigerator','Washing machine','TV')
title('Electricity usage profile')
xlabel('Time');
ylabel('Price');
%%
% battery efficiency is determined by del1, del2 
% in this case, it's 90% efficient
del2= 0;
del1 = 0;
x_crate= 0.3;

% the vectors to store the results 
cost_cal=zeros(6,1);
elec_cal=zeros(6,1);

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
K_grid=linspace(0,max_bat,6);
x_input=zeros(24,1);
for j=1:6
    K= K_grid(j);
    x=x_crate*K;
    
bat = zeros(24,1);
zt = zeros(24,1);
ht= zeros(24,1);
for i=1:24
    % off peak
    if (i>=1 & i< 9)||(i>= 23) 
        if (bat(i) >= 0 & bat(i) <K)
            ht(i)=1;
            zt(i)=1;
            if bat(i)+x < K
                x_input(i)=x;
            else
                x_input(i)=K-bat(i);
            end
        elseif  (bat(i)<0)
            bat(i)=0;
            ht(i)=1;
            zt(i)=1;
            x_input(i)=x;
        else
            ht(i)=0;
            zt(i)=1;
        end
    else
        % peak hours
        if (bat(i) > 0 & bat(i) <=K)
            ht(i) =-1;
            zt(i)=0;
        
        elseif (bat(i)<=0)
            ht(i)=0;
            zt(i)=1;
            bat(i)=0;
        else
            bat(i)=K;
            ht(i)=-1;
            zt(i)=0;
        end
    end
    if i<=23
    bat(i+1) = bat(i)+(ht(i)==1)*x_input(i)-(ht(i)==-1)*y(i)*(1+del2);
        if bat(i+1) >= K 
            bat(i+1)=K;
        end
    else 
    bat(i)=bat(i);
    end
    

end

% electricity cost calculation
before_cost=sum(pr_elect/1000.*y);
if K==0;
    after_cost=before_cost;
    total_elect=sum(y);
else
    after_cost=sum((zt==1).*(y.*pr_elect/1000)+(1+del1).*(x_input.*pr_elect/1000));
    total_elect=sum((zt==1).*y+(1+del1)*x_input);
end
cost_cal(j)=after_cost;
elec_cal(j)=total_elect;
    end

%%
% refrigerator
pd = makedist('Normal','mu',33.3,'sigma',4);
y = random(pd,24,1);
%% Washing Machine
y = zeros(24,1);
y(20)=600;
%% TV
pd = makedist('Normal','mu',70,'sigma',10);
y = random(pd,24,1);

%%
K_grid=100:100:600;
cost_cal=zeros(6,2);
for j=1:6
K= K_grid(j);
before_cost=sum(pr*y/1000)/td;
cost_opt=@(plbar)price_opt(plbar,K,pr,del2,x,y);
options = optimset('Display','iter','MaxIter',99999999999999999);
x0=mean(mean(pr));
lb=min(min(pr));
ub=max(max(pr));
[x_param2,ff]=simulannealbnd(cost_opt,x0,lb,ub,options);
cost_cal(j,1)=x_param2;
cost_cal(j,2)=ff/td;
end
