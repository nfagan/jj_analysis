function obj = fill_missing(obj, fs, C, with)

%   FILL_MISSING -- Fill in missing values associated with the labels in
%     `C` with a given value.
%
%     If data associated with a row of `C` exists, it will not be
%     overwritten.
%
%     IN:
%       - `obj` (Container)
%       - `fs` (cell array of strings, char) -- Fields identifying columns
%         of `C`.
%       - `C` (cell array of strings) -- Combinations of labels to fill in.
%     OUT:
%       - `obj` (Container)

if ( nargin < 4 ), with = 0; end

obj.assert__contains_fields( fs );
Assertions.assert__is_cellstr( C );
assert( numel(fields) == size(C, 2), ['The number of fields' ...
  , ' must match the number of columns of labels. Expected labels' ...
  , ' to have %d columns; %d were present.'], numel(fields) ...
  , size(C, 2) );

collapsed = obj.collapse_non_uniform();

for i = 1:size(C, 1)
  row = C(i, :);
  ind = obj.where( row );
  if ( any(ind) ), continue; end;
  extr = collapsed(1);
  extr.data = with;
  obj = obj.append( extr );
end

end