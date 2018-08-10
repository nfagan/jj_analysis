function pup = get_pupil_trace( trials, edf )

assert( numel(trials('identifier')) == 1, 'One identifier, only.' );

assert( edf.contains(trials('identifier')), 'Edf file does not match trial identifier.' );

matching_edf = edf( trials('identifier') );

trial_times = trials.data;

edf_data = matching_edf.data;

t = edf_data.Samples.time;
pupil = edf_data.Samples.pupilSize;

pup = cell( size(trial_times, 1), 1 );

for i = 1:size(trial_times, 1)
  
  start = trial_times(i, 1);
  stop = trial_times(i, 2);
  
  if ( isnan(start) || isnan(stop) )
    continue;
  end
  
  [~, ind_start] = min( abs(t - start) );
  [~, ind_stop] = min( abs(t - stop) );
  
  pup{i} = pupil(ind_start:ind_stop);  
end

pup = set_data( trials, pup );

end