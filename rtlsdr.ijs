load 'socket'
coinsert 'jsocket'
load 'handlebars.ijs'

sconn =: monad : 'sderror sdconnect y'

SET_FREQUENCY =: 01
SET_SAMPLERATE =: 02
SET_GAINMODE =: 03
SET_GAIN =: 04
SET_FREQENCYCORRECTION =: 05

sock =: 1 {:: sdsocket AF_INET,SOCK_STREAM,0

'returnCode type localIP' =: sdgethostbyname 1 {:: sdgethostname ''

NB. local machine, port 1234 is default
assert 'no error' = sconn sock;type;localIP;1234

NB. little endian commands, unsigned char followed by a four byte integer
cmd =: dyad : '((byte x),(int y) ) sdsend sock;0'

'error name' =: sdrecv sock,1e3,0
assert error = 0
echo name

reqBytes =: dyad : 0
	toGet =: x-#y
	echo toGet
	'error bytes' =: sdrecv sock,toGet,0
	assert error = 0
	] y,bytes
)

getBytes =: monad : 0
	NB. execute 'length reqBytes data' as long as 'length' is not equal to the size of data
	NB. start request with an empty array
	length =: y
	bytes =: length reqBytes^:(~: #)^:_ ('','')
)

normalizeBytes =: monad : 0
	bytes =: y
	length =: # bytes
	assert ((2 | length) = 0)
	NB. it's super effective! 'a.&i' : find index against character list
	data =: _1 + (a.&i.bytes) % 127 
	NB. convert an interleaved list of real,imag numbers to a half-length list of complex numbers
	data =: ((length%2), 2) $ data
	samples =: +/"1 (1, 0j1) *"1 data
)

load 'math/fftw'

freq =: 100e6
sampleRate =: 2e6

SET_SAMPLERATE cmd sampleRate

getFFTd =: dyad : 0
	freq =: y
	length =: x
	echo freq
	SET_FREQUENCY cmd freq
	usleep 1e6
	samples =: normalizeBytes getBytes length
	fftd =: | fftw_z_ samples
	freqbins =: (freq+(i.(#fftd))*(sampleRate%#fftd))
	] freqbins ,. fftd
)

load 'plot'
pd 'new'
NB. baseFreq is offset, number of bins from size of return data, each bin proportional to sampleRate divided by the number of bins
pd 'type point'
samples =: |: ,/ 2e4&getFFTd"0 (90e6 + 1e6*i.10)
echo $ samples
pd (0{samples);(1{samples)
pd 'canvas 1100 500'
sdcleanup ''
