%%  get valid durations

valid = ~any( isnan(evts.data), 2 );
durations = evts(valid);
duration_index = strcmp( fix_evt_key, 'duration' );
durations.data = durations.data(:, duration_index);

%%  get all durations

durations = evts;
duration_index = strcmp( fix_evt_key, 'duration' );
durations.data = durations.data(:, duration_index);
durations = durations.rm( no_trial_start_ids );

%%  proportion looked vs. no look

durations = pt_events;
durations = durations.require_fields( 'did_look' );
durations( 'did_look', inbounds ) = 'did_look__true';
durations( 'did_look', ~inbounds ) = 'did_look__false';
durations = durations.rm( no_trial_start_ids );

durations.data = zeros( durations.shape(1), 1 );

durations = durations.parfor_each( {'trial', 'identifier'}, @mean );
%   getting 'all__did_look' means that trial had a mix of 'did_look__true'
%   and 'did_look__false', so there was looking on that trial.
durations = durations.replace( 'all__did_look', 'did_look__true' );

look_within = { 'identifier', 'reward_type', 'trial_type', 'selected_cue' };

look_types = durations.pcombs( 'did_look' );

props = durations.for_each( look_within, @proportions, 'did_look', look_types );

%%  fractional looking duration

normdur = durations;
sum_within = { 'trial', 'identifier' };
normdur = normdur.parfor_each( sum_within, @sum );
C = normdur.pcombs( {'trial', 'identifier'} );

for i = 1:size(C, 1)  
  extr = trials.only( C(i, :) );  
  ind = normdur.where( C(i, :) );  
  assert( shape(extr, 1) == 1, 'More than one match.' );  
  state_time = extr.data(2) - extr.data(1);
  normdur.data(ind) = normdur.data(ind) / state_time;
end

mean_within = { 'identifier', 'reward_type', 'trial_type', 'selected_cue' };
normdur_meaned = normdur.parfor_each( mean_within, @mean );

%%  example looking duration

lookdur = durations;

sum_within = { 'trial', 'identifier' };
mean_within = { 'identifier', 'reward_type', 'trial_type', 'selected_cue' };

lookdur = lookdur.parfor_each( sum_within, @sum );
lookdur = lookdur.parfor_each( mean_within, @mean );

%%  example fixation duration

fixdur = durations;

mean_within = { 'identifier', 'reward_type', 'trial_type', 'selected_cue' };
fixdur = fixdur.parfor_each( mean_within, @mean );

%%  example fixation frequency

fixn = durations;
N = shape( fixn, 1 );
fixn.data = ones( N, 1 );

sum_within = { 'trial', 'identifier' };
mean_within = { 'identifier', 'reward_type', 'trial_type', 'selected_cue' };

fixn = fixn.parfor_each( sum_within, @sum );
fixn = fixn.parfor_each( mean_within, @mean );

%%  meaned reaction time

ids = intersect( rt('identifier'), has_trial_start_ids );

rtm = rt;

ind = rtm.data < .1;

rtm = rtm.keep( ~ind );

rtm = rtm.only( ids );
rtm = rtm.only( {'correction__false', 'trial_type__choice'} );

mean_within = { 'identifier', 'selected_cue' };
rtm = rtm.parfor_each( mean_within, @nanmedian );
% rtm = rtm.parfor_each( mean_within, @nanmean );

rtm = rtm.keep( ~isnan(rtm.data) );

%%  error frequency

mat_ids =     task_events( 'identifier' );
el_ids =      eyelink_starts( 'identifier' );
shared_ids =  intersect( mat_ids, el_ids );

err_rate = task_events.only( shared_ids );

err_rate = err_rate.rm( {'no_choice', 'selected_cue__', 'broke_fix'} );

err_types = err_rate( 'errors' );

err_rate_meaned = err_rate.parfor_each( {'identifier', 'selected_cue'} ...
  , @proportions, 'errors', err_types );

err_rate_meaned = err_rate_meaned.rm( {'01-Aug-2017', '02-Aug-2017', '03-Aug-2017'} );

err_rate_meaned = err_rate_meaned.rm( 'no_errors' );

pl.bar( err_rate_meaned, 'selected_cue', 'errors', {'monkey', 'task_type'} );

%%  preference per day

mat_ids =     task_events( 'identifier' );
el_ids =      eyelink_starts( 'identifier' );
shared_ids =  intersect( mat_ids, el_ids );

pref = task_events.only( shared_ids );
pref.data = zeros( shape(pref, 1), 1 );

pref = pref.only( 'correction__false' );  % no correction trials.
pref = pref.only( 'no_errors' );
pref = pref.only( 'trial_type__choice' );
pref = pref.only( {'juice', 'monkey__Kubrick'} );
% pref = pref.rm( {'01-Aug-2017', '02-Aug-2017', '03-Aug-2017'} );

cue_field = 'shown_reward_cue';

noninfo_cues =  { 'shown_reward_cue__noninfo2.png', 'shown_reward_cue__noninfo1.png' };
info_cues =     { 'shown_reward_cue__info1.png', 'shown_reward_cue__info2.png' };
blue_cues =     { 'shown_reward_cue__bluebar.png', 'shown_reward_cue__bluebracket.png' };
green_cues =    { 'shown_reward_cue__greenbar.png', 'shown_reward_cue__greenbracket.png' };

pref = pref.replace( noninfo_cues, 'non_info_cue' );
pref = pref.replace( info_cues, 'info_cue' );
pref = pref.replace( blue_cues, 'blue' );
pref = pref.replace( green_cues, 'green' );

cues = pref( cue_field );

pref_within = { 'identifier', 'block' };

pref_meaned = pref.parfor_each( pref_within, @proportions, cue_field, cues );

pl = ContainerPlotter();
pl.per_panel_labels = true;

pref_meaned.plot_by( pl, 'identifier', cue_field, {'monkey', 'task_type'} );

%%  preference over days

mat_ids =     task_events( 'identifier' );
el_ids =      eyelink_starts( 'identifier' );
shared_ids =  intersect( mat_ids, el_ids );

pref = task_events.only( shared_ids );
pref.data = zeros( shape(pref, 1), 1 );

pref = pref.only( 'correction__false' );  % no correction trials.
pref = pref.only( 'no_errors' );
pref = pref.only( 'trial_type__choice' );
% pref = pref.only( {'juice', 'monkey__Kubrick'} );

cue_field = 'selected_cue';
cues = pref( cue_field );

pl.default();
pl.add_points = false;

pref_within = { 'identifier' };

pref_meaned = pref.parfor_each( pref_within, @proportions, cue_field, cues );
pref_meaned = pref_meaned.rm( {'01-Aug-2017', '02-Aug-2017', '03-Aug-2017'} );

h = pl.bar( pref_meaned, 'task_type', cue_field, 'monkey' );

%%  plot

figure(1);

to_plot = rtm.rm( 'juice' );
to_plot.labels = to_plot.labels.sort_labels();

pl = ContainerPlotter();
pl.order_by = { 'neutral', 'threat', 'small', 'big' };
pl.per_panel_labels = true;

% to_plot.bar( pl, 'reward_type', {'trial_type', 'selected_cue'}, {'task_type', 'did_look'} );
% to_plot.bar( pl, 'reward_type', {'trial_type', 'selected_cue'}, {'task_type'} );
to_plot.bar( pl, 'selected_cue', {'trial_type'}, {'task_type'} );