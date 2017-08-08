function adjust = adjusted_rect( frac_coords, full_rect )

full_width = full_rect(3) - full_rect(1);
full_height = full_rect(4) - full_rect(2);

adjust = zeros( 1, 4 );
adjust(1) = frac_coords(1) * full_width;
adjust(3) = adjust(1) + (full_width * frac_coords(2));
adjust(2) = frac_coords(3) * full_height;
adjust(4) = adjust(2) + (full_height * frac_coords(4));

end