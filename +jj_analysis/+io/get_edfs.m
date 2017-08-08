function cont = get_edfs( path )

%   GET_EDFS -- Get all processed .edf files.
%
%     IN:
%       - `path` (char)
%     OUT:
%       - `cont` (Container)

import jj_analysis.util.assertions.*;
import jj_analysis.util.general.*;
import jj_analysis.process.*;

assert__valid_path( path );
mats = dirstruct( path, '.mat' );
conts = cell( 1, numel(mats) );

parfor i = 1:numel(mats)
  fprintf( '\n - Processing %d of %d', i, numel(mats) );
  mat = load( fullfile(path, mats(i).name) );
  F = char( fieldnames(mat) );
  mat = mat.(F);
  cont_ = Container( mat, 'identifier', get_identifier(mats(i).name) );
  conts{i} = cont_;
end

cont = extend( conts{:} );

end

function id = get_identifier(fname)

split = strsplit( fname, '.' );
assert( numel(split) == 2, ...
  'Expected filename format to be <filename>.<extension' );
id = split{1};

end