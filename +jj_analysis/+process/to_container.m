function trial_info( data, included_fields )

if ( nargin < 2 )
  included_fields = { 'trial_number', 'block_number', 'trial_type' ...
    , 'selected_cue', 'shown_reward_cue', 'reward_type', 'reward_size' ...
    , 'info_location', 'random_location' };
end

jj_analysis.util.assert__isa( data, 'struct', 'the saved-data' );
jj_analysis.util.assert__are_fields( data, {'META', 'DATA'} );

meta = data.META;
data = data.DATA;

jj_analysis.util.assert__are_fields( data, included_fields );

d = 10;






end