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


freq =: 104e6
SET_FREQUENCY cmd freq
SET_SAMPLERATE cmd 2e6
length =: 2*1e4

'error name' =: sdrecv sock,length,0
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
load 'plot'

bytes =: getBytes length
(echo Ts 'samples =: normalizeBytes bytes')
load 'math/fftw'
pd 'new'
fftd =: | fftw_z_ samples
pd 'ylog 1'
pd (freq+(i.(#fftd))*(2e6%#fftd));fftd
pd 'canvas 1000 500'
sdcleanup ''
