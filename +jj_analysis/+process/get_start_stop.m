function start_stop = get_start_stop( aligned, offset, duration, evt, key )

%   GET_START_STOP -- Convert event times to a matrix of [start, stop]
%     times.
%
%     out = ... get_start_stop( aligned, 0, 1e3, 'reward', key ) returns
%     `out`, a Container whose data are an Mx2 matrix of M trials and
%     [start, stop] times for each trial. Trial starts are drawn from the
%     column of `aligned` for which strcmp(key, 'reward') is true. Trial
%     starts are adjusted forwards by 0ms, and trial-stops occur 1000ms
%     after each trial start.
%
%     An error is thrown if the number of elements in `key` does not match
%     the number of columns in `aligned`. An error is thrown if the
%     requested `evt` is not found in `key`.
%
%     IN:
%       - `aligned` (Container)
%       - `offset` (double)
%       - `duration` (double)
%       - `evt` (char) -- Name of the target event.
%       - `key` (cell array of strings)
%     OUT:
%       - `start_stop` (Container)

import jj_analysis.util.assertions.*;

assert__isa( aligned, 'Container', 'the aligned event times' );
assert__isa( offset, 'double', 'the offset' );
assert__isa( duration, 'double', 'the duration' );
assert__isa( evt, 'char', 'the event name' );
assert__is_cellstr( key, 'the align events key' );

assert( numel(key) == shape(aligned, 2), ['The provided align events key' ...
  , ' does not match the size of the align events matrix.'] );

evt_ind = strcmp( key, evt );

assert( any(evt_ind), ['The event ''%s'' is not present in the' ...
  , ' events key.'], evt );

data = aligned.data;
subset = data(:, evt_ind) + offset;
subset = [ subset, subset + duration ];

start_stop = aligned;
start_stop.data = subset;

end