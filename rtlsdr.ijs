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

le =: monad : '1 ic <. y'
byte =: monad : '0 { (le y)'
int =: monad : '(i.2) { (le y)'

tune =: monad : '((byte SET_FREQUENCY),(int 0),(int y) ) sdsend sock;0'
echo tune 144.64e6
load 'handlebars.ijs'
data =: sdrecv sock,10,0
echo data
data =: sdrecv sock,1000,0
echo data
NB. echo 3!:3 data
sdcleanup ''
