function f = fractional_coordinates( rect1, rect2 )

x1a = rect1(1);
x2a = rect1(3);
y1a = rect1(2);
y2a = rect1(4);

x1b = rect2(1);
x2b = rect2(3);
y1b = rect2(2);
y2b = rect2(4);

fractional_width = (x2b-x1b) / (x2a-x1a);
fractional_height = (y2b-y1b) / (y2a-y1a);
x0 = x1b / (x2a-x1a);
y0 = y1b / (y2a-y1a);

f = [x0, fractional_width, y0, fractional_height];

end