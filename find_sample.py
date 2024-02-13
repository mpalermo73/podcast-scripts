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
#z = signal.correlate(source, snippet, "full", "auto");
#z = signal.correlate(source, snippet, "valid", "auto");
z = signal.correlate(source, snippet, "same", "auto");

peak = np.argmax(np.abs(z))
start = (peak-len(snippet)+1)/rate
end   = peak/rate

# print("start {} end {}".format(start, end))
print("start full: {} \nhalf: {}".format(start, start/2))
