function [cont, event_key] = get_trial_info( path )

%   GET_TRIAL_INFO -- Get all trial info from the data files in the given
%     folder.
%
%     IN:
%       - `path` (char)
%     OUT:
%       - `cont` (Container) -- Trial info.
%       - `event_key` (cell array of strings) -- Ids that identify the
%         columns of `cont`.

import jj_analysis.util.assertions.*;
import jj_analysis.util.general.*;
import jj_analysis.process.*;

assert__isa( path, 'char', 'the path to the data files' );
mats = dirstruct( path, '.mat' );
conts = cell( 1, numel(mats) );
keys = cell( 1, numel(mats) );
parfor i = 1:numel(mats)
  fprintf( '\n - Processing %d of %d', i, numel(mats) );
  mat = load( fullfile(path, mats(i).name) );
  F = char( fieldnames(mat) );
  mat = mat.(F);
  cont_ = trial_info( mat );
  [events, keys{i}] = trial_events( mat );
  cont_.data = events;
  cont_ = cont_.add_field( 'identifier', get_identifier(mats(i).name) );
  conts{i} = cont_;
end

cont = extend( conts{:} );
event_key = keys{1};

end

function id = get_identifier(fname)

split = strsplit( fname, '.' );
assert( numel(split) == 2, ...
  'Expected filename format to be <filename>.<extension' );
id = split{1};

end