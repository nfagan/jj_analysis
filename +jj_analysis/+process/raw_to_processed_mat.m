function raw_to_processed_mat(src, dest, proc_mat_name, files)

%   RAW_TO_PROCESSED_MAT -- Save raw .mat files as one processed .mat file.
%
%     ... raw_to_processed_mat('/home/src', '/home/dest') loads .mat
%     files from '/home/src' and saves a file called 'processed.mat' in
%     '/home/dest'. Only file-ids that do not already exist in
%     'processed.mat' will be processed.
%
%     ... raw_to_processed_mat( ..., 'matname') uses the filename 'matname'
%     instead of 'processed.mat'.
%
%     ... raw_to_processed_mat( ..., {'file1', 'file2'})
%     processes the files 'file1' and 'file2', regardless of whether
%     they exist in the processed file. Existing data will be overwritten.
%
%     ... raw_to_processed_mat( ..., 'all' ) re-processes all raw .mat
%     files and ovewrites the current processed file, if it exists.
%
%     IN:
%       - `src` (char) -- Path to the folder containing .edfs to process.
%       - `dest` (char) -- Path to the folder in which to save .mat files.
%       - `files` (cell array of strings, char) |OPTIONAL|

import jj_analysis.util.general.dirstruct;
import jj_analysis.util.general.percell;
import jj_analysis.util.assertions.*;

if ( nargin < 4 ), files = 'new'; end
if ( nargin < 3 ), proc_mat_name = 'processed.mat'; end
if ( ~iscell(files) ), files = { files }; end

assert__valid_path( src );
assert__valid_path( dest );
assert__is_cellstr( files );

proc_mat_file = fullfile( dest, proc_mat_name );
proc_mat_exists = exist( proc_mat_file, 'file' ) == 2;

raw_mats = dirstruct( src, '.mat' );
raw_ids = percell( @get_identifier, {raw_mats(:).name} );

if ( isempty(raw_mats) )
  fprintf( '\n Warning: ''%s'' had no .mat files ...', src );
  return;
end

processed = Container();

if ( proc_mat_exists )
  load( proc_mat_file );
  current_ids = processed( 'identifier' );
else
  current_ids = {};
end

if ( strcmp(files, 'new') )
  ids_to_process = setdiff( raw_ids, current_ids );
elseif ( strcmp(files, 'all') )
  ids_to_process = raw_ids;
else
  assert__strings_present( raw_mats, files, 'the files to process' );
  ids_to_process = percell( @get_identifier, files );
  processed = processed.remove( ids_to_process );
end

if ( numel(ids_to_process) == 0 )
  fprintf( '\n No new data to add ...\n\n' );
  return;
end

new_processed = cell( 1, numel(ids_to_process) );
keys = cell( size(new_processed) );

parfor i = 1:numel(ids_to_process)
  id = ids_to_process{i};
  src_file = [ id, '.mat' ];
  [new_processed{i}, keys{i}] = jj_analysis.io.get_trial_info( src, src_file );
end

new_processed = extend( new_processed{:} );

processed = processed.append( new_processed );

key = keys{1};

save( fullfile(dest, proc_mat_name), 'processed' );
save( fullfile(dest, 'key.mat'), 'key' );

end

function id = get_identifier(fname)

split = strsplit( fname, '.' );
assert( numel(split) == 2, ...
  'Expected filename format to be <filename>.<extension' );
id = split{1};

end