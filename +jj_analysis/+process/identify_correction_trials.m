function cont = identify_correction_trials( cont )

%   IDENTIFY_CORRECTION_TRIALS -- Indicate whether a trial is a correction
%     trial.
%
%     IN:
%       - `cont` (Container)
%     OUT:
%       - `cont` (Container)

cont = cont.parfor_each( 'identifier', @per_id );

end

function cont = per_id( cont )

%   PER_ID -- Process one identifier.

no_errs = cont.where( 'no_errors' );
errs = ~no_errs;
inds = find( errs );
nexts = inds + 1;
if ( errs(end) )
  nexts(end) = find( errs, 1, 'last' );
end
nexts = unique( nexts );

logical_inds = false( cont.shape(1), 1 );
logical_inds( inds ) = true;
logical_inds( nexts ) = true;

cont = cont.require_fields( 'correction' );
cont( 'correction', logical_inds ) = 'correction__true';
cont( 'correction', ~logical_inds ) = 'correction__false';

end