cont = jj_analysis.io.get_trial_info();

%%

subset = cont.only( {'no_errors', 'trial_type__choice'} );
cue_field = 'selected_cue';
cues = subset( cue_field );
subset = subset.collapse( 'block' );
subset = subset.for_each( {'date', 'block'}, @percentages, cue_field, cues );
summed = subset.for_each( {'date', 'block'}, @sum );
% assert( all(summed.data == 100) );

figure(1);
[h, pl] = subset.plot_by( 'date', 'selected_cue', 'monkey' );

%%

A = [ 10; 11; 80; 70; 60; 65 ];
B = [ 20; 30; 15; 20; 35; 70 ];

ngps = 3;
n = floor( numel(A)/ngps );
ratioA = zeros( 1, ngps );
ratioB = zeros( 1, ngps );
for i = 1:ngps
  [A_, ind] = datasample( A, n, 'replace', false );
  A( ind ) = [];
  B_ = B( ind );
  B( ind ) = [];
  ratioA(i) = sum(A_) / sum([A_; B_]);
  ratioB(i) = sum(B_) / sum([A_; B_]);
end

full_ratioA = mean( ratioA );
full_ratioB = mean( ratioB );

disp( 'A:' );
disp( full_ratioA );
disp( 'B:' );
disp( full_ratioB );
disp( 'Sum:' );
disp( full_ratioA + full_ratioB );

%%
