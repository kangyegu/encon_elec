function lbar_result=select_price_mat(Y,nn,eff,p_sampick,x_crate)

lb= min(min(p_sampick,[],2));
ub= max(max(p_sampick,[],2));
lbar_result=cell(size(eff,2),3);

for kk=1:size(eff,2)
del2 = eff(kk);

for jj=1:3
    y = Y(:,jj);
    max_bat=ceil(sum(y)/10)*10;
    K_grid=linspace(0,max_bat,nn);
    lbar_find =zeros(nn,2);
    for i=1:nn

    K= K_grid(i);

    x=x_crate*K;
    cost_opt=@(plbar)select_price(plbar,y,x,K,p_sampick,del2);
    options = optimset('Display','off','MaxIter',99999999999999999);
    [x_param2,ff]=fminbnd(cost_opt,lb,ub,options);

    lbar_find(i,1)=x_param2;
    lbar_find(i,2)=ff;
    end
    
lbar_result{kk,jj} = lbar_find;
end
end




end


    



