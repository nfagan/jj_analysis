function [mat, event_names] = trial_events(data)

%   TRIAL_EVENTS -- Get event times for each trial.
%
%     IN:
%       - `data` (struct) -- Data file with DATA fields.
%     OUT:
%       - `mat` (double) -- Matrix of M trials by N event times.
%       - `event_names` (cell array of strings) -- Ids that identify the
%         columns of `mat`.

import jj_analysis.util.assertions.*;
assert__isa( data, 'struct', 'the saved-data' );
assert__are_fields( data, {'DATA'} );

data = data.DATA;

event_names = { 'trial_start', 'fixation', 'display_random_vs_info_cues' ...
  , 'look_to_random_vs_info', 'display_info_cues', 'display_social_image', 'reward' };

mat = nan( numel(data), numel(event_names) );

for i = 1:numel(data)
  
  current = data(i);
  evts = current.events;
  trial_evts = zeros( 1, numel(event_names) );
  
  for j = 1:numel(event_names)
    if ( ~isfield(evts, event_names{j}) ), continue; end
    trial_evts(j) = evts.(event_names{j});
  end
  
  mat(i, :) = trial_evts;
end


end

