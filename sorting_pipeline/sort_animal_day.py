#!/usr/bin/env python

# prerequisites:
# pip install spikeforest
# pip install ml_ms4alg
# conda install -c flatiron mountainlab ml_ms3
# caution: do not install ml_ms4alg from conda package - it conflicts with the pypi version

import argparse
# Spike sorting of one animal-day
import os
import shutil

import numpy as np

import ml_ms4alg
import mlprocessors as mlpr
import spikeextractors as se
import spikeforest as sf
from label_map import apply_label_map, create_label_map
from misc_utils import TemporaryDirectory, mkdir2, read_geom_csv
from shellscript import ShellScript


def main():
    # command-line arguments
    parser = argparse.ArgumentParser(
        description="Franklab spike sorting for a single animal day")
    parser.add_argument(
        '--input', help='The input directory containing the animal day ephys data', )
    parser.add_argument(
        '--output', help='The output directory where the sorting results will be written')
    parser.add_argument(
        '--num_jobs', help='Number of parallel jobs', required=False, default=1)
    parser.add_argument(
        '--force_run', help='Force the processing to run (no cache)', action='store_true')
    parser.add_argument(
        '--test', help='Only run 2 epochs and 2 ntrodes in each', action='store_true')
    args = parser.parse_args()

    animal_day_path = args.input
    animal_day_output_path = args.output

    # parse the epoch names from the input directory
    epoch_names = [name for name in sorted(
        os.listdir(animal_day_path)) if name.endswith('.mda')]
    if args.test:
        # if we are testing, we only keep two of these
        epoch_names = epoch_names[0:2]
    # call load_epoch for each epoch name
    epochs = [
        load_epoch(animal_day_path + '/' + name,
                   name=name[0:-4], test=args.test)
        for name in epoch_names
    ]

    # make the output directory if it doesn't already exist
    mkdir2(animal_day_output_path)

    # report the number of parallel jobs we will be using
    print('Num parallel jobs: {}'.format(args.num_jobs))

    # Start the job queue
    job_handler = mlpr.ParallelJobHandler(int(args.num_jobs))
    with mlpr.JobQueue(job_handler=job_handler) as JQ:
        # loop through the epochs
        for epoch in epochs:
            print('PROCESSING EPOCH: {}'.format(epoch['path']))
            # make the output directory for the epoch (if doesn't exist)
            mkdir2(animal_day_output_path + '/' + epoch['name'])
            # loop through the ntrodes within the epoch
            for ntrode in epoch['ntrodes']:
                print('PROCESSING NTRODE: {}'.format(ntrode['path']))
                # make the output directory for the ntrode (if doesn't exist)
                mkdir2(animal_day_output_path + '/' +
                       epoch['name'] + '/' + ntrode['name'])
                # define the names of the output files
                firings_out = animal_day_output_path + '/' + \
                    epoch['name'] + '/' + ntrode['name'] + '/firings.mda'
                metrics_out = animal_day_output_path + '/' + \
                    epoch['name'] + '/' + ntrode['name'] + '/metrics.json'
                firings_curated_out = animal_day_output_path + '/' + \
                    epoch['name'] + '/' + ntrode['name'] + \
                    '/firings_curated.mda'
                # grab the input file name that was parsed earlier
                recording_file_in = ntrode['recording_file']
                geom_in = ntrode['geom_file']

                print('Sorting...')
                spike_sorting(
                    recording_file_in=recording_file_in,
                    geom_in=geom_in,
                    firings_out=firings_out,
                    metrics_out=metrics_out,
                    firings_curated_out=firings_curated_out,
                    args=args  # these are the command-line arguments
                )
        JQ.wait()


def load_ntrode(path, *, name):
    # use the .geom.csv if it exists (we assume path ends with .mda)
    geom_file = path[0:-4] + '.geom.csv'
    if os.path.exists(geom_file):
        print('Using geometry file: {}'.format(geom_file))
    else:
        # if doesn't exist, we will create a trivial geom later
        geom_file = None

    # here's the structure for representing ntrode information
    return dict(
        name=name,
        path=path,
        recording_file=path,
        geom_file=geom_file
    )


def load_epoch(path, *, name, test=False):
    # read the ntrode names
    ntrode_names = [name for name in sorted(
        os.listdir(path)) if name.endswith('.mda')]
    if test:
        # if we are testing, we only use the first 2
        ntrode_names = ntrode_names[0:2]
    # load each of the ntrodes
    ntrodes = [
        load_ntrode(path + '/' + name2, name=name2[0:-4])
        for name2 in ntrode_names
    ]
    # here's the data representing the epoch
    return dict(
        path=path,
        name=name,
        ntrodes=ntrodes
    )

