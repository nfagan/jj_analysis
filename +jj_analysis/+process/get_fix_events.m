function [events, key] = get_fix_events( edf )

%   GET_FIX_EVENTS -- Get fixation events for each session.
%
%     IN:
%       - `edf` (Container) -- Container whose data are processed .edf
%         structs.
%     OUT:
%       - `events` (Container) -- Container whose data are a
%         matrix of fix-event data.
%       - `key` (cell array of strings) -- Ids that identify each column of
%         `events.

import jj_analysis.util.assertions.*;

assert__isa( edf, 'Container', 'the edf struct Container' );

events = Container();

key = { 'start', 'end', 'duration', 'posX', 'posY', 'pupilSize' };

n_edfs = shape( edf, 1 );

for i = 1:n_edfs
  evt = one_edf( edf(i), key );
  labels = field_label_pairs( edf(i) );
  evt = Container( evt, labels{:} );
  events = events.append( evt );
end

end

function [evt, required_fields] = one_edf(edf, required_fields)

%   ONE_EDF -- Subroutine for processing a single .edf struct.

import jj_analysis.util.assertions.*;

data = edf.data;

assert__are_fields( data, 'Events' );

events = data.Events;

assert__are_fields( events, 'Efix' );

efix = events.Efix;

assert__are_fields( efix, required_fields );

evt = zeros( numel(efix.(required_fields{1})), numel(required_fields) );

for i = 1:numel(required_fields)
  evt(:, i) = efix.(required_fields{i});
end

end