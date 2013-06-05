load 'httpget.ijs'
load 'convert/json'
load 'tables/dsv'
Ver_phttpget_=: '1.1'

baseURL =: 'http://localhost:9003/rest/v1/'

devices =: dec_json httpget baseURL,'devices'

device =: ;(0{devices)
serial =: ;'id' gethash_json ;(device gethash_json devices)

deviceURL =: baseURL,'devices/',serial

deviceInfo =: dec_json httpget deviceURL
NB. start

'sampleTime=0.0001&samples=10000' httpget deviceURL,'/configuration'

'capture=on' httpget deviceURL

NB. 10ksps, 1 second scrollback

type =: 3!:0

NB. x, y
get =: dyad : 0
	'start end' =: y
	chan =: x
	count =: end - start
	populateStart =: dyad : '''&start='',":y'
	strOrZero =: monad : '0 populateStart^:~: (0{y)'
	isntString =: dyad : '(type '''') ~: (type y)'
	startString =: '' [ ^:isntString strOrZero start
	requestURL =: (deviceURL,'/',chan,'/input?resample=0&header=0',startString,'&count=',(":count))
	csvData =: httpget requestURL
	',' fixdsv csvData
)

echo 'time to get 10k samples - should be about 1sec'
echo (6!:2 ' ''a'' get (0, 10000)')

setout =: dyad : 0
	NB. 'a', 'i' set 10
	chan =: ; (0 { x)
	direction =: ; (1 { x)
	value =: 0{y
	requestURL =: deviceURL,'/',chan,'/output'
	params =: 'wave=arb&mode=',direction,'&repeat=0','&points=0:', (":value) NB., ''''
	response =: dec_json params httpget requestURL
	; 'startSample' gethash_json response
)

setOut =: monad : 0
	('a'; 'svmi') setout y
)

echo setOut &.> ((i.100)%20)
