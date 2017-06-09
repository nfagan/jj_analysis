%%  load

pathstr = jj_analysis.util.paths.pathfor( 'raw_data' );
cont = jj_analysis.io.get_trial_info( pathstr );

pl = ContainerPlotter();



%%  get preference over days

valid = cont.only( 'no_errors' );
choice = valid.only( 'trial_type__choice' );
%   calculate the percentage of each selected_cue, within day + block
choice = choice.do( {'date', 'block'}, @percentages, 'selected_cue' );

%%  only no correction trials

[valid, errs] = jj_analysis.process.exclude_n_plus_one_errors( cont );

valid = valid.only( 'trial_type__choice' );

choice = valid.do( {'date', 'block'}, @percentages, 'selected_cue' );
%%  plot preference over days

pl.default();
pl.y_lim = [ 0 100 ];

pl.plot_by( choice, 'date', 'selected_cue', [] );

%%  plot preference within a block

n_blocks = numel( choice('block') );

pl.default();
pl.y_lim = [0 100];
pl.order_by = arrayfun( @(x) ['block__', num2str(x)], 1:n_blocks, 'un', false );

dates = choice('date');
one_session = choice.only( dates{end-3} );

pl.plot_by( one_session, 'block', 'selected_cue', 'date' );

%%  plot error rate

err_rate = cont.only( 'trial_type__choice' );
err_rate = err_rate.rm( {'broke_fix'} );
err_types = err_rate( 'errors' );
% err_rate = err_rate.do( {'date', 'selected_cue'}, @percentages, 'errors', err_types );
 err_rate = err_rate.do( {'date', 'block', 'selected_cue'}, @percentages, 'errors', err_types );

 days = err_rate( 'date' );

% err_rate = err_rate.only( days{3} );

n_blocks = numel( err_rate('block') );

pl.default();
pl.y_lim = [];
 pl.order_by = arrayfun( @(x) ['block__', num2str(x)], 1:n_blocks, 'un', false );

%  pl.plot_by( err_rate, 'block', 'errors', [] );

% pl.plot_by( err_rate, 'date', 'selected_cue', 'errors' ); %by days
pl.plot_by( err_rate, 'block', 'selected_cue', 'errors'); %blocks include err_rate = err_rate.only('05_31TaC'); above plotting function