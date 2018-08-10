% evt_start = 'display_random_vs_info_cues';
evt_start = 'display_info_cues';
evt_stop = 'reward';

baseline_amt = 200;
look_ahead = 3e3;

trials = get_start_stop_events( aligned, evt_start, evt_stop, task_evt_key );

evt_start_t = trials.data(:, 1);

trials.data(:, 1) = evt_start_t - baseline_amt;
trials.data(:, 2) = evt_start_t + look_ahead;

[I, C] = trials.get_indices( {'identifier', 'date'} );

all_pup = Container();

collapse_trial = false;
do_normalize = true;
normalize_first_block = true;

for i = 1:numel(I)
  pup = jj_analysis.process.get_pupil_trace( trials(I{i}), edfs );
  
  empties = cellfun( @isempty, pup.data ) | ...
    cellfun( @(x) numel(x) ~= look_ahead + baseline_amt + 1, pup.data );
  pup(empties) = [];
  
  baseline = cellfun( @(x) nanmean(x(1:baseline_amt)), pup.data );
  
  if ( collapse_trial )
    rest = cellfun( @(x) nanmean(x(baseline_amt+1:end)), pup.data );
    if ( do_normalize )
      res = res ./ baseline;
    end
    all_pup = append( all_pup, set_data(pup, rest ./ baseline) );
    continue;
  end
  
  rest = cell2mat( cellfun(@(x) x(baseline_amt+1:end)', pup.data, 'un', false) );
  
  if ( do_normalize && ~normalize_first_block )
    rest = bsxfun( @rdivide, rest, baseline );
  end
  
  if ( normalize_first_block )
    block_1_ind = where( pup, 'block__1' );
    baseline_block_1 = nanmean( baseline(block_1_ind, :) );
    rest = rest ./ baseline_block_1;
  end
  
  all_pup = append( all_pup, set_data(pup, rest) );
end

% all_pup.data = cell2mat( cellfun(@(x) x(:)', all_pup.data, 'un', false) );

%%

conf = jj_analysis.config.load();

save_p = fullfile( conf.PATHS.data_dir, 'plots', 'pupil', 'bar', datestr(now, 'mmddyy') );

pl = ContainerPlotter();
pl.y_lim = [0, 1];

f = figure(1);
clf( f );

plt = all_pup;

plt.data = nanmean( plt.data, 2 );
plt = plt.each1d( {'date'}, @rowops.nanmean );

plt = plt.collapse( {'date', 'selected_cue'} );

groups_are = { 'drug' };
x_is = 'selected_cue';
panels_are = { 'task_type' };

pl.bar( plt, x_is, groups_are, panels_are );


%%

conf = jj_analysis.config.load();

save_p = fullfile( conf.PATHS.data_dir, 'plots', 'pupil' ...
  , 'line', datestr(now, 'mmddyy') );

pl = ContainerPlotter();
pl.y_lim = [0.35, 1.4];
% pl.y_lim = [2200, 5200];
pl.x_lim = [0, 3e3];
pl.x = 0:look_ahead;
pl.y_label = 'Normalized pupil size';
pl.x_label = 'Time (ms) from info vs. random cue display.';

f = figure(1);
clf( f ); 

pl.add_ribbon = true;

plt = all_pup;

plt = plt.each1d( {'date'}, @rowops.nanmean );

plt = plt.collapse( {'date', 'selected_cue'} );

% plt = plt.only( {'trial_type__choice', 'correction__false'} );

% plt = plt.each1d( {'date'}, @rowops.nanmean );
% plt = plt.collapse( 'task_type' );

% plt = plt.collapse( 'date' );

figs_are = { 'date' };

lines_are = { 'drug' };
panels_are = { 'date', 'task_type' };

filenames_are = unique( [figs_are, lines_are, panels_are] );

[I, C] = plt.get_indices( figs_are );

for i = 1:numel(I)
  
subset_plt = plt( I{i} );

pl.plot( subset_plt, lines_are, panels_are );

filename = strjoin( flat_uniques(subset_plt, filenames_are) );

separate_folders = true;

shared_utils.io.require_dir( save_p );

shared_utils.plot.save_fig( f, fullfile(save_p, filename) ...
  , {'epsc', 'png', 'fig'}, separate_folders );

end

%%  bar

conf = jj_analysis.config.load();

save_p = fullfile( conf.PATHS.data_dir, 'plots', 'pupil', 'bar', datestr(now, 'mmddyy') );

pl = ContainerPlotter();

f = figure(1);
clf( f ); 

plt = all_pup;
plt = plt.only( 'correction__false' );

plt = plt.collapse( {'date', 'selected_cue'} );

figs_are = { 'date' };
x_is = 'selected_cue';
lines_are = { 'drug' };
panels_are = { 'task_type', 'date' };

filenames_are = unique( [figs_are, lines_are, panels_are] );

[I, C] = plt.get_indices( figs_are );

for i = 1:numel(I)
  
subset_plt = plt( I{i} );

pl.bar( subset_plt, x_is, lines_are, panels_are );

filename = strjoin( flat_uniques(subset_plt, filenames_are) );

separate_folders = true;

shared_utils.io.require_dir( save_p );

shared_utils.plot.save_fig( f, fullfile(save_p, filename) ...
  , {'epsc', 'png', 'fig'}, separate_folders );

end

