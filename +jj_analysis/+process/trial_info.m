function cont = trial_info( data )

%   TRIAL_INFO -- Extract basic trial info from a data file.
%
%     IN:
%       - `data` (struct) -- Data file with META and DATA fields.
%     OUT:
%       - `cont` (Container) -- Container object.

import jj_analysis.util.assertions.*;
assert__isa( data, 'struct', 'the saved-data' );
assert__are_fields( data, {'META', 'DATA'} );

meta = data.META;
data = data.DATA;

data_fields = { 'trial_number', 'block_number', 'trial_type' ...
  , 'selected_cue', 'shown_reward_cue', 'reward_type', 'reward_size' ...
  , 'info_location', 'random_location', 'errors' };
assert__are_fields( data, data_fields );

meta_fields = fieldnames( meta );

cont = Container();

for i = 1:numel(data)
  current = data(i);
  labs = struct();
  labs.trial =              [ 'trial__' num2str(current.trial_number) ];
  labs.block =              [ 'block__' num2str(current.block_number) ];
  labs.trial_type =         [ 'trial_type__' current.trial_type ];
  labs.selected_cue =       [ 'selected_cue__' current.selected_cue ];
  labs.shown_reward_cue =   [ 'shown_reward_cue__' current.shown_reward_cue ];
  labs.reward_type =        [ current.reward_type ];
  labs.reward_size =        [ 'reward_size__' num2str(current.reward_size) ];
  labs.info_location =      [ 'info_location__' current.info_location ];
  labs.random_location =    [ 'random_location__' current.random_location ];
  
  %   selected cue location
  selected_type = current.selected_cue;
  if ( ~isempty(selected_type) )
    selected_location = current.([selected_type '_location']);
  else
    selected_location = '';
  end
  labs.selected_location = [ 'selected_location__' selected_location ];
  
  if ( current.errors.broke_choice )
    labs.errors = 'broke_choice';
  elseif ( current.errors.no_choice )
    labs.errors = 'no_choice';
  elseif ( current.errors.broke_fixation )
    labs.errors = 'broke_fix';
  elseif ( current.errors.no_fixation )
    labs.errors = 'no_fix';
  else
    labs.errors = 'no_errors';
  end
  
  labs = structfun( @(x) {x}, labs, 'un', false );
  
  current_cont = Container( 1, labs );
  
  cont = cont.append( current_cont );  
end

for i = 1:numel(meta_fields)
  F = meta_fields{i};
  val = meta.(F);
  if ( ~isequal(F, 'date') )
    cont = cont.add_field( F, [F, '__', val] );
  else
    val = datestr( val );
    cont = cont.add_field( F, val );
  end
end

cont = cont.sparse();

end