# mini_analysis description
Mini-analysis pipeline in MATLAB for ScanImage data

A step-by-step pipeline for identifying miniature PSCs in voltage-clamp data, acquired using Bernardo's custom ScanImage

This semi-automated pipeline requires the user to manually select several example PSCs to generate an average PSC onto which a template PSC wave-form can be manually fit
After basic processing of the raw data traces, the user than selects an amplitude threshold and correlation threshold to identify PSCs through two main methods: amplitude over noise, or by matching to the template

Following selection of these parameters, PSCs are detected in all data traces

Users than quality control each identified PSC in a separate GUI

Finally, the mean PSC and CDF of the inter-event intervals and amplitudes are plotted and saved

# Directions
To run the pipeline, open the "mini_analysis.m" file while the current folder is set to the cell folder you want to analyze
  This .m file is broken up into sections that should be run one at a time:
  
  --Section 1: Define whether you are detecting mEPSCs or mIPSCs 
  --Section 2: Load in all traces corresponding to which epoch of the recording you want analyzed
  --Section 3: Downsample/Filter the raw data traces and trim out the RC check
  --Section 4: Manually select several example PSCs and match the mean PSC to a template, determined by a multiexponential fit
  Section 5: Select the amplitude and correlation thresholds for the amplitude detection and template-matching detection, respsectively
  Section 6: Detect all events according the the tresholds just chosen
  Section 7: Convert detected events to match the raw data
  Section 8: Perform manual QC of each mini (this is the step that takes the longest)
  Section 9: Graph and save data
