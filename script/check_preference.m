%%  get paths to mat files, raw edfs, etc.

import jj_analysis.process.*;
import jj_analysis.io.*;
import jj_analysis.process.bounds.*;

conf = jj_analysis.config.load();
raw_edf = conf.PATHS.raw_edf;
processed_edf = conf.PATHS.processed_edf;
raw_mat = conf.PATHS.raw_data;
processed_mat = conf.PATHS.processed_data;
plot_p = fullfile( conf.PATHS.data_dir, 'plots', datestr(now, 'mmddyy') );

jj_analysis.util.paths.add_depends();

mats = shared_utils.io.dirnames( fullfile(conf.PATHS.data_dir ...
  , 'tarantino_pharm_raw', 'TarantinoOTPharmacology'), '.mat', false );
ids = cellfun( @(x) x(1:end-4), mats, 'un', false );

%%

load( fullfile(processed_mat, 'processed.mat') );
load( fullfile(processed_mat, 'key.mat') );

task_evt_key = key;
task_events = processed;

task_events = identify_correction_trials( task_events );
task_events = add_drug_type( task_events );

all_dates = task_events('date');
date_nums = datenum( all_dates );

date0 = datenum( '01-Jan-2018' );
ind = date_nums > date0;

latest_dates = all_dates(ind);

%%

subset = task_events(latest_dates);
subset = subset(ids);

%%  no correction

no_corrections = subset({'correction__false'});

%%  err

to_err = subset({'trial_type__choice'});

[I, C] = to_err.get_indices( {'date', 'identifier', 'block'} );

errs = Container();

for i = 1:numel(I)
  
  subset_to_err = to_err(I{i});
  
  err_index = subset_to_err.where( 'no_errors' );
  
  n_no_errs = sum( err_index );
  n_errs = sum( ~err_index );
  
  err_rate = n_errs / (n_no_errs + n_errs);
  
  errs = append( errs, set_data(one(subset_to_err), err_rate) );  
end

%%  pref

to_pref = no_corrections({'trial_type__choice'});

pref_each = {'date', 'identifier', 'block'};

[I, C] = to_pref.get_indices( pref_each );

pref = Container();

for i = 1:numel(I)
  subset_to_pref = to_pref(I{i});
  
  n_rand = sum( subset_to_pref.where('selected_cue__random') );
  n_info = sum( subset_to_pref.where('selected_cue__info') );
  
%   pref_over_rand = (n_info - n_rand) ./ (n_info + n_rand);
  pref_over_rand = n_info ./ (n_info + n_rand);
  
  subset_to_pref = one( subset_to_pref );
  subset_to_pref.data = pref_over_rand;
  
  subset_to_pref('selected_cue') = 'info_over_random';
  
  pref = append( pref, subset_to_pref );
end

%%  all measures

pref = pref.require_fields( 'measure_type' );
pref('measure_type') = 'preference';
errs = errs.require_fields( 'measure_type' );
errs('measure_type') = 'error_rate';

measures = append( pref, errs );

%%  plot on average over days

pl = ContainerPlotter();
prefix = 'preference__average';
output_p = fullfile( plot_p, 'preference' );

pl.y_lim = [0, 1];
pl.x_tick_rotation = 0;

f = figure(1);
clf( f );

pl.bar( measures({'preference'}), 'selected_cue', 'task_type', 'drug' );

fname = fullfile( output_p, prefix );
% shared_utils.io.require_dir( output_p );
% shared_utils.plot.save_fig( gcf, fname, {'epsc', 'png', 'fig'}, true );

%%  plot over blocks

output_p = fullfile( conf.PATHS.data_dir, 'plots', 'error_rate', datestr(now, 'mmddyy') );
shared_utils.io.require_dir( output_p );

[I, C] = measures.get_indices( {'date', 'identifier'} );

for i = 1:numel(I)
  
plt = measures(I{i});

blocks = plt('block');

pl = ContainerPlotter();

pl.y_lim = [0, 1];
% pl.x_tick_rotation = 0;
pl.order_by = blocks;

f = figure(1);
clf( f );

pl.plot_by( plt, 'block', 'task_type', {'drug', 'task_type', 'measure_type'} );

fname = fullfile( flat_uniques(plt, {'date', 'drug' 'task_type', 'identifier'}) );
fname = strjoin( fname, '_' );

full_fname = fullfile( output_p, fname );

shared_utils.plot.save_fig( gcf(), full_fname, {'epsc', 'png', 'fig'}, true );

end

%%  plot each day

pl = ContainerPlotter();

pl.y_lim = [0, 1];
% pl.x_tick_rotation = 0;

days = pref('date');
[~, sorted_ind] = sort( datenum(days) );
days = days(sorted_ind);

f = figure(1);
clf( f );

pl.order_by = days;

pl.bar( pref, 'date', 'task_type', {'drug', 'task_type'} );


%%  plot over days

output_p = fullfile( plot_p, 'preference' );
prefix = 'preference_over_time__';

measdat = measures.data;
measlabs = fcat.from( measures.labels );

mask = fcat.mask( measlabs, @find, {'preference', 'social'} );

pl = plotlabeled.make_common();

dates = combs( measlabs, 'date', mask );
nums = datenum( dates );
[~, I] = sort( nums );

pl.x_order = dates(I);
pl.y_lims = [0.3, 1];

xcats = 'date';
gcats = 'selected_cue';
pcats = { 'measure_type', 'task_type' };

spec = cshorzcat( gcats, pcats );

axs = pl.errorbar( measdat(mask), measlabs(mask), xcats, gcats, pcats );

dsp3.req_savefig( gcf, output_p, measlabs(mask), spec, prefix );











