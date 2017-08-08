function [adjusted_eyes, adjusted_mouth] = get_eye_mouth_rois( img_rect )

import jj_analysis.process.*;

%  original rois -- see exampleScript.m in Courtney

image = [600, 150, 1200, 750];
eyes = [690, 247, 1095, 392];
mouth = [711, 547, 1070, 750];

%  get eye / mouth proportions

mouth_prop = fractional_coordinates( image, mouth );
eyes_prop = fractional_coordinates( image, eyes );

%  Convert to the current image size

adjusted_mouth = adjusted_rect( mouth_prop, img_rect );
adjusted_eyes = adjusted_rect( eyes_prop, img_rect );

end