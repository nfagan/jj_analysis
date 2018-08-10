conf = jj_analysis.config.load();

mats = { '02_26KuA.mat', '02_21KuA.mat' };

info = jj_analysis.io.get_trial_info( conf.PATHS.raw_data, mats );

%%

[valid, errs] = jj_analysis.process.exclude_n_plus_one_errors( info );

%%

check_side_bias_cont = valid;

pref_each = { 'date', 'block', 'selected_cue' };

[I, C] = check_side_bias_cont.get_indices( pref_each );

side_bias = Container();

for i = 1:numel(I)
  subset_check_side_bias = check_side_bias_cont(I{i});
  
  n_left = sum( subset_check_side_bias.where('selected_location__center-left') );
  n_right = sum( subset_check_side_bias.where('selected_location__center-right') );
  
  index = (n_left - n_right) / (n_left + n_right);
  
  one_subset_check_side_bias = one( subset_check_side_bias );
  one_subset_check_side_bias.data = index;
  
  side_bias = append( side_bias, one_subset_check_side_bias );
end

%%

pl = ContainerPlotter();

f = figure(1);
clf( f );

x_is = 'date';
groups_are = { 'date' };
panels_are = { 'selected_cue' };

pl.y_lim = [-1, 1];
pl.y_label = 'Preference for left over right';

axs = pl.bar( side_bias, x_is, groups_are, panels_are );

set( axs, 'nextplot', 'add' );

for i = 1:numel(axs)
  xs = get( gca, 'xlim' );
  ys = repmat( 0.5, size(xs) );
  plot( axs(i), xs, ys, 'k--' );
end



