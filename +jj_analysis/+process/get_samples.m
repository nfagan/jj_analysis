function [samples, key] = get_samples( edf )

%   GET_SAMPLES -- Get x y position and pupil size.
%
%     IN:
%       - `edf` (Container) -- Container whose data are processed .edf
%         structs.
%     OUT:
%       - `samples` (Container) -- Container whose data are a
%         matrix of x y coordinates and pupil size
%       - `key` (cell array of strings) -- Ids that identify each column of
%         `samples.

import jj_analysis.util.assertions.*;

assert__isa( edf, 'Container', 'the edf struct Container' );

key = { 'posX', 'posY', 'pupilSize', 'time' };

n_edfs = shape( edf, 1 );

samples = cell( n_edfs, 1 );

parfor i = 1:n_edfs
  fprintf( '\n Processing %d of %d', i, n_edfs );
  sample = one_edf( edf(i), key );
  labels = field_label_pairs( edf(i) );
  sample = Container( sample, labels{:} );
  samples{i} = sample;
end

sizes = cellfun( @(x) shape(x, 1), samples );
N = sum( sizes );
new_data = zeros( N, numel(key) );
stp = 1;
labs = SparseLabels();
for i = 1:n_edfs
  sz = sizes(i);
  samp = samples{i};
  new_data( stp:stp+sz-1, : ) = samp.data;
  stp = stp + sz;
  labs = labs.append( samp.labels );
end

samples = Container( new_data, labs );

end

function samp = one_edf(edf, key)

%   ONE_EDF -- Subroutine for processing a single .edf struct.

import jj_analysis.util.assertions.*;

data = edf.data;

assert__are_fields( data, 'Samples' );

samples = data.Samples;

assert__are_fields( samples, key );

samp = zeros( numel(samples.(key{1})), numel(key) );

for i = 1:numel(key)
  samp(:, i) = samples.(key{i});
end

end