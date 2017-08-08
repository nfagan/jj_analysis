function evts = get_fix_events_per_trial( when, fevents, key )

%   GET_FIX_EVENTS_PER_TRIAL -- Transform fix events such that they are 
%     w/r/t the event times of each trial.
%
%     evts = ... get_fix_events_per_trial( when, fevents, key ) outputs
%     `evts`, a Container whose data are an MxN matrix of M fixation-events
%     by N fixation-event data fields (e.g., duration, pupil size). Each
%     row of `evts` contains a trial label that identifies it as having
%     occurred during that trial. `when` is a Container whose data are an 
%     Mx2 matrix of M trials by 2 event times (start and stop). `fevents` 
%     is a Container whose data are an MxN matrix of M fixation-events by 
%     N fixation-event data fields.
%
%     Fix events are matched to trial start times by their respective
%     'identifier' labels. If a given identifier in `when` does not exist
%     in `fevents`, an error is thrown.
%
%     IN:
%       - `when` (Container) -- Start and stop times.
%       - `fevents` (Container) -- Fixation events.
%       - `key` (cell array of strings) -- Ids that identify the columns in
%         `fevents`.
%     OUT:
%       - `evts` (Container)

import jj_analysis.util.assertions.*;

assert__isa( when, 'Container', 'the trial start and end times' );
assert__isa( fevents, 'Container', 'the fixation events' );

assert( size(when.data, 2) == 2, ['Expected the data in input 1 to have' ...
  , ' two columns; instead %d were present.'], size(when.data, 2) );

required_keys = { 'start', 'end', 'duration' };

assert__strings_present( key, required_keys );

evts = when.parfor_each( 'identifier', @one_identifier, fevents, key );

end

function evts = one_identifier(when, fevents, key)

%   ONE_IDENTIFIER -- Get per-trial fix events for one id.

ids = when( 'identifier' );

assert( all(fevents.contains(ids)), ['The identifier(s) ''%s''' ...
  , ' is/are not present in the given fix events Container.'] ...
  , strjoin(ids, ', ') );

event = fevents.only( ids );
event = event.data;

trials = when.data;

start_col_ind =   strcmp( key, 'start' );
stop_col_ind =    strcmp( key, 'end' );
dur_col_ind =     strcmp( key, 'duration' );

if ( all(isnan(trials)) )
  evts = when;
  evts.data = nan( shape(evts, 1), size(event, 2) );
  return;
end

starts = event(:, start_col_ind);

evts = Container();

for i = 1:size(trials, 1)  
  evt = when(i);
  evt.data = nan( 1, size(event, 2) );
  
  if ( any(isnan(trials(i, :))) )
    evts = evts.append( evt );
    continue; 
  end
  
  start = trials(i, 1);
  stop = trials(i, 2);
  
  after_start = starts >= start & starts < stop;
  
  if ( ~any(after_start) )
    evts = evts.append( evt );
    continue; 
  end
  
  subset = event( after_start, : );
  last_stop = subset( end, stop_col_ind );
  last_start = subset( end, start_col_ind );
  
  if ( last_stop > stop )
    subset( end, stop_col_ind ) = stop;
    subset( end, dur_col_ind ) = stop - last_start;
  end
  
  labs = evt.field_label_pairs();
  
  evt = Container( subset, labs{:} );
  evts = evts.append( evt );  
end

fprintf( '\n %s Done.', strjoin(ids, '_') );

end