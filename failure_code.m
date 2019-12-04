Data = csvReadFromKaggle('Mobserved50by200');
[row,col] = size(Data);
%Y(a,b) movie a by viewer b, (bx*ax)+(by*ay)= Y(a,b) unknown:av,bx,ay,by
X=zeros(row,1); % Viewer's avg score
for i = 1:1:row
    count = 0;
    total = 0;
    for j=1:1:col
        if(0==isnan(Data(i,j)))
            count = count+1;
            total = total + Data(i,j);
        end 
    end
    X(i)=total/count;
end

Y=zeros(col,1);% movie's 'true' score
for i = 1:1:col
    count = 0;
    total = 0;
    for j=1:1:row
        if(0==isnan(Data(j,i)))
            count = count+1;
            total = total + Data(j,i);
        end 
    end
    Y(i)=total/count;
end

P=[];
% find all NaN entries, and store their coordinates into P


for i=1:1:row
    for j=1:1:col
        if(isnan(Data(i,j)))
            P=[P;[i,j]];
        end
    end
end
%!!!! AVERAGE viewer scoring:
avg_viewer = 0;
count_effective_viewer=0;
for i = 1:1:row
    if(X(i)~=0)
        count_effective_viewer=count_effective_viewer+1;
        avg_viewer=avg_viewer + X(i);
    end
end
avg_viewer=avg_viewer/count_effective_viewer;

n=size(P);  % number of missing entries
Data2=Data; %% based on avg movie scores
for i=1:1:n(1)
    k = P(i,1);  %viewer k = P(i,1), movie P(i,2)
%     XX=[]; %perceived as X coordinates
%     YY=[]; %Y coordinates
%     for  j =1:1:col% check the scores k gives to other movies
%         if(0==isnan(Data(k,j)))
%             XX=[XX;Y(j)]; % avg score
%             YY=[YY;Data(k,j)]; % the score this viewer gives
%         end
%     end
%    fitcknn(YY,XX,'NumNeighbors',5,'Standardize',0.1)
    sum=0;
%     for  i=1:1:row % find similar viewers, what can be similar?
%         
        
   N = zeros(row,2);
   N(k)=inf;
       % w*(Data(i,P(i,2))-X(i))
     for m=1:1:row % kth viewer is the current viewer  % iterating all viewers
         N(m,1)=m;
         count_neighbour=0;
         sum_neighbour=0;
         for l=1:1:col
             if (k~=m && 0==isnan(Data(k,l)) && 0==isnan(Data(m,l))) % both k and m watched movie l
                 count_neighbour = count_neighbour + 1;
                 sum_neighbour = sum_neighbour + Data(m,l)-Data(k,l);
             end
         end
         N(m,2)=sum_neighbour/count_neighbour;
     end
      N = sortrows(N,2); % people who are close to the current viewer
      
      Num_closest = 10;
      sum_closest =0;
      NN=zeros(row); % will be a set exclude who didn't watch current movie P(i,2)
      index_NN=1;
      for j=1:1:row
          NN(j) = Y(P(i,2));
      end
      
      %% find avg_viewer 
     for j=1:1:row 
         %N(j,1):the viewer
         if (k~=N(j,1) && 0==isnan(Data(N(j,1),P(i,2)))) % N(j,1) saw this movie i.e., jth best neighbour watched this movie
             NN(index_NN) = N(j,2); % add this score  to NN
             index_NN = index_NN+1;
         end
     end
%      if (size(NN,1)<Num_closest)
%          NN = [NN;Y(P(i,2));Y(P(i,2));Y(P(i,2));Y(P(i,2));Y(P(i,2))]; % to be safe
%      end
     
     % Now NN has all the scores, in ordering, that other best neighbours
     % give to the current movie
     for j=1:1:Num_closest
         sum_closest = sum_closest + NN(j);
     end
     sum_closest = sum_closest / Num_closest; % prediction
     
     
     Data2(P(i,1),P(i,2)) =sum_closest;
         
     
    
     %Data2(P(i,1),P(i,2)) = Y(P(i,2)) + (X(P(i,1))-avg_viewer); %
     
     
%      z= interp1(XX,YY,Y(P(i,2)));
%      if(isnan(z))% interp. fail
%          z=Y(P(i,2)) + (X(P(i,1))-avg_viewer); %%-- interpolation+ mean:1.28988
%      end
%      
%     Data2(P(i,1),P(i,2)) = z;% interpolation+ fill zero: 1.28
    
end
 
    
    % Data2(P(i,1),P(i,2)) = Y(P(i,2)) + (X(P(i,1))-avg_viewer); 
    % 1.07 -- score   
     
    %%%%%%%%%%%%%%%%%%%%%%%% avg movie-score + this_viewer's preference
csvWriteForKaggle('trash trial', Data2)


          
    
            
        