%%  get paths to mat files, raw edfs, etc.

pathinit; pathadd global jj_analysis;

import jj_analysis.process.*;
import jj_analysis.io.*;
import jj_analysis.process.bounds.*;

conf = jj_analysis.config.load();
raw_edf = conf.PATHS.raw_edf;
processed_edf = conf.PATHS.processed_edf;
raw_mat = conf.PATHS.raw_data;

%%  edf -> mat

edf_to_mat( raw_edf, processed_edf );

%%  load task data

[task_events, task_evt_key] = get_trial_info( raw_mat );
task_events = identify_correction_trials( task_events );

%%  load processed edfs saved as .mat

edfs = get_edfs( processed_edf );

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

aligned = to_edf_time( subset, eyelink_starts );

% aligned = aligned.rm( '13-Jul-2017' );

% aligned = aligned.rm( 'correction__true' );

%%  get start and stop times for each trial

trials = get_start_stop_events( aligned, 'display_social_image', 'reward', task_evt_key );

%%  get fix events for each trial

per_trial_events = get_fix_events_per_trial( trials, fix_events, fix_evt_key );

%%  optionally get samples (takes a long time)

[samples, sample_key] = get_samples( edfs );
samples = get_samples_by_trial( trials, samples, sample_key );

%%  optionally get reaction time

post_display_amt = 500;
vel_thresh = 15;

trials = get_event_by_name( aligned, 'display_info_cues', task_evt_key );
trials.data = [ trials.data, trials.data+post_display_amt ];

rt = get_reaction_time( trials, edfs, vel_thresh );

%%  bound fix events by position

img_rect = get_centered_rect( 400, 1200, 900 ); % img_size, width, height
roi_name = 'image';

[evts, inbounds] = get_fix_events_in_bounds( per_trial_events, fix_evt_key, img_rect );

evts = evts.require_fields( 'rois' );
evts( 'rois' ) = roi_name;

%%  bound fix events by positions -- eyes, mouth

[eye_roi, mouth_roi] = get_eye_mouth_rois( img_rect );

[mouth_evts, mouth_inbounds] = get_fix_events_in_bounds( per_trial_events, fix_evt_key, mouth_roi);
[eye_evts, eye_inbounds] = get_fix_events_in_bounds( per_trial_events, fix_evt_key, eye_roi);

eye_evts = eye_evts.require_fields( 'rois' );
eye_evts( 'rois' ) = 'eyes';
mouth_evts = mouth_evts.require_fields( 'rois' );
mouth_evts( 'rois' ) = 'mouth';
