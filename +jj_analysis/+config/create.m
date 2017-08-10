function create()

%   CREATE -- Create the jj_analysis config file.

opts = struct();

% - PATHS - %
data_dir = '/Volumes/My Passport/NICK/Chang Lab 2016/jessica/jj_analysis/';
PATHS.data_dir = data_dir;
PATHS.raw_data = fullfile( data_dir, 'raw_data' );
PATHS.processed_data = fullfile( data_dir, 'processed_data' );
PATHS.raw_edf = fullfile( data_dir, 'raw_edf' );
PATHS.processed_edf = fullfile( data_dir, 'processed_edf' );

opts.PATHS = PATHS;

jj_analysis.config.save( opts );
jj_analysis.config.save( opts, '-default' );

end