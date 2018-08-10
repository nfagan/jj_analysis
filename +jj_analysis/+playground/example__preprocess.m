%%  get paths to mat files, raw edfs, etc.

import jj_analysis.process.*;
import jj_analysis.io.*;
import jj_analysis.process.bounds.*;

conf = jj_analysis.config.load();
raw_edf = conf.PATHS.raw_edf;
processed_edf = conf.PATHS.processed_edf;
raw_mat = conf.PATHS.raw_data;
processed_mat = conf.PATHS.processed_data;

jj_analysis.util.paths.add_depends();

mats = shared_utils.io.dirnames( fullfile(conf.PATHS.data_dir ...
  , 'tarantino_pharm_raw', 'TarantinoOTPharmacology'), '.mat', false );
ids = cellfun( @(x) x(1:end-4), mats, 'un', false );

%%  edf -> mat

edf_to_mat( raw_edf, processed_edf );
raw_to_processed_mat( raw_mat, processed_mat, 'processed.mat' );

%%  load task data

load( fullfile(processed_mat, 'processed.mat') );
load( fullfile(processed_mat, 'key.mat') );

task_evt_key = key;
task_events = processed;

task_events = identify_correction_trials( task_events );
task_events = add_drug_type( task_events );

all_dates = task_events('date');
date_nums = datenum( all_dates );

date0 = datenum( '01-Jan-2018' );
ind = date_nums > date0;

latest_dates = all_dates(ind);

%%  load processed edfs saved as .mat

edfs = get_edfs( processed_edf );

[I, C] = edfs.get_indices( 'identifier' );

copy_cats = { 'date' };

for i = 1:numel(I)
  
  in_evts = task_events.where( C(i, :) );
  
  if ( ~any(in_evts) ), continue; end
  
  one_evts = one( task_events(in_evts) );
  
  for j = 1:numel(copy_cats)
    category = copy_cats{j};
    edfs = edfs.require_fields( category );
    edfs(category, I{i}) = one_evts(category);
  end
end

%%  get trial start times, fix events

eyelink_starts = get_trial_starts( edfs );
[fix_events, fix_evt_key] = get_fix_events( edfs );

no_trial_start =        eyelink_starts.where( 'trial_start__false' );
all_el_ids =            eyelink_starts( 'identifier', : );
no_trial_start_ids =    unique( all_el_ids(no_trial_start) );
has_trial_start_ids =   unique( all_el_ids(~no_trial_start) );

%%  convert matlab time -> eyelink time

%   for now, let's only keep the task_events whose identifiers are also
%   present in the eyelink data we have already processed

mat_ids =     task_events( 'identifier' );
el_ids =      eyelink_starts( 'identifier' );
shared_ids =  intersect( mat_ids, el_ids );

subset = task_events.only( shared_ids );
subset.data(:, 1) = subset.data(:, 2);

present_dates = intersect( subset('date'), latest_dates );

subset = subset(present_dates);

aligned = to_edf_time( subset, eyelink_starts );

%%  get start and stop times for each trial

trials = get_start_stop_events( aligned, 'fixation', 'display_random_vs_info_cues', task_evt_key );
trials.data(:, 1) = trials.data(:, 2) - 1e3;

%%

% pup_vec_length = 1e3;
adjust_start = -200;
adjust_ahead = 1e3;

pup_vec_length = abs( adjust_start ) + abs( adjust_ahead );

trials = get_start_stop_events( aligned, 'fixation', 'display_random_vs_info_cues', task_evt_key );
trials.data(:, 2) = trials.data(:, 2) + adjust_start;
trials.data(:, 1) = trials.data(:, 2) + adjust_ahead;

[I, C] = trials.get_indices( {'identifier', 'date'} );

all_pup = Container();

for i = 1:numel(I)
  pup = jj_analysis.process.get_pupil_trace( trials(I{i}), edfs );
  pup = pup( cellfun(@(x) numel(x) == pup_vec_length + 1, pup.data) );
  all_pup = append( all_pup, pup );
end

all_pup.data = cell2mat( cellfun(@(x) x(:)', all_pup.data, 'un', false) );

%%  get fix events for each trial

pt_events = get_fix_events_per_trial( trials, fix_events, fix_evt_key );

pup = cellfun( @(x) nanmean(x(:, strcmp(fix_evt_key, 'pupilSize'))), pt_events.data );



%%  optionally get samples (takes a long time)

[samples, sample_key] = get_samples( edfs(present_dates) );
samples = get_samples_by_trial( trials, samples, sample_key );

%%  optionally get reaction time

post_display_amt = 500;
vel_thresh = 15;

trials = get_event_by_name( aligned, 'display_info_cues', task_evt_key );
trials.data = [ trials.data, trials.data+post_display_amt ];

rt = get_reaction_time( trials, edfs, vel_thresh );

%%  bound fix events by position

img_rect = get_centered_rect( 400, 1600, 900 ); % img_size, width, height
roi_name = 'image';

[evts, inbounds] = get_fix_events_in_bounds( pt_events, fix_evt_key, img_rect );

evts = evts.require_fields( 'rois' );
evts( 'rois' ) = roi_name;

%%

durations = evts;

start_ind = strcmp( fix_evt_key, 'start' );
end_ind = strcmp( fix_evt_key, 'end' );
durations.data = cellfun( @(x) sum(x(:, end_ind) - x(:, start_ind)), durations.data );

%%  bound fix events by positions -- eyes, mouth

[eye_roi, mouth_roi] = get_eye_mouth_rois( img_rect );

[mouth_evts, mouth_inbounds] = get_fix_events_in_bounds( pt_events, fix_evt_key, mouth_roi);
[eye_evts, eye_inbounds] = get_fix_events_in_bounds( pt_events, fix_evt_key, eye_roi);

eye_evts = eye_evts.require_fields( 'rois' );
eye_evts( 'rois' ) = 'eyes';
mouth_evts = mouth_evts.require_fields( 'rois' );
mouth_evts( 'rois' ) = 'mouth';
