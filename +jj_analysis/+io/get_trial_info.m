function cont = get_trial_info( path )

%   GET_TRIAL_INFO -- Get all trial info from the data files in the given
%     folder.
%
%     IN:
%       - `path` (char)
%     OUT:
%       - `cont` (Container) -- Trial info.

import jj_analysis.util.assertions.*;
import jj_analysis.util.general.*;
import jj_analysis.process.*;

if ( nargin == 0 )
  path = jj_analysis.util.paths.pathfor( 'raw_data' );
end

assert__isa( path, 'char', 'the path to the data files' );
mats = dirstruct( path, '.mat' );
cont = Container();
for i = 1:numel(mats)
  fprintf( '\n - Processing %d of %d', i, numel(mats) );
  mat = load( fullfile(path, mats(i).name) );
  F = char( fieldnames(mat) );
  mat = mat.(F);
  cont_ = trial_info( mat );
  cont = cont.append( cont_ );
end

end