subset = task_events.only( shared_ids );
subset = subset.rm( no_trial_start_ids );
subset = subset.rm( '13-Jul-2017' );
subset = subset.parfor_each( 'identifier', @jj_analysis.process.exclude_n_plus_one_errors );

choice = subset.only( 'trial_type__choice' );

cues = choice.pcombs( 'selected_cue' );

pref = choice.parfor_each( 'identifier', @proportions, 'selected_cue', cues );
pref = pref.only( 'selected_cue__info' );

%%

to_correlate = normdur_meaned;

organize_within = { 'identifier', 'reward_type', 'trial_type', 'selected_cue' };
to_match = setdiff( organize_within, 'identifier' );

enumed = to_correlate.enumerate( organize_within );

rebuilt_pref = Container();
rebuilt_corr = Container();

for i = 1:numel(enumed)
  current = enumed{i};
  id = current( 'identifier' );
  matching_pref = pref.only( id );
%   for j = 1:numel(to_match)
%     matching_pref( to_match{j} ) = current( to_match{j} );
%   end
  matching_pref.labels = current.labels;
  rebuilt_pref = rebuilt_pref.append( matching_pref );
  rebuilt_corr = rebuilt_corr.append( current );
end

% rebuilt_corr = rebuilt_corr.rm_fields( 'rois' );

%%

pl = ContainerPlotter();

to_plot_corr = rebuilt_corr.only( 'social' );
to_plot_pref = rebuilt_pref.only( 'social' );

pl.x_lim = [0, 1];

pl.scatter( to_plot_pref, to_plot_corr, {'trial_type', 'selected_cue'}, 'reward_type' );