conf = jj_analysis.config.load();

addpath( genpath(fullfile(conf.PATHS.repositories, 'eyelink')) );

src = fullfile( conf.PATHS.data_dir, 'tarantino_pharm_raw', 'TarantinoOTPharmacology' );
dest = fullfile( conf.PATHS.data_dir, 'processed_edf' );

jj_analysis.process.edf_to_mat( src, dest );

%%

