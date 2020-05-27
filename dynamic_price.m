function [costbat_result1,costbat_result2, costbat_result3]=dynamic_price(eff,nn,p_sampick,y_ref,y_was,y_tv,x_crate)

global bat ht zt x_input y_use

% efficiency makes difference
%

for eff_ind=1:3
    del2= eff(eff_ind);
    del1 = eff(eff_ind);
    
    % the vectors to store the results
    cost_cal=zeros(nn,3);
    elec_cal=zeros(nn,1);
    % update length
    % appliance_index: the number represents the appliance
    % if 1 : refrigerator, 2: washing machine 3: tv
    
    nsample=size(p_sampick,1);
    wall_input=cell(nn,3);
    
    for kk=1:3
        appliance_index=kk;
        
        bat_store=zeros(24,nsample);
        for nnn=1:nn
            wall_input{nnn,kk}=zeros(24,nsample);
        end
        fprintf('Appliance now: %d\n', kk)
        
        if appliance_index==1
            y=y_ref(1:24,1);
        elseif   appliance_index==2
            y=y_was(1:24,1);
        else
            y=y_tv(1:24,1);
        end
        
        
        plbar_mat=zeros(nn,1);
        max_bat=ceil(sum(y)/10)*10;
        K_grid=linspace(0,max_bat,nn);
        batterycost=zeros(nn,1);
        
        for j=1:nn
            K= K_grid(j);
            bat=zeros(24,1);
            before_cost=sum(p_sampick*y/1000)/nsample;
            x=x_crate*K;
            y_usesto=zeros(24,nsample);
            total_cost=0;
            cost_opt=@(plbar)price_opt(plbar,K,p_sampick,del1,del2,x,y);
            options = optimset('Display','off','MaxIter',99999999999999999);
            x0=mean(mean(p_sampick));
            lb= min(min(p_sampick,[],2));
            ub= max(max(p_sampick,[],2));
            [x_param2,ff]=fminbnd(cost_opt,lb,ub,options);
            total_cost=ff;
            bat_store=bat;
            y_usesto=y_use';
            wall_input{j,kk}=y_usesto;            
            cost_cal(j,kk)=total_cost;
            fprintf('Capacity in the loop: %d\n', K);
            batterycost(j)=133.6/1000*K;
            plbar_mat(j,1)=x_param2;
        end
        
        
        if appliance_index==1;
            cost_ref_dyn=[cost_cal(:,1),K_grid',batterycost];
            bat_ref_dyn=bat_store;
            plbar_ref_dyn=plbar_mat;
            
        elseif appliance_index==2;
            cost_was_dyn=[cost_cal(:,2),K_grid',batterycost];
            bat_was_dyn=bat_store;
            plbar_was_dyn=plbar_mat;

        else
            cost_tv_dyn=[cost_cal(:,3),K_grid',batterycost];
            bat_tv_dyn=bat_store;
            plbar_tv_dyn=plbar_mat;

        end
        
        
    end
    
    if eff_ind==1;
        cost_ref_dyn1=cost_ref_dyn;
        bat_ref_dyn1= bat_ref_dyn;
        plbar_ref_dyn1=plbar_ref_dyn;
        cost_was_dyn1=cost_was_dyn;
        bat_was_dyn1= bat_was_dyn;
        plbar_was_dyn1=plbar_was_dyn;
        cost_tv_dyn1=cost_tv_dyn;
        bat_tv_dyn1= bat_tv_dyn;
        plbar_tv_dyn1=plbar_tv_dyn;

    elseif eff_ind==2
        cost_ref_dyn2=cost_ref_dyn;
        bat_ref_dyn2= bat_ref_dyn;
        plbar_ref_dyn2=plbar_ref_dyn;
        cost_was_dyn2=cost_was_dyn;
        bat_was_dyn2= bat_was_dyn;
        plbar_was_dyn2=plbar_was_dyn;
        cost_tv_dyn2=cost_tv_dyn;
        bat_tv_dyn2= bat_tv_dyn;
        plbar_tv_dyn2=plbar_tv_dyn;
    else
        
        cost_ref_dyn3=cost_ref_dyn;
        bat_ref_dyn3= bat_ref_dyn;
        plbar_ref_dyn3=plbar_ref_dyn;
        cost_was_dyn3=cost_was_dyn;
        bat_was_dyn3= bat_was_dyn;
        plbar_was_dyn3=plbar_was_dyn;
        cost_tv_dyn3=cost_tv_dyn;
        bat_tv_dyn3= bat_tv_dyn;
        plbar_tv_dyn3=plbar_tv_dyn;
    end
    
    
end


    
 costbat_result1=cell(3,3);
 costbat_result1{1,1} =cost_ref_dyn1;
 costbat_result1{1,2} =bat_ref_dyn1;
 costbat_result1{1,3} =plbar_ref_dyn1;

 costbat_result1{2,1} =cost_was_dyn1;
 costbat_result1{2,2} =bat_was_dyn1;
 costbat_result1{2,3} =plbar_was_dyn1;
 
 
 costbat_result1{3,1} =cost_tv_dyn1;
 costbat_result1{3,2} =bat_tv_dyn1;
 costbat_result1{3,3} =plbar_tv_dyn1;

 costbat_result2=cell(3,2);
 costbat_result2{1,1} =cost_ref_dyn2;
 costbat_result2{1,2} =bat_ref_dyn2;
 costbat_result2{1,3} =plbar_ref_dyn2;

 costbat_result2{2,1} =cost_was_dyn2;
 costbat_result2{2,2} =bat_was_dyn2;
 costbat_result2{2,3} =plbar_was_dyn2;
 
 costbat_result2{3,1} =cost_tv_dyn2;
 costbat_result2{3,2} =bat_tv_dyn2;
 costbat_result2{3,3} =plbar_tv_dyn2;
 
 
 costbat_result3=cell(3,2);
 costbat_result3{1,1} =cost_ref_dyn3;
 costbat_result3{1,2} =bat_ref_dyn3;
 costbat_result3{1,3} =plbar_ref_dyn3;
 
 costbat_result3{2,1} =cost_was_dyn3;
 costbat_result3{2,2} =bat_was_dyn3;
 costbat_result3{2,3} =plbar_was_dyn3;
 
 
 costbat_result3{3,1} =cost_tv_dyn3;
 costbat_result3{3,2} =bat_tv_dyn3;
 costbat_result3{3,3} =plbar_tv_dyn3;
     
end
