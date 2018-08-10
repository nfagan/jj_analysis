%%  load

pathstr = jj_analysis.util.paths.pathfor( 'raw_data' );
cont = jj_analysis.io.get_trial_info( pathstr );

%%  analyze

%   select non-error choice trials

choice = cont.only( {'trial_type__choice', 'no_errors'} );

%   identify the kinds of cues present in `choice`

cues = choice( 'selected_cue' );

%   for each 'date', calculate the counts (frequencies) of each 
%   'selected_cue'. Pass in `cues` to ensure that, if a given day doesn't
%   have one of those `cues`, it will have a count of 0.

cnts = choice.for_each( 'date', @counts, 'selected_cue', cues );

%   extract the counts for each kind of cue.

info_cnts = cnts.only( 'selected_cue__info' );
rand_cnts = cnts.only( 'selected_cue__random' );

%   objects can't be added, subtracted, etc. unless their labels are
%   equivalent. collapse the 'selected_cue' field of each object to
%   make their labels equivalent.

info_cnts = info_cnts.collapse( 'selected_cue' );
rand_cnts = rand_cnts.collapse( 'selected_cue' );

%   calculate the preference index (A-B) / (A+B). Because we calculated
%   counts for each 'date', the preference index is also with respect to
%   'date'.

pref = ( info_cnts - rand_cnts ) ./ ( rand_cnts + info_cnts );

%   add a new field of labels 'preference' to mark that the data points in
%   `pref` describe preference for information over random.

pref = pref.add_field( 'preference', 'prefers_info_over_random' );

%   create a bar plot where 'preference' forms the x-axis, and with a panel
%   for each 'monkey'. Set grouping to [] such that the bar-plot isn't
%   grouped.

figure(1);

pref.bar( 'preference', [], 'monkey' );

%   plot with 'date' on the x-axis, instead. Group by 'preference' to add a
%   legend identifying each bar-group (though, in this case, there's only
%   one).

figure(2);

pref.bar( 'date', 'preference', 'monkey' );

