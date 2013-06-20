load 'httpget.ijs'
load 'convert/json'
NB. load 'tables/dsv'
Ver_phttpget_=: '1.1'

baseURL =: 'http://localhost:9003/rest/v1/'

devices =: dec_json httpget baseURL,'devices'

device =: 0{::devices
serial =: ;'id' gethash_json ;(device gethash_json devices)

deviceURL =: baseURL,'devices/',serial

deviceInfo =: dec_json httpget deviceURL
NB. start

'sampleTime=0.0001&samples=100000' httpget deviceURL,'/configuration'

'capture=on' httpget deviceURL

NB. 10ksps, 10 seconds scrollback

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
	(((#data)%2),2) $ data =: ". }: }: (LF,',') charsub csvData
)

setout =: dyad : 0
	chan =: 0 {:: x
	direction =: 1 {:: x
	value =: 0 { y
	requestURL =: deviceURL,'/',chan,'/output'
	params =: 'wave=arb&mode=',direction,'&repeat=0','&points=0:', (":value) NB., ''''
	response =: dec_json params httpget requestURL
	". ": ; 'startSample' gethash_json response
)

startSample =: 0{ ('a';'simv')&setout"0 (0, 50)
data =: 'a' get (startSample , 1000+startSample)
load 'handlebars.ijs'
plot (startSample + (i.#data)),.data
