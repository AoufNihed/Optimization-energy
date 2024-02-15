 %Define parameters:
load_demand = [100 90 80 70 60]; % Load demand for 5 time periods (kW)
solar_generation_forecast = [30 40 50 40 30]; % Solar generation forecast for 5 time periods (kW)
battery_capacity = 100; % Battery capacity (kWh)
initial_battery_state = 50; % Initial state of charge of the battery (kWh)
grid_price = [0.1 0.15 0.2 0.15 0.1]; % Grid electricity price for 5 time periods ($/kWh)
battery_efficiency = 0.95; % Battery charging/discharging efficiency
battery_degradation_cost = 0.04; % Cost of battery degradation per kWh

% Define variables:
num_periods = length(load_demand);
battery_state = zeros(1, num_periods); % State of charge of the battery for each time period (kWh)
grid_import = zeros(1, num_periods); % Grid electricity import for each time period (kW)

% Initialize the battery state:
battery_state(1) = initial_battery_state;
% Optimization using a simple linear programming approach
for t = 1:num_periods
% Calculate available energy from solar and battery
available_energy = solar_generation_forecast(t) + battery_state(t) - load_demand(t);

% Check if the battery needs to be charged from the grid
if available_energy < 0
grid_import(t) = abs(available_energy);
battery_state(t) = 0;
else
% Charge the battery if excess energy is available
excess_energy = min(available_energy, battery_capacity - battery_state(t));
battery_state(t) = battery_state(t) + excess_energy;
end

% Calculate battery degradation cost
battery_degradation_cost_t = battery_degradation_cost * (battery_state(t) / battery_capacity)^2;
% Update the battery state for the next time period
if t < num_periods
battery_state(t+1) = battery_state(t) * battery_efficiency + (solar_generation_forecast(t) - load_demand(t) - grid_import(t)) / battery_efficiency;
end
% Calculate total cost for this time period
total_cost = grid_import(t) * grid_price(t) + battery_degradation_cost_t;

% Display results for this time period
disp(['Time Period ' num2str(t) ':'])
disp(['Grid Import (kWh)'  num2str(grid_import(t))])
disp(['Battery State of Charge (kWh)' num2str(battery_state(t))])
disp(['Battery Degradation Cost (DZ)' num2str(battery_degradation_cost_t)])
disp(['Total Cost (DZ)' num2str(total_cost)])
end

% Display the overall results
disp('Overall Results:')
disp(['Total Grid Import (kWh): ' num2str(sum(grid_import))])
disp(['Total Battery Degradation Cost (DZ): ' num2str(sum(battery_degradation_cost * (battery_state / battery_capacity).^2))])
disp(['Total Cost (DZ): ' num2str(sum(grid_import .* grid_price) + sum(battery_degradation_cost * (battery_state / battery_capacity).^2))])
