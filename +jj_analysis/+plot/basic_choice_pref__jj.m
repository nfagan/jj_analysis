%%  load

pathstr = jj_analysis.util.paths.pathfor( 'raw_data' );
cont = jj_analysis.io.get_trial_info( pathstr );

pl = ContainerPlotter();



%%  get preference over days

valid = cont.only( 'no_errors' );
choice = valid.only( 'trial_type__choice' );
%   calculate the percentage of each selected_cue, within day + block
choice = choice.do( {'date', 'block'}, @percentages, 'selected_cue', choice('selected_cue') );

%%  only no correction trials

[valid, errs] = jj_analysis.process.exclude_n_plus_one_errors( cont );

valid = valid.only( 'trial_type__choice' );

% valid = valid.only('10-Nov-2017');

choice = valid.do( {'date', 'block', 'monkey', 'task_type'}, @percentages, 'selected_cue', valid('selected_cue') );
%%  plot preference over 

%plt = choice
%plt = choice.only('task_type__juice');
%plt = choice.only({'task_type__social', 'monkey__Tarantino'});
plt = choice.only({'task_type__juice', 'monkey__Hitchcock'});

days = plt( 'date' );
dnums = datenum( days );
[~, sorted_ind] = sort( dnums );
days = days( sorted_ind );

pl.default();
pl.y_lim = [ 0 100 ];
pl.order_by = days;

pl.plot_by( plt, 'date', 'selected_cue', [] );

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
%err_rate = err_rate.rm( {'selected_cue__info', 'selected_cue__'} );
err_types = err_rate( 'errors' );
fs = { 'errors' };
C = err_rate.combs( fs );
%  err_rate = err_rate.do( {'date', 'selected_cue'}, @percentages, fs, C );
err_rate = err_rate.do( {'date', 'block', 'task_type', 'monkey', 'selected_cue'}, @percentages, fs, C );

%%

plt_err = err_rate;

plt_err = plt_err.only({'task_type__social', 'monkey__Tarantino'});

plt_err = plt_err.remove( {'selected_cue__'} );

 days = plt_err( 'date' );
 dnums = datenum( days );
 [~, sorted_ind] = sort( dnums );
 days = days( sorted_ind );

% err_rate = err_rate.only( days{3} );

n_blocks = numel( err_rate('block') );

pl.default();
pl.y_lim = [0, 100];
% pl.order_by = arrayfun( @(x) ['block__', num2str(x)], 1:n_blocks, 'un', false );
pl.order_by = days;

%  pl.plot_by( err_rate, 'block', 'errors', [] );
%%
figure
% pl.plot_by( err_rate, 'date', 'selected_cue', 'errors' ); %by days
pl.plot_by( plt_err, 'date', 'errors', 'selected_cue'); %blocks include err_rate = err_rate.only('05_31TaC'); above plotting function

