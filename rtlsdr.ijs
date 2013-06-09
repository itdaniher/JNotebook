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

SET_FREQUENCY cmd 104e6
SET_SAMPLERATE cmd 2e6
length =: 1e5

'error name' =: sdrecv sock,length,0
assert error = 0
echo name

getBytes =: dyad : 0
	toGet =: x-#y
	echo toGet
	'error bytes' =: sdrecv sock,toGet,0
	assert error = 0
	] y,bytes
)


normalizeBytes =: monad : 0
	bytes =: y
	length =: # bytes
	assert ((2 | length) = 0)
	data =: _1 + (a.&i.bytes) % 127 
	NB. convert an interleaved list of real,imag numbers to a half-length list of complex numbers
	data =: ((length%2), 2) $ data
	samples =: +/"1 (1, 0j1) *"1 data
)
load 'plot'
checkLength =: dyad : 'x ~: # y'
bytes =: ] length getBytes^:checkLength^:_ ('','') 
echo $ bytes
(echo Ts 'samples =: normalizeBytes bytes')
plot |samples
load 'math/fftw'
plot | fftw_z_ samples
sdcleanup ''
