function [cont, logical_inds] = exclude_n_plus_one_errors( cont )

%   EXCLUDE_N_PLUS_ONE_ERRORS -- Only retain trials for which there was no
%     correction trial.
%
%     IN:
%       - `cont` (Container)
%     OUT:
%       - `cont` (Container)
%       - `logical_inds` (logical) -- Index of error trials

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

cont = cont.keep( ~logical_inds );

end