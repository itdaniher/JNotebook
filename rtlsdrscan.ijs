load 'handlebars.ijs'
load 'math/fftw'
load 'librtlsdr.ijs'

freq =: 100e6
sampleRate =: 2e6

getFFTd =: dyad : 0
	freq =: y
	length =: x
	tune freq
	samples =: normalizeBytes getBytes length
	fftd =: | fftw_z_ samples
	freqbins =: (freq+(i.(#fftd))*(sampleRate%#fftd))
	] freqbins ,. fftd
)

NB. baseFreq is offset, number of bins from size of return data, each bin proportional to sampleRate divided by the number of bins
samples =: |: ,/ (20*512)&getFFTd"0 (80e6 + 1e6*i.20)
plot samples 
