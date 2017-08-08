P = jj_analysis.util.paths.pathfor( 'raw_data' );
P2 = jj_analysis.util.paths.pathfor( 'processed_edf' );
[task_events, task_evt_key] = jj_analysis.io.get_trial_info( P );

%%
P2 = jj_analysis.util.paths.pathfor( 'raw_edf' );
edfs = jj_analysis.util.general.dirstruct( P2, 'edf' );
edfs = { edfs(:).name };

% edfs = {'07_22TaA.edf', '07_25KuA.edf', '07_25TaA.edf', '07_26KuA.edf', '07_26TaA.edf' };

bad_files = {};
good_files = {};

for i = 1:numel(edfs)
  fprintf( '\n Processing %d of %d', i, numel(edfs) );
  try
    b = Edf2Mat(edfs{i});
    good_files{end+1} = edfs{i};
  catch
    fprintf( '\n Error opening ''%s''.', edfs{i} );
    bad_files{end+1} = edfs{i};
  end
end

%%  edf -> mat

conf = jj_analysis.config.load();
raw_edf = conf.PATHS.raw_edf;
proc_edf = conf.PATHS.processed_edf;
jj_analysis.process.edf_to_mat( raw_edf, proc_edf );

%%  load processed edfs saved as .mat

edfs = jj_analysis.io.get_edfs( proc_edf );

%%  get trial start times + fix events

starts = jj_analysis.process.get_trial_starts( edfs );
[fix_events, fix_evt_key] = jj_analysis.process.get_fix_events( edfs );

%%  convert matlab time -> eyelink time

shared_ids = intersect( task_events('identifier'), starts('identifier') );
extr = task_events.only( shared_ids );
extr.data = extr.data(:, 2:end);

aligned = jj_analysis.process.to_edf_time( extr, starts );

aligned.data = [aligned.data(:, 3), aligned.data(:, 3) + 1e3];
per_trial_events = jj_analysis.process.get_fix_events_per_trial( aligned, fix_events, fix_evt_key );

%%
