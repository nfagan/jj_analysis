function rebuilt = fix_block(cont)

later_days = cont.rm( 'block_sequence__' );

valid = later_days.only( 'no_errors' );
% choice = valid.only( 'trial_type__choice' );
choice = valid;

c = choice.pcombs( {'date', 'session', 'block'} );

% seq_ids = {};

n_trials = zeros( size(c, 1), 1 );
n_sequence_ids = zeros( size(n_trials) );

for i = 1:size(c, 1)
  
  extr = choice.only( c(i, :) );
  
  date = c{i, 1};
  session = c{i, 2};
  block = c{i, 3};
  
%   extr = choice.only( c(i, :) );
  sequence_ids = extr( 'block_sequence' );
  
  n_trials(i) = shape( extr, 1 );
  n_sequence_ids(i) = numel(sequence_ids);
  
end

ns = [ n_trials, n_sequence_ids ];

%%

C = choice.pcombs( {'date', 'session'} );

last_blocks = cell( size(C, 1), 1 );
for i = 1:size( C, 1)
  extr = choice.only( C(i, :) );
  blocks = extr( 'block' );
  ind = cellfun( @(x) str2double(x(8:end)), blocks );
  [~, ind] = sort( ind );
  
  blocks = blocks( ind );
  last_block = blocks{end};
  last_blocks{i} = last_block;
end

%%  remove the last block in each session from the search

C_ = [ C, last_blocks ];
ind = false( size(c, 1), 1 );

for i = 1:size(c, 1)
  any_matches = false( size(C_, 1), 1 );
  for j = 1:size( C_, 1)
    any_matches(j) = isequal( c(i, :), C_(j, :) );
  end
  ind(i) = any( any_matches );
end

num_inds = find( ind );

sans_last = ns;
sans_last( num_inds, : ) = [];
c( num_inds, : ) = [];

%%

%   for each erroneous block, replace the block number for the subsequent
%   block with the block number of the erroneous block.

missing_one_ind = sans_last(:, 1) == 23;
erroneous_blocks = c( missing_one_ind, : );
subsequent_blocks = erroneous_blocks(:, end);
subsequent_blocks = cellfun( @(x) str2double(x(8:end)), subsequent_blocks );
subsequent_blocks = subsequent_blocks + 1;
subsequent_blocks = arrayfun( @(x) sprintf('block__%d', x), subsequent_blocks, 'un', false );
subsequent_blocks = [ erroneous_blocks(:, 1:2), subsequent_blocks ];

rebuilt = Container();

for i = 1:size(erroneous_blocks, 1)
  first = cont.only( erroneous_blocks(i, :) );
  next = cont.only( subsequent_blocks(i, :) );
  assert( ~isempty(first) && ~isempty(next) );
  last_trial = first( first.shape(1) );
  last_id = last_trial( 'block_sequence' );
  j = 1;
  should_change = true;
  rest = Container();
  while ( should_change )
    extr = next(j);
    next_id = extr( 'block_sequence' );
    error_type = char( extr('errors') );
    if ( strcmp(error_type, 'no_errors') )
      should_change_next = false;
    else
      should_change_next = true;
    end
    if ( j == 1 )
      assert( isequal(last_id, next_id), 'Ids were not equal' );
    else
      if ( isequal(last_id, next_id) )
        should_change = true;
      else
        should_change = false;
      end
    end
    if ( ~should_change )
      break;
    end
    extr('block') = char( first('block') );
    rest = rest.append( extr );
    j = j + 1;
    if ( ~should_change_next )
      break;
    end
  end
  rest = rest.append( next(j:next.shape(1)) );
  rebuilt = rebuilt.extend( first, rest );
end

cont_ = cont;

for i = 1:size(erroneous_blocks, 1)
  ind = cont_.where( erroneous_blocks(i, :) ) | ...
    cont_.where( subsequent_blocks(i, :) );
  cont_ = cont_.keep( ~ind );
end

rebuilt = rebuilt.append( cont_ );


end
