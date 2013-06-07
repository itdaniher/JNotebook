load 'socket'
coinsert 'jsocket'

NB. sdsocket/sdconnect/sdsend/sdrecv/sdclose

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

echo sconn sock;type;localIP;1234

NB. little endian commands, unsigned char followed by a four byte integer

le =: monad : '3 ic <. y'
byte =: monad : '0 { (le y)'
int =: monad : '(4+(i.4)) { (|. le y)' 
tune =: monad : '((byte SET_FREQUENCY),(int y) ) sdsend sock;0'
echo tune 500e6
sdrecv sock,10,0

NB. get empty
sdrecv sock,1024,0

length =: 1024
data =: 1{::sdrecv sock,length,0
boxed =: ;/ data
b2i =: monad : '0 ic y,byte 0'
data =: (1 b2i\ data) % 255
realIndexes =: (2*i.($ i.length)%2)
imagIndexes =: realIndexes + 1
data =: ((realIndexes { data)) + 0j1 * imagIndexes { data
load 'plot'
plot |: data
sdcleanup ''
