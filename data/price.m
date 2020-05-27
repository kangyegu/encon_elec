clear all;
clc;
load data_smp.mat;

%% 
% col1 : hour// col2 : SMP // col3: month // col4: year // col5: ampm - 1:
% am/ 2 - pm 

august = price(price(:,3)==8,[1,2,5]);
nov = price(price(:,3)==11,[1,2,5]);
jan = price(price(:,3)==1,[1,2,5]);
april = price(price(:,3)==4,[1,2,5]);


figure(1);
plot(august(august(:,3)==1,1),august(august(:,3)==1,2),'--',jan(jan(:,3)==1,1),jan(jan(:,3)==1,2))
legend('August','January');
xlim([1,12])
ylabel('$/Mwh');
xlabel('hour');
title('System Energy Price : Newark case(AM)');


figure(2);
plot(august(august(:,3)==2,1),august(august(:,3)==2,2),'--',jan(jan(:,3)==2,1),jan(jan(:,3)==2,2))
legend('August','January');
xlim([1,12])
ylabel('$/Mwh');
xlabel('hour');
title('System Energy Price : Newark case(PM)');


figure(3);
plot(april(april(:,3)==1,1),april(april(:,3)==1,2),'--',nov(nov(:,3)==1,1),nov(nov(:,3)==1,2))
legend('April','November');
xlim([1,12])
ylabel('$/Mwh');
xlabel('hour');
title('System Energy Price : Newark case(AM)');


figure(4);
plot(april(april(:,3)==2,1),april(april(:,3)==2,2),'--',nov(nov(:,3)==2,1),nov(nov(:,3)==2,2))
legend('April','November');
xlim([1,12])
ylabel('$/Mwh');
xlabel('hour');
title('System Energy Price : Newark case(PM)');