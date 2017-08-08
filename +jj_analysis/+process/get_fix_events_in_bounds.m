function [evts, in_bounds] = get_fix_events_in_bounds( events, event_key, bounds, bound_func )

%   GET_FIX_EVENTS_IN_BOUNDS -- Keep fix-events that are within
%     positional bounds.
%
%     events = ... get_fix_events_in_bounds( events, key, bounds, func )
%     retains fix-events that are within the positional `bounds`, using
%     `key` to identify the X and Y columns in `events`, and `func` to
%     determine whether a given fix-event is in bounds. 
%
%     `func` is a function that accepts three inputs: 1) the given
%     `bounds`, 2) `pos`, a two-element (x, y) coordinate for the given
%     fix-event, and 3) `obj`, the Container object housing the full
%     fix-event data and labels for the current fix-event.
%
%     [events, index] = ... also returns the index of fix-events that were
%     in-bounds, with respect to the inputted events object.
%
%     IN:
%       - `events` (Container)
%       - `event_key` (cell array of strings)
%       - `bounds` (double)
%       - `bound_func` (function_handle)
%     OUT:
%       - `evts` (Container)
%       - `in_bounds` (logical)

import jj_analysis.util.assertions.*;

if ( nargin < 4 )
  bound_func = @jj_analysis.process.bounds.rectangle_in_bounds;
end

assert__isa( events, 'Container', 'the fixation events' );
assert__is_cellstr( event_key, 'the event key' );
assert__isa( bounds, 'double', 'the positional bounds' );
assert__isa( bound_func, 'function_handle', 'the bounding function' );
assert( numel(event_key) == size(events.data, 2), ['The given event key' ...
  , ' does not properly correspond to the fixation events matrix.'] );

required_keys = { 'posX', 'posY' };

assert__strings_present( event_key, required_keys, 'the events key' );

x_ind = strcmp( event_key, 'posX' );
y_ind = strcmp( event_key, 'posY' );

data = events.data;

in_bounds = false( size(data, 1), 1 );

parfor i = 1:size(data, 1)
  trial = data(i, :);
  pos = [ trial(x_ind), trial(y_ind) ];
  if ( any(isnan(pos)) ), continue; end
  in_bounds(i) = bound_func( bounds, pos, events(i) );
end

evts = events( in_bounds );

end