function rect = get_centered_rect( sz, w, h )

%   GET_RECT -- Get the vertices of a square centered in a screen.
%
%     IN:
%       - `sz` (double) -- Size of the square image.
%       - `w` (double) -- Width of the screen.
%       - `h` (double) -- Height of the screen.
%     OUT:
%       - `rect` (double) -- 4-element square vertices.

rect = [w/2-(sz/2), h/2-(sz/2), w/2+(sz/2), h/2+(sz/2)];

end