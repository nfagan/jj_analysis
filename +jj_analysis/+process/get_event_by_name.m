function evts = get_event_by_name( aligned, name, key )

%   GET_EVENT_BY_NAME -- Return a single column of event times.
%
%     IN:
%       - `aligned` (Container)
%       - `name` (char)
%       - `key` (cell array of strings)
%     OUT:
%       - `evts` (Container)

import jj_analysis.util.assertions.*;

assert__isa( aligned, 'Container', 'the aligned events' );
assert__isa( name, 'char', 'the event name' );
assert__is_cellstr( key, 'the events key' );

assert( numel(key) == size(aligned.data, 2), ['The given key does' ...
  , ' not properly correspond to the events matrix.'] );

ind = strcmp( key, name );

assert( any(ind), 'The event ''%s'' does not exist in the given key', name );

evts = aligned;
evts.data = evts.data(:, ind);

end