%%  load

pathstr = jj_analysis.util.paths.pathfor( 'raw_data' );
cont = jj_analysis.io.get_trial_info( pathstr );

%%  get preference over days

valid = cont.only( 'no_errors' );
choice = valid.only( 'trial_type__choice' );
choice = choice.do( {'date', 'block'}, @percentages, 'selected_cue' );

pl = ContainerPlotter();

%%  plot preference over days

pl.default();
pl.y_lim = [0 100];

pl.plot_by( choice, 'date', 'selected_cue', [] );

%%  plot preference within a block

pl.default();
pl.y_lim = [0 100];

dates = choice('date');
one_session = choice.only( dates{2} );

pl.plot_by( one_session, 'block', 'selected_cue', [] );