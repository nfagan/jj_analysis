%%  load

pathstr = jj_analysis.util.paths.pathfor( 'raw_data' );
cont = jj_analysis.io.get_trial_info( pathstr );

pl = ContainerPlotter();

%%  get preference over days

valid = cont.only( 'no_errors' );
choice = valid.only( 'trial_type__choice' );
%   calculate the percentage of each selected_cue, within day + block
choice = choice.do( {'date', 'block'}, @percentages, 'selected_cue' );

%%  plot preference over days

pl.default();
pl.y_lim = [0 100];

pl.plot_by( choice, 'date', 'selected_cue', [] );

%%  plot preference within a block

n_blocks = numel( choice('block') );

pl.default();
pl.y_lim = [0 100];
pl.order_by = arrayfun( @(x) ['block__', num2str(x)], 1:n_blocks, 'un', false );

dates = choice('date');
one_session = choice.only( dates{1} );

pl.plot_by( one_session, 'block', 'selected_cue', [] );