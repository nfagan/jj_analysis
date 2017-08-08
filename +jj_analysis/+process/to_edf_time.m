function mat = to_edf_time(mat, starts)

%   TO_EDF_TIME -- Convert task events in Matlab time to Eyelink time.
%
%     This function requires that each 'identifier' in the Matlab object is
%     also present in the Eyelink trial starts object. Otherwise, an error
%     is thrown.
%
%     IN:
%       - `mat` (Container) -- Matlab task times.
%       - `starts` (Container) -- Eyelink trial start times.
%     OUT:
%       - `mat` (Container) -- Adjusted event times.

import jj_analysis.util.assertions.*;

assert__isa( mat, 'Container', 'the matlab event times' );
assert__isa( starts, 'Container', 'the eyelink trial start times' );

mat = mat.for_each( 'identifier', @one_identifier, starts );

end

function mat = one_identifier(mat, starts)

%   ONE_IDENTIFIER -- Align to Eyelink time for one id.

ids = mat( 'identifier' );

assert( all(starts.contains(ids)), ['The identifier(s) ''%s''' ...
  , ' is/are not present in the given .edf trial start times Container.'] ...
  , strjoin(ids, ', ') );

subset = starts.only( ids );

if ( all(isnan(subset.data)) )
  mat.data = nan( size(mat.data) );
  return;
end

data = mat.data;

N = size( data, 1 );

n_subset = shape( subset, 1 );

if ( n_subset - N == 1 )
  subset = subset(1:end-1);
else
  assert( N == n_subset, ['More than 1 (%d) trial difference between' ...
    , ' Eyelink and Matlab time.'] );
end

mat_trials = mat( 'trial', : );
subset_trials = subset( 'trial', : );

assert( isequal(mat_trials, subset_trials), ['Task trial ids' ...
  , ' do not propertly correspond to Eyelink trial ids for ''%s''.'] ...
  , strjoin(ids, ', ') );

first = data(:, 1);

for i = 1:size(data, 2)
  offset = (data(:, i) - first) .* 1e3;
  offset = offset + subset.data;
  data(:, i) = offset;
end

mat.data = data;

end