# This is a mountaintools processor


class CustomSorting(mlpr.Processor):
    NAME = 'CustomSorting'
    VERSION = '0.1.7'  # the version can be incremented when the code inside run() changes

    # input files
    recording_file_in = mlpr.Input('Path to raw.mda')
    geom_in = mlpr.Input('Path to geom.csv', optional=True)

    # output files
    firings_out = mlpr.Output('Output firings.mda file')
    firings_curated_out = mlpr.Output('Output firings.curated.mda file')
    metrics_out = mlpr.Output('Metrics .json output')

    # parameters
    samplerate = mlpr.FloatParameter("Sampling frequency")

    mask_out_artifacts = mlpr.BoolParameter(optional=True, default=False,
                                            description='Whether to mask out artifacts')
    freq_min = mlpr.FloatParameter(
        optional=True, default=600, description='Use 0 for no bandpass filtering')
    freq_max = mlpr.FloatParameter(
        optional=True, default=3000, description='Use 0 for no bandpass filtering')
    whiten = mlpr.BoolParameter(optional=True, default=True,
                                description='Whether to do channel whitening as part of preprocessing')
    detect_sign = mlpr.IntegerParameter(
        'Use -1, 0, or 1, depending on the sign of the spikes in the recording')
    adjacency_radius = mlpr.FloatParameter(
        'Use -1 to include all channels in every neighborhood')
    clip_size = mlpr.IntegerParameter(
        optional=True, default=50, description='')
    detect_threshold = mlpr.FloatParameter(
        optional=True, default=5, description='')
    detect_interval = mlpr.IntegerParameter(
        optional=True, default=10, description='Minimum number of timepoints between events detected on the same channel')
    noise_overlap_threshold = mlpr.FloatParameter(
        optional=True, default=0.15, description='Use None for no automated curation')

    def run(self):
        # This temporary file will automatically be removed even in the case of a python exception
        with TemporaryDirectory() as tmpdir:
            # names of files for the temporary/intermediate data
            filt = tmpdir + '/filt.mda'
            filt2 = tmpdir + '/filt2.mda'
            pre = tmpdir + '/pre.mda'

            print('Bandpass filtering raw -> filt...')
            _bandpass_filter(self.recording_file_in, filt)

            if self.mask_out_artifacts:
                print('Masking out artifacts filt -> filt2...')
                _mask_out_artifacts(filt, filt2)
            else:
                print('Copying filt -> filt2...')
                filt2 = filt

            if self.whiten:
                print('Whitening filt2 -> pre...')
                _whiten(filt2, pre)
            else:
                pre = filt2

            # read the preprocessed timeseries into RAM (maybe we'll do it differently later)
            X = sf.mdaio.readmda(pre)

            # handle the geom
            if type(self.geom_in) == str:
                print('Using geom.csv from a file', self.geom_in)
                geom = read_geom_csv(self.geom_in)
            else:
                # no geom file was provided as input
                num_channels = X.shape[0]
                if num_channels > 6:
                    raise Exception(
                        'For more than six channels, we require that a geom.csv be provided')
                # otherwise make a trivial geometry file
                print('Making a trivial geom file.')
                geom = np.zeros((X.shape[0], 2))

            # Now represent the preprocessed recording using a RecordingExtractor
            recording = se.NumpyRecordingExtractor(
                X, samplerate=30303, geom=geom)

            # hard-code this for now -- idea: run many simultaneous jobs, each using only 2 cores
            # important to set certain environment variables in the .sh script that calls this .py script
            num_workers = 2

            # Call MountainSort4
            sorting = ml_ms4alg.mountainsort4(
                recording=recording,
                detect_sign=self.detect_sign,
                adjacency_radius=self.adjacency_radius,
                clip_size=self.clip_size,
                detect_threshold=self.detect_threshold,
                detect_interval=self.detect_interval,
                num_workers=num_workers,
            )

            # Write the firings.mda
            print('Writing firings.mda...')
            sf.SFMdaSortingExtractor.write_sorting(
                sorting=sorting, save_path=self.firings_out)

            # not sure why this is not working
            # I was trying to use spikeforestsorters so that we could swap other sorters in
            # but ran into some unexpected problems
            # result = sorters.MountainSort4.execute(
            #     recording_dir=recording_dir,
            #     firings_out=self.firings_out,
            #     detect_sign=self.detect_sign,
            #     adjacency_radius=self.adjacency_radius,
            #     clip_size=self.clip_size,
            #     detect_threshold=self.detect_threshold,
            #     detect_interval=self.detect_interval,
            #     num_workers=num_workers,
            #     _use_cache=False
            # )

            print('Computing cluster metrics...')
            cluster_metrics_path = tmpdir + '/cluster_metrics.json'
            _cluster_metrics(pre, self.firings_out, cluster_metrics_path)

            print('Computing isolation metrics...')
            isolation_metrics_path = tmpdir + '/isolation_metrics.json'
            pair_metrics_path = tmpdir + '/pair_metrics.json'
            _isolation_metrics(pre, self.firings_out,
                               isolation_metrics_path, pair_metrics_path)

            print('Combining metrics...')
            metrics_path = tmpdir + '/metrics.json'
            _combine_metrics(cluster_metrics_path,
                             isolation_metrics_path, metrics_path)

            # copy metrics.json to the output location
            shutil.copy(metrics_path, self.metrics_out)

            print('Creating label map...')
            label_map_path = tmpdir + '/label_map.mda'
            create_label_map(metrics=metrics_path,
                             label_map_out=label_map_path)

            print('Applying label map...')
            apply_label_map(firings=self.firings_out, label_map=label_map_path,
                            firings_out=self.firings_curated_out)


