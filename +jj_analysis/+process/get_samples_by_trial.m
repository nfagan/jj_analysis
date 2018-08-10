function trial_samples = get_samples_by_trial( trials, samples, sample_key )

%   GET_SAMPLES_BY_TRIAL -- Bin raw eye-data samples into trials.
%
%     trial_samps = ... get_samples_by_trial( trials, samples, sample_key )
%     uses the start and stop times in `trials` to create a matrix of
%     position, pupil size, and time samples for each trial. `trial_samps`
%     is a Container of the same size as `trials`, whose data are cell
%     arrays of per-trial samples.
%
%     IN:
%       - `trials` (Container) -- Start and stop times.
%       - `samples` (Container) -- Samples.
%       - `sample_key` (cell array of strings) -- Identifiers for each
%         column of `samples`.

import jj_analysis.util.assertions.*;

assert__isa( trials, 'Container', 'the trial starts and stops' );
assert__isa( samples, 'Container', 'the edf samples' );
assert__is_cellstr( sample_key );

required_keys = { 'time' };

assert__strings_present( sample_key, required_keys, 'the sample key' );

assert( numel(sample_key) == size(samples.data, 2), ['The given sample' ...
  , ' key does not properly correspond to the dimensions of the sample' ...
  , ' matrix.'] );

trial_ids = trials( 'identifier' );
sample_ids = samples( 'identifier' );

assert( isempty(setdiff(trial_ids, sample_ids)), ['Some of the trial' ...
  , ' identifiers were not present in the edf samples.'] );

trial_samples = cell( 1, numel(trial_ids) );

parfor i = 1:numel(trial_ids)
  id = trial_ids{i};
  trial = trials.only( id );
  sample = samples.only( id );
  trial_samples{i} = per_id( trial, sample, sample_key );
end

trial_samples = extend( trial_samples{:} );

end

function trial_samples = per_id( trials, samples, sample_key )

%   PER_ID -- Get samples for one identifier.

trial_times = trials.data;
sample_data = samples.data;

n_rows = size( trial_times, 1 );
n_cols = size( trial_times, 2 );

new_data = cell( n_rows, 1 );

trial_samples = trials;

%   don't proceed if all trial times are NaN

if ( all(isnan(trial_times(:))) )
  new_data = cellfun( @(x) nan(1, n_cols), new_data, 'un', false );
  trial_samples.data = new_data;
  return;
end

time_ind = strcmp( sample_key, 'time' );
sample_times = sample_data(:, time_ind);

error_data = nan( 1, n_cols );

for i = 1:size(trial_times, 1)
  trial = trial_times(i, :);
  if ( any(isnan(trial)) )
    new_data{i} = error_data;
    continue;
  end
  
  start = trial(1);
  stop = trial(2);
  
  if ( start > stop )
    warning( 'Start-time was greater than stop-time.' );
    new_data{i} = error_data;
    continue;
  end
  
  start_diff = abs( sample_times - start );
  stop_diff = abs( sample_times - stop );
  start_ind = find( start_diff == min(start_diff) );
  stop_ind = find( stop_diff == min(stop_diff) );
  
  num_inds = start_ind:stop_ind;
  
  new_data{i} = sample_data( num_inds, : );
end

trial_samples.data = new_data;

end