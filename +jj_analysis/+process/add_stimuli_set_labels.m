function revlabs = add_stimuli_set_labels(revlabs)

tarantino = 'monkey__Tarantino';

addcat( revlabs, 'stimuli_set' );

rev_dates = { '05-Dec-2017' };
task_types = { 'social' };
monks = { tarantino };
setlabs = { 'stimuli_set_B' };

for i = 1:numel(rev_dates)

  first_reversal_day = rev_dates{i};
  first_reversal_num = datenum( first_reversal_day );
  
  monk = monks{i};
  task_type = task_types{i};

  mask = fcat.mask( revlabs, @find, {monk, task_type} );
  dates = combs( revlabs, 'date', mask );

  nums = datenum( dates );
  
  post_date_ind = find( nums >= first_reversal_num );
  n_post = numel( post_date_ind );
  
  for j = 1:n_post
    ind = find( revlabs, dates{post_date_ind(j)}, mask );
    setcat( revlabs, 'stimuli_set', setlabs{i}, ind );
  end
end 

end