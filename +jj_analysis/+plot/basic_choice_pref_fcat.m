%%  load

conf = jj_analysis.config.load();

pathstr = jj_analysis.util.paths.pathfor( 'raw_data' );
cont = jj_analysis.io.get_trial_info( pathstr );

pl = ContainerPlotter();

datedir = datestr( now, 'mmddyy' );
plot_p = fullfile( fileparts(conf.PATHS.raw_data), 'plots', datedir, 'preference2' );
pharm_p = fullfile( fileparts(conf.PATHS.raw_data), 'tarantino_pharm_raw', 'TarantinoOTPharmacology' );

pharm_mats = shared_utils.io.dirnames( pharm_p, '.mat' );
pharm_mats = pharm_mats( cellfun(@(x) ~strcmp(x(1), '.'), pharm_mats) );
pharm_ids = cellfun( @(x) x(1:8), pharm_mats, 'un', 0 );

%%  only no correction trials

[valid, errs] = jj_analysis.process.exclude_n_plus_one_errors( cont );
valid = valid.only( 'trial_type__choice' );

ind = where( valid, pharm_ids );

valid = add_field( valid, 'pharm', 'pharm__false' );
valid('pharm', ind) = 'pharm__true';

valid = valid({'pharm__false'});

%%

usedat = valid.data;
uselabs = fcat.from( valid.labels );

[blocklabs, I] = keepeach( uselabs', {'date', 'block', 'identifier'} );

plabs = fcat();
pdat = [];

cues = combs( uselabs, 'selected_cue' );

for i = 1:numel(I)
  ind = I{i};
  
  N = numel( ind );
  
  ns = double( count(uselabs, cues, ind) );
  fracs = ns / N * 100;
  
  pdat = [ pdat; fracs ];
  
  for j = 1:numel(cues)
    setcat( blocklabs, 'selected_cue', cues{j}, i );
    append1( plabs, blocklabs, i );
  end
end

%%  reversal

revlabs = plabs';

jj_analysis.process.add_reversal_labels( revlabs );
jj_analysis.process.add_stimuli_set_labels( revlabs );

ephron = 'monkey__Ephron';
tarantino = 'monkey__Tarantino';

%%  plot preference over days

prefix = 'with_bad_social_days';

%   ephron
bad_social_days = { '23-Jul-2018', '24-Jul-2018', '26-Jul-2018' };

bad_tarantino_days = { '16-Nov-2017', '13-Jul-2017', '07-Nov-2017' ...
  , '08-Nov-2017', '09-Nov-2017', '10-Nov-2017' };

pltlabs = revlabs';
pltdat = pdat;

mask = fcat.mask( pltlabs, @find, {ephron, 'social'} ...
  , @findnone, bad_tarantino_days ...
  , @findnone, {} ...
  );

xcats = { 'date' };
gcats = { 'selected_cue' };
pcats = { 'task_type', 'monkey', 'stimuli_set' };
spec = cshorzcat( gcats, pcats );

dates = combs( pltlabs, 'date' );
[~, I] = sort( datenum(dates) );

pl = plotlabeled.make_common();
pl.fig = figure(1);
pl.x_order = dates(I);
pl.y_lims = [0, 100];

axs = pl.errorbar( pltdat(mask), pltlabs(mask), xcats, gcats, pcats );

dsp3.req_savefig( figure(1), plot_p, pltlabs(mask), spec, prefix );

%%  average preference

pltlabs = revlabs';
pltdat = pdat;

prefix = 'with_first_days';

mask = fcat.mask( pltlabs, @find, {ephron, 'social'} ...
  , @findnone, bad_tarantino_days ...
  , @findnone, bad_social_days );

xcats = { 'task_type' };
gcats = { 'selected_cue' };
pcats = { 'reversal', 'monkey' };
spec = cshorzcat( xcats, gcats, pcats );

pl = plotlabeled.make_common();
pl.fig = figure(2);
pl.y_lims = [0, 100];

axs = pl.bar( pltdat(mask), pltlabs(mask), xcats, gcats, pcats );

dsp3.req_savefig( figure(2), plot_p, pltlabs(mask), spec, prefix );

%%  


