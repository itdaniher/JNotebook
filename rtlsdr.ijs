load 'socket'
coinsert 'jsocket'
load 'handlebars.ijs'

sconn =: monad : 'sderror sdconnect y'
ssend =: dyad : 'sderror x sdsend y'
srecv =: dyad : 'sderror x sdrecv y'
sclse =: monad : 'sderror sdcleanup '''''

SET_FREQUENCY =: 01
SET_SAMPLERATE =: 02
SET_GAINMODE =: 03
SET_GAIN =: 04
SET_FREQENCYCORRECTION =: 05

sock =: 1 {:: sdsocket AF_INET,SOCK_STREAM,0

'returnCode type localIP' =: sdgethostbyname 1 {:: sdgethostname ''

NB. local machine, port 1234 is default
echo sconn sock;type;localIP;1234

NB. little endian commands, unsigned char followed by a four byte integer
cmd =: dyad : '((byte x),(int y) ) sdsend sock;0'

SET_FREQUENCY cmd 144.64e6
SET_SAMPLERATE cmd 1e5
length =: 1024

NB. get first chunk
echo sdrecv sock,length,0

getSamples =: monad : 0
	length =: y
	bytes =: 1{::sdrecv sock,length,0
	boxed =: ;/ data
	data =: ((1 b2i\ bytes) % 127)-1
	realIndexes =: (2*i.($ i.length)%2)
	imagIndexes =: realIndexes + 1
	samples =: ((realIndexes { data)) + 0j1 * imagIndexes { data
)

load 'plot'
plot |: getSamples length
sdcleanup ''
