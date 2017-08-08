function assert__strings_present( arr1, values, var_kind )

%   ASSERT__STRINGS_PRESENT -- Ensure a cell array of strings contains
%     values.
%
%     IN:
%       - `arr1` (cell array of strings)
%       - `values` (cell array of strings, char)
%       - `var_kind` (char) |OPTIONAL| -- Optionally provide a more verbose
%       	variable name in case the assertion fails. Defaults to 'the
%       	input'.

if ( nargin == 2 ), var_kind = 'the input'; end
if ( ~isa(values, 'cell') ), values = { values }; end

jj_analysis.util.assertions.assert__is_cellstr( values );
jj_analysis.util.assertions.assert__is_cellstr( arr1 );

cellfun( @(x) assert(any(strcmp(arr1, x)), ['The required value ''%s''' ...
  , ' is not present in %s.'], x, var_kind), values );
end