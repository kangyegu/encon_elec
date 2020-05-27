function total_cost=select_price(plbar,y,x,K,pmat,del2)


p_peak=pmat>plbar;
A=y'.*p_peak;
B =y'.*(~p_peak);
charg=min(K,sum(x*(~p_peak),2));
pu_pick=pmat.*p_peak;
pl_pick=pmat.*~p_peak;
pu =zeros(size(pmat,1),1);
pl =zeros(size(pmat,1),1);

for i=1:size(pmat,1)
pu(i,1)=mean(pu_pick(i,pu_pick(i,:)>0));
pl(i,1)=mean(pl_pick(i,pl_pick(i,:)>0));
end


pu(isnan(pu)) = 0;
pl(isnan(pl)) = 0;

peak_left=max(0,(sum(A,2)-charg))/1000;

peak_sum=sum(peak_left.*pu)/size(pmat,1);
offpeak_sum=sum(sum(B,2)/1000.*pl)/size(pmat,1);
battery_sum = sum((charg./del2).*pl/1000)/size(pmat,1);

total_cost=peak_sum+offpeak_sum+battery_sum;
