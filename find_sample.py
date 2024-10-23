#!/usr/bin/env python3
import numpy as np
import sys
from scipy.io import wavfile
from scipy import signal

snippet = sys.argv[1]
source  = sys.argv[2]


# for F in *mp3 ; do ffmpeg -y -loglevel 24 -i "$F" "${F%mp3}wav" ; START=$(../find_sample.py start_sample.wav "${F%mp3}wav" 2>&1 | awk '/start/{print $2}') ; ffmpeg -y -loglevel 24 -ss $START -i "$F" -acodec copy trimmed/"$F" ; done
# for F in *mp3 ; do eyeD3 --write-images=. "$F" ; eyeD3 --add-image="FRONT_COVER.jpg":FRONT_COVER:"$(dirname $PWD)" trimmed/"$F" ; rm -fv FRONT_COVER.jpg ; touch -r "$F" trimmed/"$F" ; done




# read the sample to look for
rate_snippet, snippet = wavfile.read(snippet);
snippet = np.array(snippet, dtype='float')

# read the source
rate, source = wavfile.read(source);
source = np.array(source, dtype='float')

# resample such that both signals are at the same sampling rate (if required)
if rate != rate_snippet:
  num = int(np.round(rate*len(snippet)/rate_snippet))
  snippet = signal.resample(snippet, num)

# https://docs.scipy.org/doc/scipy/reference/generated/scipy.signal.correlate.html
# compute the cross-correlation

# correlate_modes = ["full"]
correlate_modes = ["full", "same", "valid"]
# correlate_methods = {"direct", "fft"}
correlate_methods = ["auto"]

for correlate_mode in correlate_modes:
    for correlate_method in correlate_methods:
      z = signal.correlate(source, snippet, correlate_mode, correlate_method)
      peak = np.argmax(np.abs(z))
      start = (peak-len(snippet)+1)/rate
      end   = peak/rate
      # print("{} {}: {}".format(correlate_mode, correlate_method, start))
      print("{}".format(start))
