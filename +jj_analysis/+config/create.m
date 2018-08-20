function opts = create(do_save)

%   CREATE -- Create the jj_analysis config file.
%
%     OUT:
%       - `opts` (struct)

if ( nargin < 1 ), do_save = true; end

opts = struct();

% - PATHS - %
data_dir = '/Volumes/My Passport/NICK/Chang Lab 2016/jessica/jj_analysis/';
PATHS.data_dir = data_dir;
PATHS.raw_data = fullfile( data_dir, 'raw_data' );
PATHS.processed_data = fullfile( data_dir, 'processed_data' );
PATHS.raw_edf = fullfile( data_dir, 'raw_edf' );
PATHS.processed_edf = fullfile( data_dir, 'processed_edf' );
PATHS.repositories = '/Volumes/My Passport/NICK/Chang Lab 2016/repositories';

DEPENDENCIES = { 'global' };

opts.PATHS = PATHS;
opts.DEPENDENCIES = DEPENDENCIES;

if ( do_save )
  jj_analysis.config.save( opts );
  jj_analysis.config.save( opts, '-default' );
end

end