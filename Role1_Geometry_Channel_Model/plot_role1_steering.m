function plot_role1_steering(txArray, f)
%PLOT_ROLE1_STEERING Show that changing the steering angle changes the beam.

angles = [ ...
     30 -30;
      0 -30;
    -30 -30];

for k = 1:size(angles,1)
    az = angles(k,1);
    el = angles(k,2);

    w = steering_weights(txArray, f, az, el);

    figure;
    pattern( ...
        txArray, f, ...
        -180:180, -90:90, ...
        Weights=w, ...
        Type="powerdb");

    title(sprintf("Tx array: steering az = %d°, el = %d°", az, el));
end
end
