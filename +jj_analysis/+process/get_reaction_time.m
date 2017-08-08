function rts = get_reaction_time( trials, edfs, vel_thresh )

%   GET_REACTION_TIME -- Calculate and return reaction time.
%
%     rts = ... get_reaction_time( trials, edfs ) uses the start and stop
%     times in `trials` to obtain position and time samples for each trial.
%     The reaction time is the time from `start` at which the x or y
%     velocity for that trial exceeds 50 deg/s.
%
%     rts = ... get_reaction_time( ..., 20 ) uses the criterion 20 deg/s,
%     instead of 50.
%
%     IN:
%       - `trials` (Container) -- Object whose data are an Mx2 matrix of M
%         trials and [start, stop] times.
%       - `edfs` (Container) -- Object whose data are a struct array with
%         the field 'Samples'.
%       - `vel_thresh` (double) |OPTIONAL| -- Velocity threshold.
%     OUT:
%       - `rt` (Container) -- Object whose data are an Mx1 vector of M
%         reaction times for each trial.

if ( nargin < 3 )
  vel_thresh = 50;
end

import jj_analysis.util.assertions.*;

assert__isa( trials, 'Container', 'the trial starts and stops' );
assert__isa( edfs, 'Container', 'the edfs' );

trial_ids = trials( 'identifier' );
edf_ids = edfs( 'identifier' );

assert__strings_present( edf_ids, trial_ids, 'the trial start-stop ids' );

rts = cell( 1, numel(trial_ids) );

for i = 1:numel(trial_ids)
  id = trial_ids{i};
  fprintf( '\n Processing ''%s'' (%d of %d)', id, i, numel(trial_ids) );
  trial = trials.only( id );
  edf = edfs.only( id );
  rts{i} = per_id( trial, edf, id, vel_thresh );
end

rts = extend( rts{:} );

end

function rt = per_id( trials, edf, id, vel_thresh )

%   PER_ID -- Process one trial-edf identifier set.

import jj_analysis.process.*;

assert( shape(edf, 1) == 1, ...
  'More than one edf struct was present for ''%s''.', id );

data = trials.data;

rt = trials;

if ( all(isnan(data(:))) )
  rt.data = nan( size(rt.data, 1), 1 );
  return;
end

[samples, sample_key] = get_samples( edf );
samples = get_samples_by_trial( trials, samples, sample_key );
sample_data = samples.data;

t_ind = strcmp( sample_key, 'time' );
x_ind = strcmp( sample_key, 'posX' );
y_ind = strcmp( sample_key, 'posY' );

rts = nan( numel(sample_data), 1 );

for i = 1:numel(sample_data)
  trial = sample_data{i};
  if ( any(isnan(trial(:))) ), continue; end
  x = trial(:, x_ind);
  y = trial(:, y_ind);
  t = trial(:, t_ind);
  rts(i) = calculate_reaction_time( x, y, t, vel_thresh );
end

rt.data = rts;

end