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

SET_FREQUENCY cmd 100e6
SET_SAMPLERATE cmd 400000
length =: 20000

load 'format.ijs'
'error name' =: sdrecv sock,length,0
assert error = 0
echo name

getSamples =: monad : 0
	length =: y
	'error bytes' =: sdrecv sock,length,0
	assert error = 0
	data =: ((1 b2i\ bytes) % 127)-1
	length =: # data
	assert ((2 | length) = 0)
	realIndexes =: (length) $ (1, 0)
	imagIndexes =: realIndexes = 0
	samples =: (realIndexes # data) + (0j1 * imagIndexes # data)
)

load 'plot'
plot |: getSamples length
sdcleanup ''
