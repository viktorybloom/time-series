%load spxvix2016

bigt = length(rets);

ewma = zeros(bigt,1);
ewma(1) = mean(rets.^2);

lambda = 0.95;

for t = 2:bigt
    
    ewma(t) = lambda*ewma(t-1) + (1-lambda)*rets(t-1)^2;
    
end
