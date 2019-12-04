% Eric Xie  50209162, Zitong Wang 40883150
% Something to say about this project... It is all about what we
% encountered, and how we found the method. 
% You can just ignore this section, if you only want the codes...

% I just assume everyone knows that this matrix can be seen as:
% viewers(Rows) scoring different movies(Cols) instance. 

% So at the very beginning,
% my intuitive strategy was that a viewer may score movies similarly;
% like a viewer who always give 'higher scores' (higher than the avg score of that movie) would likely to 
% give a higher score to the other movies( missing entries)
% Thus the way I did to approximate the missing score for a movie (name it 'current movie')was that I first
% iterate all the viewers, and for each viewer(name it the 'current viewer'), I iterate all the viewers
% again and rank their similarity to the current viewer, creating a sort of "priority list". 
% Then, with priority list, I filter our the viewers who didn't watch the
% movie of which I want to approximate the score. (i.e., Suppose I want to approximate how would Jim score Harry Porter, I filter out the people who didn't watch Harry Porter)
% For the remaining priority list, I pick like the 10 most similar viewers,
% and see what scores they give to the current movie.
% Without writing a weighting function that weights the significance of
% each of the 10 most similar viewers' scores, I just tried to run it and
% wanted to see the result first..but ...but it turns out that the result
% wasn't so good... I believe that after finishing the weighting function,
% the results could be improved, but I strongly felt that I wasn't in
% the most corect path.
% So...................................I started searching for another
% method, and SVD  decomposition was what I found promising. However,  I
% have to say, from here, it is definitely not started from scratch.
% Becasue it is a low rank matrix, when doing SVD decomposition, some
% singular values should actually be zero. By eliminating those disturbing
% singular values, the eventually leftover diagonal matrix can help recover
% to the original matrix. Basically that's the thing the codes does...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


Data = csvReadFromKaggle('Mobserved50by200');

Result = complete_data(Data);
csvWriteForKaggle('trash trial', Result); % yeah... that's how we name it..





function A = complete_data(M)

    A = M;
    [m,n] = size(A);
    %For M_shadow, initially, set all entries to 1.
    %if an entry is missing, set it to 0. So that M can indicate the
    %coordinates of all known/missing data.
    M_shadow = ones(m,n); % lcoating all the missing data
    for i = 1:m
        for j = 1:n
            if(isnan(M(i,j)))
                M_shadow(i,j) = 0;
                A(i,j) = 0;
            end
        end
    end
    
    %% Similar to gradient descent
    %the reason why 1:15 is because the calculation accuracy in the matlab
    %is decimal point 15...As I am informed..but probably even a few steps
    %would be good enough since the original input data aren't 15 digit
    %precise..
    for step_size = 1:1:1
        A = completeHelperRough(A, M_shadow, step_size);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function A = completeHelperRough(M, M_shadow, step_size)
    % make a copy of the original matrix
    A = M;
    % save the prev
    prev_result = A; 
    % m = row, n = col
    [m,n] = size(A);

    % initialize with a huge nuclear norm
    nuclear_norm = 1e100; 
    [U,S,V] = svd(A);
    S1 = S
    

    while sum(diag(S))< nuclear_norm
        nuclear_norm = sum(diag(S)); %update nuclear norm
        prev_result = A; % save A before changing A
        
       %% shink singular value, for those too small singular values, shrink them to zero
        min_sigma = 0;
        i = min(size(S));
        while i > 0
            S(i,i) = round(S(i,i), step_size);
            if(S(i,i)>0)
                min_sigma = S(i,i);
                break;
            else
                S(i,i) = 0; 
            end
            i = i - 1;
        end
        while i > 0
            S(i,i) = S(i,i) - min_sigma;
            if(S(i,i)<0)
                S(i,i) = 0.0;
            end
            i = i - 1;
        end
        
       %% calculate the new result A
        temp_M = U * S * V';
        if(temp_M == 0)
            disp('Error!');
            break;
        else
            for i = 1:m
                for j = 1:n
                    if(M_shadow(i,j) == 0)
                        A(i,j) = temp_M(i,j);
                    end
                end
            end
        end 
        [U,S,V] = svd(A);
    end 
    
    A = prev_result; % if current result A is worse, go back to prev_result
end