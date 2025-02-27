% -----------------------------------------------------------------
% EPIDEMIC - Epidemiology Educational Code
% www.EpidemicCode.org
% -----------------------------------------------------------------
% Modeling: rhs_SEIR(+AHD).m
%
% This function defines the system of ODEs for the
% SEIR(+AHD) epidemic model.
%
% The dynamic state coordinates are:
%
%   S = susceptibles            (number of individuals)
%   E = exposed                 (number of individuals)
%   I = symptomatic infectious  (number of individuals)
%   A = asymptomatic infectious (number of individuals)
%   H = hospitalized            (number of individuals)
%   R = recovered               (number of individuals)
%   D = deceased                (number of individuals)
%   C = cumulative infectious   (number of individuals)
%
% The epidemic model parameters are:
%
%   N0       = initial population size            (number of individuals)
%   beta     = transmission rate                  (days^-1)
%   alpha    = latent rate                        (days^-1)
%   fE       = symptomatic fraction               (dimensionless)
%   gamma    = recovery rate                      (days^-1)
%   rho      = hospitalization rate               (days^-1)
%   delta    = death rate                         (days^-1)
%   kappaH   = hospitalization mortality-factor   (dimensionless)
%
% Inputs:
%   t: time                    - double
%   y: state vector            - double array (8x1)
%   param: parameters vector   - double array (8x1)
%
% Output:
%   dydt: state rate of change - double array (8x1)
% -----------------------------------------------------------------
% programmers: Eber Dantas
%              Americo Cunha
%
% number of lines: 36
% last update: Jan 17, 2021
% -----------------------------------------------------------------

% -----------------------------------------------------------------
function dydt = rhs_SEIRAHD(t,y,param)

if length(param) < 8
   error('Warning: To few model parameters')
elseif length(param) > 8
   error('Warning: To many model parameters')
end

if mod(param(1),1) ~= 0
   error('Warning: Use a integer population size')
end

if sum(param<0)~=0
   error('Warning: Use positive parameters values')
end

if sum([param(5) param(8)]>1) ~=0
   error('Warning: Use values < 1 for fE,kappaH')
end


% model parameters: param = [N0 alpha fE gamma rho delta kappaH zeta]
N0       = param(1);  % initial population size   (number of individuals)
beta     = param(2);  % transmission rate (days^-1)
alpha    = param(3);  % latent rate (days^-1)
fE       = param(4);  % symptomatic fraction (dimensionless)
gamma    = param(5);  % recovery rate (days^-1)
rho      = param(6);  % hospitalization rate (days^-1)
delta    = param(7);  % death rate (days^-1)
kappaH   = param(8);  % hospitalization mortality-factor (dimensionless)

% SEIR(+AHD) dynamic model:
% 
%      y = [S E I A H R D C]               is the state vector
%   dydt = [dSdt dEdt dIdt dRdt dDdt dCdt] is the evolution law
%      N = current population at time t
% 
% dSdt - rate of susceptible             (number of individuals/days)
% dEdt - rate of exposed                 (number of individuals/days)
% dIdt - rate of symptomatic infectious  (number of individuals/days)
% dAdt - rate of asymptomatic infectious (number of individuals/days)
% dHdt - rate of hospitalized            (number of individuals/days)
% dRdt - rate of recovered               (number of individuals/days)
% dDdt - rate of deaths                  (number of individuals/days)
% dCdt - rate of cumulative infectious   (number of individuals/days)

[S E I A H R D C] = deal(y(1),y(2),y(3),y(4),y(5),y(6),y(7),y(8));

   N = N0 - D;
dSdt = - beta*S.*(I+A+H)./N;   
dEdt = beta*S.*(I+A+H)./N - alpha*E;                                           
dIdt = fE*alpha*E - (gamma+rho+delta)*I;           
dAdt = (1-fE)*alpha*E - (gamma+delta)*A;           
dHdt = rho*I - (gamma+kappaH*delta)*H;             
dRdt = gamma*(I+A+H);
dDdt = delta*(I+A+kappaH*H);
dCdt = alpha*E;                                    

% system of ODEs
dydt = [dSdt; dEdt; dIdt; dAdt; dHdt; dRdt; dDdt; dCdt];

end
% -----------------------------------------------------------------
