function revlabs = add_reversal_labels(revlabs)

ephron = 'monkey__Ephron';
tarantino = 'monkey__Tarantino';

addcat( revlabs, 'reversal' );

rev_dates = { '27-Jun-2018', '25-May-2017', '28-Nov-2017' };
task_types = { 'juice', 'juice', 'social' };
monks = { ephron, tarantino, tarantino };

for i = 1:numel(rev_dates)

  first_reversal_day = rev_dates{i};
  first_reversal_num = datenum( first_reversal_day );
  
  monk = monks{i};
  task_type = task_types{i};

  mask = fcat.mask( revlabs, @find, {monk, task_type} );
  dates = combs( revlabs, 'date', mask );

  nums = datenum( dates );

  rev_labs = cell( size(dates) );
  rev_labs(nums >= first_reversal_num) = { 'reversal__true' };
  rev_labs(nums < first_reversal_num) = { 'reversal__false' };

  for j = 1:numel(dates)
    ind = find( revlabs, dates{j}, mask );
    setcat( revlabs, 'reversal', rev_labs{j}, ind );
  end
end 

end