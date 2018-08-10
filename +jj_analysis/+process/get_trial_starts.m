function trial_starts = get_trial_starts( edf )

%   GET_TRIAL_STARTS -- Get start times for each trial.
%
%     IN:
%       - `edf` (Container) -- Container whose data are processed .edf
%         structs.
%     OUT:
%       - `trial_starts` (Container) -- Container whose data are a
%         column-vector of start times.

import jj_analysis.util.assertions.*;

assert__isa( edf, 'Container', 'the edf struct Container' );

trial_starts = Container();

n_edfs = shape( edf, 1 );

for i = 1:n_edfs
  [start, trial_ids, has_trial_start] = one_edf( edf(i) );
  labels = field_label_pairs( edf(i) );
  labels = [ labels, {'trial', trial_ids}, 'trial_start', has_trial_start ];
  start = Container( start, labels{:} );
  trial_starts = trial_starts.append( start );
end

end

function [trial_starts, trial_ids, has_trial_start] = one_edf(edf)

%   ONE_EDF -- Subroutine for processing a single .edf struct.

import jj_analysis.util.assertions.*;

data = edf.data;

id = char( edf('identifier') );

assert__are_fields( data, 'Events' );

events = data.Events;

assert__are_fields( events, 'Messages' );

messages = events.Messages;
time = messages.time;
info = messages.info;
trial_inds = cellfun( @(x) ~isempty(strfind(x, 'TRIAL__')), info );

try
  assert( any(trial_inds), 'No trial identifiers were found for ''%s''.', id );
catch err
  fprintf( '\n %s', err.message );
  trial_starts = NaN;
  trial_ids = 'trial__NaN';
  has_trial_start = 'trial_start__false';
  return
end

trial_messages = info( trial_inds );

%   validate -- make sure messages are formatted correctly.

n_trial = numel( 'TRIAL__' );

n_chars = cellfun( @numel, trial_messages );
assert( all(n_chars >= n_trial+1), 'Some trials were missing trial numbers.' );

ns = cellfun( @(x) str2double(x(n_trial+1:end)), trial_messages );

assert( all(diff(ns) == 1), 'Some trials were not monotonically increasing.' );
assert( ns(1) == 1, ['Expected the first trial to have an id of 1, but it' ...
  , ' was %d.'], ns(1) );

trial_starts = time( trial_inds );
trial_starts = trial_starts(:);
trial_ids = lower( trial_messages(:) );

has_trial_start = 'trial_start__true';

end