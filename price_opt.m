function cost_return=price_opt(plbar,K,pr,del1,del2,x,y)
global bat next_b1 ht zt x_input y_use

ht=zeros(size(pr,1),24);
zt = zeros(size(pr,1),24);
x_input=zeros(size(pr,1),24);
y_use=zeros(size(pr,1),24);
bat=zeros(size(pr,1),24);

td=size(pr,1);
    
for kk=1:size(pr,1)
    
    
for i=1:24
    % off peak
    if (pr(kk,i)<= plbar) 
        if (bat(kk,i) >= 0 & bat(kk,i) <K)
            ht(kk,i)=1;
            zt(kk,i)=1;
            if bat(kk,i)+x < K
                x_input(kk,i)=x;
            else
                x_input(kk,i)=max(0,K-bat(kk,i));
            end
            y_use(kk,i)=y(i);
        elseif  (bat(kk,i)<0)
            bat(kk,i)=0;
            ht(kk,i)=1;
            zt(kk,i)=1;
            if bat(kk,i)+x< K
            x_input(kk,i)=x;
            else
            x_input(kk,i)=max(K-bat(kk,i),0);
            end
            y_use(kk,i)=y(i);
        else
            ht(kk,i)=0;
            zt(kk,i)=1;
            y_use(kk,i)=y(i);
        end
        
    else
        % peak hours
        if (bat(kk,i) > 0 & bat(kk,i) <=K)
            ht(kk,i) =-1;
            if (bat(kk,i)<y(i)*1/del2)
                zt(kk,i)=1;            
                y_use(kk,i)=y(i)*1/del2-bat(kk,i);
            else
                zt(kk,i)=0;
            end
        elseif (bat(kk,i)<=0)
            ht(kk,i)=0;
            zt(kk,i)=1;
            bat(kk,i)=0;
            y_use(kk,i)=y(i);
        else 
            bat(kk,i)=K;
            ht(kk,i)=-1;
            zt(kk,i)=0;
        end
    end
    
if (i ~= 24)
bat(kk,i+1) = bat(kk,i)+(ht(kk,i)==1)*x_input(kk,i)-(ht(kk,i)==-1)*y(i)*1/del2;
    if bat(kk,i+1) >= K 
        bat(kk,i+1)=K;
    end
    if bat(kk,i+1) <= 0; 
        bat(kk,i+1)=0;
    end
    
    
else
next_b1=bat(kk,i)+(ht(kk,i)==1)*x_input(kk,i)-(ht(kk,i)==-1)*y(i)*1/del2;

    if next_b1>=K
        next_b1=K;
    end
    
    if next_b1 <=0
        next_b1 =0;
    end
    
end


end




bat(kk+1,1) = next_b1;

end

% electricity cost calculation
A= pr/1000.*x_input*1/del1;
sum_A = sum(A,2);
after_cost=(sum(sum((((zt==1).*pr/1000).*y_use),2)+sum_A))/td;
cost_return=after_cost;
end