def spike_sorting(*, recording_file_in, geom_in, firings_out, metrics_out, firings_curated_out, args):
    params = dict(
        recording_file_in=recording_file_in,
        firings_out=firings_out,
        metrics_out=metrics_out,
        firings_curated_out=firings_curated_out,
        mask_out_artifacts=True,
        freq_min=300,
        freq_max=6000,
        whiten=True,
        samplerate=30303,
        detect_sign=1,
        adjacency_radius=50,
        _force_run=args.force_run
    )
    if geom_in:
        params['geom_in'] = geom_in
    CustomSorting.execute(**params)


def _bandpass_filter(timeseries_in, timeseries_out):
    code = '''
    #!/bin/bash
    ml-exec-process ms3.bandpass_filter -i timeseries:{} -o timeseries_out:{} -p samplerate:30303 freq_min:300 freq_max:6000
    '''.format(timeseries_in, timeseries_out)
    print(code)
    script = ShellScript(code)
    script.start()
    retcode = script.wait()
    if retcode != 0:
        raise Exception('problem running ms3.bandpass_filter')


def _whiten(timeseries_in, timeseries_out):
    code = '''
    #!/bin/bash
    ml-exec-process ms3.whiten -i timeseries:{} -o timeseries_out:{}
    '''.format(timeseries_in, timeseries_out)
    print(code)
    script = ShellScript(code)
    script.start()
    retcode = script.wait()
    if retcode != 0:
        raise Exception('problem running ms3.whiten')


def _mask_out_artifacts(timeseries_in, timeseries_out):
    code = '''
    #!/bin/bash
    ml-exec-process ms3.mask_out_artifacts -i timeseries:{} -o timeseries_out:{} -p threshold:6 interval_size:2000
    '''.format(timeseries_in, timeseries_out)
    print(code)
    script = ShellScript(code)
    script.start()
    retcode = script.wait()
    if retcode != 0:
        raise Exception('problem running ms3.mask_out_artifacts')


def _cluster_metrics(timeseries, firings, metrics_out):
    code = '''
    #!/bin/bash
    ml-exec-process ms3.cluster_metrics -i timeseries:{} firings:{} -o cluster_metrics_out:{} -p samplerate:30303
    '''.format(timeseries, firings, metrics_out)
    print(code)
    script = ShellScript(code)
    script.start()
    retcode = script.wait()
    if retcode != 0:
        raise Exception('problem running ms3.cluster_metrics')


def _isolation_metrics(timeseries, firings, metrics_out, pair_metrics_out):
    code = '''
    #!/bin/bash
    ml-exec-process ms3.isolation_metrics -i timeseries:{} firings:{} -o metrics_out:{} pair_metrics_out:{} -p compute_bursting_parents:true
    '''.format(timeseries, firings, metrics_out, pair_metrics_out)
    print(code)
    script = ShellScript(code)
    script.start()
    retcode = script.wait()
    if retcode != 0:
        raise Exception('problem running ms3.isolation_metrics')


def _combine_metrics(metrics1, metrics2, metrics_out):
    code = '''
    #!/bin/bash
    ml-exec-process ms3.combine_cluster_metrics -i metrics_list:{} metrics_list:{} -o metrics_out:{}
    '''.format(metrics1, metrics2, metrics_out)
    print(code)
    script = ShellScript(code)
    script.start()
    retcode = script.wait()
    if retcode != 0:
        raise Exception('problem running ms3.combine_metrics')


if __name__ == '__main__':
    main()
