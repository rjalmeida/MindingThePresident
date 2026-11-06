function[Z]=regressor_matrix(y,p)

% This function constructs a matrix of lagged regressors

n=size(y,2);
k=size(y,1);

Z=zeros(k*p,n);

for i=1:p
    Z(((i-1)*k+1):(i*k),(1+i):n) = y(:,1:(n-i));
end
Z=Z(:,(1+p):n);
