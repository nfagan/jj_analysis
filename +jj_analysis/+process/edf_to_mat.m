function edf_to_mat(src, dest, files)

%   EDF_TO_MAT -- Save .edf files as structs in .mat format.
%
%     jj_analysis.process.edf_to_mat('/home/src', '/home/dest') loads .edf
%     files from '/home/src' and saves .mat files in '/home/dest'. Only
%     files which do not already exist in '/home/dest' will be processed.
%
%     ... edf_to_mat('/home/src', '/home/dest', 'new') is equivalent to
%     above.
%
%     ... edf_to_mat('/home/src', '/home/dest', {'file1', 'file2'})
%     processes the .edf files 'file1' and 'file2', regardless of whether
%     they exist in '/home/dest'. However, files must exist in '/home/src'.
%
%     IN:
%       - `src` (char) -- Path to the folder containing .edfs to process.
%       - `dest` (char) -- Path to the folder in which to save .mat files.

import jj_analysis.util.*;

if ( nargin < 3 ), files = 'new'; end
if ( ~iscell(files) ), files = { files }; end

assertions.assert__valid_path( src );
assertions.assert__valid_path( dest );
assertions.assert__is_cellstr( files );

edfs = general.dirstruct( src, '.edf' );

assert( numel(edfs) > 0, 'No .edf files were found in ''%s''.', src );

edfs = { edfs(:).name };
edf_ids = cellfun( @get_identifier, edfs, 'un', false );

if ( strcmp(files, 'new') )
  current = general.dirstruct( dest, '.mat' );
  current = { current(:).name };
  current_ids = cellfun( @get_identifier, current, 'un', false );
  file_ids = setdiff( edf_ids, current_ids );
else
  for i = 1:numel(files)
    fname = files{i};
    if ( ~isempty(strfind(fname, '.')) )
      files{i} = get_identifier( fname );
    end
  end
  assert( isempty(setdiff(files, edf_ids)), ['At least one requested file' ...
    , ' does not exist.'] );
  file_ids = files;
end

files_to_use = cellfun( @(x) fullfile(src, x), file_ids, 'un', false );
nfiles = numel( files_to_use );

if ( nfiles == 0 )
  fprintf( '\n No new data to add ...' ); 
  return;
end

parfor i = 1:nfiles
  fprintf( '\n Processing ''%s'' (%d of %d)', file_ids{i}, i, nfiles );
  fname = [ files_to_use{i}, '.edf' ];
  savename = fullfile( dest, [file_ids{i}, '.mat'] );
  try
    edf = Edf2Mat( fname );
  catch err
    fprintf( '\n Could not load ''%s''.', files_to_use{i} );
    continue;
  end
  save_edf = struct();
  save_edf.Events = edf.Events;
  save_edf.Samples.pupilSize = edf.Samples.pupilSize;
  save_edf.Samples.posX = edf.Samples.posX;
  save_edf.Samples.posY = edf.Samples.posY;
  save_edf.Samples.time = edf.Samples.time;
  save_edf.Identifier = file_ids{i};
  do_save( savename, save_edf );
end

end

function do_save(fname, save_edf)

save( fname, 'save_edf' );

end

function id = get_identifier(fname)

split = strsplit( fname, '.' );
assert( numel(split) == 2, ...
  'Expected filename format to be <filename>.<extension' );
id = split{1};

end