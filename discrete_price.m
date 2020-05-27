function [cost,bat_cal]=discrete_price(del1,del2,x_crate,nn,y_ref,y_was,y_tv,pr_elect)

elec_cal=1000*ones(nn,1);

% appliance_index: the number represents the appliance
% if 1 : refrigerator, 2: washing machine 3: tv

bat_ref =zeros(24,nn);
bat_tv =zeros(24,nn);
bat_was =zeros(24,nn);
for appliance_index=1:3
    
cost_cal=1000*ones(nn,1);

    if appliance_index==1
        y=y_ref(1:24);
    elseif appliance_index==2
        y=y_was(1:24);
    elseif appliance_index==3
        y=y_tv(1:24);
    end
    max_bat=ceil(sum(y)/10)*10*1.3;
    K_grid=linspace(0,max_bat,nn);
    batterycost=zeros(nn,1);
    x_input=zeros(24,1);
    for j=1:nn
        K= K_grid(j);
        x=x_crate*K;
        loop=1;
        bat_bef=0;
        
        bat = zeros(24,1);
        while loop<=100;
            
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
                            x_input(i)=max(0,K-bat(i));
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
                        if (bat(i)<y(i)*1/(del2))
                            zt(i)=1;
                            y_use(i)=y(i)*1/(del2)-bat(i);
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
        if appliance_index==1
            bat_ref(:,j)=bat;
        end
        if appliance_index==2
            bat_was(:,j)=bat;
        end
        if appliance_index==3
            bat_tv(:,j)=bat;
        end
        
  end      

        if appliance_index==1
            cost_ref=[cost_cal,K_grid',batterycost];
        elseif appliance_index==2
            cost_was=[cost_cal,K_grid',batterycost];
        elseif appliance_index==3
            cost_tv=[cost_cal,K_grid',batterycost];
        end
 
end


cost= cell(3,1);
cost{1,1} = cost_ref;
cost{2,1} = cost_was;
cost{3,1} = cost_tv;

bat_cal= cell(3,1);
bat_cal{1,1} = bat_ref;
bat_cal{2,1} = bat_was;
bat_cal{3,1} = bat_tv;
end


