function [cont, event_key] = get_trial_info( path, mats )

%   GET_TRIAL_INFO -- Get all trial info from the data files in the given
%     folder.
%
%     IN:
%       - `path` (char)
%       - `mats` (cell array of strings, char) |OPTIONAL| -- .mat files to
%         load. Defaults to loading all .mat files in the given `path`.
%     OUT:
%       - `cont` (Container) -- Trial info.
%       - `event_key` (cell array of strings) -- Ids that identify the
%         columns of `cont`.

import jj_analysis.util.assertions.*;
import jj_analysis.util.general.*;
import jj_analysis.process.*;

if ( nargin == 0 )
  path = jj_analysis.util.paths.pathfor( 'raw_data' );
end

assert__isa( path, 'char', 'the path to the data files' );

if ( nargin < 2 )
  mats = dirstruct( path, '.mat' );
  mats = { mats(:).name };
else
  if ( ~iscell(mats) ), mats = { mats }; end
  assert__is_cellstr( mats, 'the .mat files' );
end

mats = mats( cellfun(@should_include, mats) );

conts = cell( 1, numel(mats) );
keys = cell( 1, numel(mats) );
parfor i = 1:numel(mats)
  fprintf( '\n - Processing %d of %d', i, numel(mats) );
  mat = load( fullfile(path, mats{i}) );
  F = char( fieldnames(mat) );
  mat = mat.(F);
  cont_ = trial_info( mat );
  
  if ( ~isempty(cont_) )
    [events, keys{i}] = trial_events( mat );
    cont_.data = events;
    cont_ = cont_.add_field( 'identifier', get_identifier(mats{i}) );
  end
  
  conts{i} = cont_;
end

cont = extend( conts{:} );
event_key = keys{1};

end

function tf = should_include(fname)
tf = numel( fname ) > 0 && fname(1) ~= '.';
end

function id = get_identifier(fname)

split = strsplit( fname, '.' );
assert( numel(split) == 2, ...
  'Expected filename format to be <filename>.<extension' );
id = split{1};

end