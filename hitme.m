hitme
s = lspb(0, 1, steps); % Linear segment with parabolic blend from 0 to 1 over 'steps' steps
qMatrix_trapz = nan(steps, 6); % Preallocate matrix for joint states

L1 = Link('d',0,'a',1,'alpha',0,'qlim',[-pi pi]);
L2 = Link('d',0,'a',1,'alpha',0,'qlim',[-pi pi]);
L3 = Link('d',0,'a',1,'alpha',0,'qlim',[-pi pi]);
L4 = Link('d',0,'a',1,'alpha',0,'qlim',[-pi pi]);
L5 = Link('d',0,'a',1,'alpha',0,'qlim',[-pi pi]);


% Generate trajectory for each joint using the trapezoidal profile
for i = 1:steps
    qMatrix_trapz(i, :) = (1 - s(i)) * q1 + s(i) * q2;
end

% Calculate relative velocities for each joint
velocity_trapz = zeros(steps - 1, 6); % Preallocate for velocity matrix
for i = 2:steps
    velocity_trapz(i - 1, :) = (qMatrix_trapz(i, :) - qMatrix_trapz(i - 1, :));
end

% Convert the relative velocities to absolute values and round them
velocity_trapz_abs = abs(velocity_trapz);
velocity_trapz_rounded = round(velocity_trapz_abs, 4);

% Determine the maximum absolute velocity for any joint
max_absolute_velocity = max(velocity_trapz_rounded(:));

% Display the result
fprintf('The maximum absolute velocity performed by any of the joints is: %.4f\n', max_absolute_velocity);