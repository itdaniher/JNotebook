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

sampleTime =: 1%10000
samplesToStore =: 1%sampleTime

(('sampleTime',":sampleTime),'&samples=',":samplesToStore) httpget deviceURL,'/configuration'

'capture=on' httpget deviceURL

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
	selectCleanup =: monad : 'count = 1'
	cleanRow =: monad : '". }: (LF,'','') charsub y'
	cleanRows =: monad : '(((#data)%2),2) $ data =: cleanRow y'
	data =: cleanRows`cleanRow @. selectCleanup csvData
)

setout =: dyad : 0
	chan =: 0 {:: x
	direction =: 1 {:: x
	value =: 0 { y
	requestURL =: deviceURL,'/',chan,'/output'
	params =: 'wave=arb&mode=',direction,'&repeat=0','&points=0:', ('_-' charsub ":value) NB., ''''
	response =: dec_json params httpget requestURL
	". ": ; 'startSample' gethash_json response
)

load 'math/fftw'

oneSec =: 1%sampleTime
xpyj =: dyad : 'x+0j1*y'
logFFT =: monad : '^. |fftw_z_ y'

load 'handlebars.ijs'

doStuff =: monad : 0
	start =: ('a';'svmi')&setout y
	data =: 'a' get (start+oneSec*1),(start+oneSec*2)
	ffts =: logFFT"1  |: data
	ffts =: 100 movingAverage"1 ffts
	ffts =: (;/(i.2%~1+(1{$ffts))) { |: ffts
	((6j3":y),'.png') plot (i.(0 { $ffts)),.ffts
)


doStuff"0 (2+30%~i.30)

