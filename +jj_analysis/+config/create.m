function create()

%   CREATE -- Create the jj_analysis config file.

opts = struct();

% - PATHS - %
PATHS.raw_data = '/Volumes/My Passport/NICK/Chang Lab 2016/jessica/jj_analysis/raw_data';
PATHS.processed_data = '/Volumes/My Passport/NICK/Chang Lab 2016/jessica/jj_analysis/processed_data';

opts.PATHS = PATHS;

jj_analysis.config.save( opts );
jj_analysis.config.save( opts, '-default' );

end