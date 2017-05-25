function pathstr = pathfor(identifier)

%   PATHFOR -- Get the path associated with the given identifier.
%
%     IN:
%       - `identifier` (char)
%     OUT:
%       - `pathstr` (char)

import jj_analysis.util.*;

opts = jj_analysis.config.load();
paths = opts.PATHS;
assertions.assert__are_fields( paths, identifier );

pathstr = paths.( identifier );


end