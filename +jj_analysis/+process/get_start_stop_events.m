function start_stop = get_start_stop_events( aligned, evt1, evt2, key )

%   GET_START_STOP_EVENTS -- Convert event times to a matrix of 
%     [start, stop] times.
%
%     out = ... get_start_stop_events( aligned, 'fixation', 'reward', key )
%     returns `out`, a Container whose data are an Mx2 matrix of M trials
%     and [start, stop] times for each trial. Trial starts are drawn from
%     column of `aligned` for which strcmp(key, 'fixation') is true.
%     Trial-stops are drawn from the column of `aligned` for which
%     strcmp(key, 'reward') is true.
%
%     An error is thrown if the number of elements in `key` does not match
%     the number of columns in `aligned`. An error is thrown if the
%     requested events are not found in `key`.
%
%     IN:
%       - `aligned` (Container)
%       - `evt1` (char) -- Start event.
%       - `evt2` (char) -- Stop event.
%       - `key` (cell array of strings)
%     OUT:
%       - `start_stop` (Container)

import jj_analysis.util.assertions.*;

assert__isa( aligned, 'Container', 'the aligned event times' );
assert__isa( evt1, 'char', 'the start event' );
assert__isa( evt2, 'char', 'the stop event' );
assert__is_cellstr( key, 'the align events key' );

assert( numel(key) == shape(aligned, 2), ['The provided align events key' ...
  , ' does not match the size of the align events matrix.'] );

start_ind = strcmp( key, evt1 );
stop_ind = strcmp( key, evt2 );

msg_not_present = 'The event ''%s'' is not present in the events key.';

assert( any(start_ind), msg_not_present, evt1 );
assert( any(stop_ind), msg_not_present, evt2 );

data = aligned.data;

starts = data(:, start_ind);
stops = data(:, stop_ind);

start_stop = aligned;
start_stop.data = [ starts, stops ];

end