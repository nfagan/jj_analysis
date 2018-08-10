function rt = calculate_reaction_time(x, y, t, vel_thresh, vel_window_size)

sizes = [ size(x, 1), size(y, 1), size(t, 1) ];
assert( all(diff(sizes) == 0 ), 'Improperly dimensioned x, y, or t inputs' );

if ( nargin < 5 )
  vel_window_size = 10;    %   - window size for getting an avg velocity
end

rt = NaN;

curr_x = x(:)';
curr_y = y(:)';
curr_t = t(:)';

smooth_x = smooth( curr_x, 'sgolay' )';
smooth_y = smooth( curr_y, 'sgolay' )';

%   - steve's code -- convert from pixels to degrees. confirm 
%     distance / resolution / screensize settings are accurate in
%     Pix2Deg

deg_x = pix_to_deg( smooth_x );
deg_y = pix_to_deg( smooth_y );

new_size = [size(deg_x, 1) size(deg_x, 2) - (vel_window_size+1)];

x_vel = zeros(new_size); 
y_vel = zeros(new_size);
new_t = zeros(new_size);

%   - velocity over n sample window

for j = (vel_window_size+1):size(deg_x,2)
  delta_x = deg_x(:,j) - deg_x(:,j-vel_window_size);
  delta_y = deg_y(:,j) - deg_y(:,j-vel_window_size);
  delta_t = curr_t(:,j) - curr_t(:,j-vel_window_size);

  x_vel(:,j-vel_window_size) = abs(delta_x ./ (delta_t/1e3));
  y_vel(:,j-vel_window_size) = abs(delta_y ./ (delta_t/1e3));
  new_t(:,j-vel_window_size) = curr_t(:, j);
end

above_thresh_x = find( x_vel > vel_thresh, 1, 'first' );
above_thresh_y = find( y_vel > vel_thresh, 1, 'first' );

if ( ~isempty(above_thresh_x) && ~isempty(above_thresh_y) )
  min_start = min( above_thresh_x, above_thresh_y );
  start_time = new_t( min_start );
  rt = (start_time - t(1)) / 1e3;
end

end


function degrees = pix_to_deg(pixel, distance, H_res,V_res, H_monitor, V_monitor)

%   Steve's code for converting pixel coords -> degrees

if nargin < 2
    distance = 44;
    H_res = 1200;
    V_res = 900;
    H_monitor = 33;
    V_monitor = 25;
end

% Get how many cm is a pixel from the resolution and size of the
% monitor
H_pixel = H_monitor/H_res;
V_pixel = V_monitor/V_res;

H_radian = 2 * atan( (H_pixel/2) / distance );
V_radian = 2 * atan( (V_pixel/2) / distance );        

Hdeg = rad2deg(H_radian);
Vdeg = rad2deg(V_radian);

DegreesPerPixel = mean([Hdeg, Vdeg]);
degrees = DegreesPerPixel .* pixel;

end