function cost=battery_cost(y_ref,y_was,y_tv,nn)

cost=zeros(nn,3);

    for kk=1:3
        
        if kk==1
            y=y_ref(1:24,1);
        elseif   kk==2
            y=y_was(1:24,1);
        else
            y=y_tv(1:24,1);
        end
        
        
        max_bat=ceil(sum(y)/10)*10;
        K_grid=linspace(0,max_bat,nn);
        batterycost=133.6/1000*K_grid;
        cost(:,kk)=batterycost;
    end
end

        
        