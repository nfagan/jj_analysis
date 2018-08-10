function tf = rectangle_in_bounds(img_rect, pos, obj)

%   RECTANGLE_IN_BOUNDS -- Return whether a coordinate is within a
%     rectangle.
%
%     IN:
%       - `img_rect` (double) -- 4-element rectangle vertices.
%       - `pos` (double) -- 2-element (x, y) coordinate.
%       - `obj` (Container) -- Full fix-event data and labels for the
%         current trial.
%     OUT:
%       - `tf` (logical)

x1 = img_rect(1);
x2 = img_rect(3);
y1 = img_rect(2);
y2 = img_rect(4);

x = pos(:, 1);
y = pos(:, 2);

tf = x >= x1 & x <= x2 & y >= y1 & y <= y2;

end