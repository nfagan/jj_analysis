function arr = percell( func, arr )

%   PERCELL -- Alias for `cellfun`, but assumes non-uniform output.
%
%     See also cellfun
%
%     IN:
%       - `func` (function_handle)
%       - `arr` (cell array)
%     OUT:
%       - `arr` (cell array)

arr = cellfun( func, arr, 'un', false );

end