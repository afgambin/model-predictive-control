function [array_BS_HE] = generate_harvested_profile(N, shadowing_factor, selected_HE_24_samples, N_on, upThreshold)

% Different pattern for each BS
high_BSs = upThreshold*ones(length(selected_HE_24_samples), N_on);
low_BSs = zeros(length(selected_HE_24_samples), N - N_on);
a = 0;
b = shadowing_factor;
c = shadowing_factor/4;

% Off BSs
for i=1:(N - N_on)
    r = a + (b-a).*rand(24,1);  % random number between [a,b]
    low_BSs(:,i) = r.*selected_HE_24_samples;
end

% On BSs
for i=1:N_on
    r = a + (c-a).*rand(24,1);  % random number between [a,b]
    high_BSs(:,i) = high_BSs(:,i) + r.*selected_HE_24_samples;
end



array_BS_HE = [low_BSs high_BSs];

end