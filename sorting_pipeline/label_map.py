import numpy as np
import json
from spikeforest import mdaio

# authors: J Chung and J Magland

def create_label_map(*, metrics, label_map_out, firing_rate_thresh = .05, isolation_thresh = 0.95, noise_overlap_thresh = .03, peak_snr_thresh=1.5):
    """
    Generate a label map based on the metrics file, where labels being mapped to zero are to be removed.
    Parameters
    ----------
    metrics : INPUT
        Path of metrics json file to be used for generating the label map
    label_map_out : OUTPUT
        Path to mda file where the second column is the present label, and the first column is the new label
        ...
    firing_rate_thresh : float64
        (Optional) firing rate must be above this
    isolation_thresh : float64
        (Optional) isolation must be above this
    noise_overlap_thresh : float64
        (Optional) noise_overlap_thresh must be below this
    peak_snr_thresh : float64
        (Optional) peak snr must be above this
    """
    label_map = []

    #Load json
    with open(metrics) as metrics_json:
        metrics_data = json.load(metrics_json)

    #Iterate through all clusters
    for idx in range(len(metrics_data['clusters'])):
        if metrics_data['clusters'][idx]['metrics']['firing_rate'] < firing_rate_thresh or \
            metrics_data['clusters'][idx]['metrics']['isolation'] < isolation_thresh or \
            metrics_data['clusters'][idx]['metrics']['noise_overlap'] > noise_overlap_thresh or \
            metrics_data['clusters'][idx]['metrics']['peak_snr'] < peak_snr_thresh:
            #Map to zero (mask out)
            label_map.append([0,metrics_data['clusters'][idx]['label']])
        elif metrics_data['clusters'][idx]['metrics']['bursting_parent']: #Check if burst parent exists
            label_map.append([metrics_data['clusters'][idx]['metrics']['bursting_parent'],
                              metrics_data['clusters'][idx]['label']])
        else:
            label_map.append([metrics_data['clusters'][idx]['label'],
                              metrics_data['clusters'][idx]['label']]) # otherwise, map to itself!
                

    #Writeout
    return mdaio.writemda64(np.array(label_map),label_map_out)

def apply_label_map(*, firings, label_map, firings_out):
    """
    Apply a label map to a given firings, including masking and merging
    Parameters
    ----------
    firings : INPUT
        Path of input firings mda file
    label_map : INPUT
        Path of input label map mda file [base 1, mapping to zero removes from firings]
    firings_out : OUTPUT
        ...
    """
    firings = mdaio.readmda(firings)
    label_map = mdaio.readmda(label_map)
    label_map = np.reshape(label_map, (-1,2))
    label_map = label_map[np.argsort(label_map[:,0])] # Assure input is sorted

    #Propagate merge pairs to lowest label number
    for idx, label in enumerate(label_map[:,1]):
    	# jfm changed on 12/8/17 because isin() is not isin() older versions of numpy. :)
        #label_map[np.isin(label_map[:,0],label),0] = label_map[idx,0] # Input should be sorted
        label_map[np.where(label_map[:,0]==label)[0],0] = label_map[idx,0] # Input should be sorted

    #Apply label map
    for label_pair in range(label_map.shape[0]):
    	# jfm changed on 12/8/17 because isin() is not isin() older versions of numpy. :)
        #firings[2, np.isin(firings[2, :], label_map[label_pair, 1])] = label_map[label_pair,0]
        firings[2, np.where(firings[2, :] == label_map[label_pair, 1])[0]] = label_map[label_pair,0]

    #Mask out all labels mapped to zero
    firings = firings[:, firings[2, :] != 0]

    #Write remapped firings
    return mdaio.writemda64(firings, firings_out)
