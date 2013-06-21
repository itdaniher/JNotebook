NB. Contributed by Bill Harris, Facilitated Systems; Ian Daniher, Analog Devices

require 'trig'

twl =: 20&*@:(10&^.)
tel =: 10&*@:(10&^.)

NB. monad: takes a vector from 0 to N, returns N numbers between 0 and 1 - equivalent to linspace 0, 1, N
indices =: (] %~ i.)@: #

NB. good enough
hamming=: 0.54 & - @: (0.46 & *)@: cos @: (2p1 & *) @: indices

NB. better
blackmanharris=: 3 : 0
   0.355768 0.487396 0.144232 0.012604 blackmanharris y
:
  'a0 a1 a2 a3'=. x
  w=.-(a3&*)@: (2 & o.) @: (6p1 & *) @: indices y
  w=.w+(a2&*)@: (2 & o.) @: (4p1 & *) @: indices y
  w=.w-(a1&*)@: (2 & o.) @: (2p1 & *) @: indices y
  w=. a0+w
)

NB. 'best'?
nuttall=: 10r32 15r32 6r32 1r31 & blackmanharris

NB. 0 = x sinc 0
sinc =: dyad : '(2p1*y) %~ sin x*2p1*y'

lpf =: dyad : 0
	'corner samplingRate' =: x
	taps =: y
	filter =: (hamming taps) * (corner%samplingRate) sinc taps -~ 2%~#taps
	NB. in place ammend of the tap h = 0
	filter =: 2p1*(corner%samplingRate) (2%~#taps) } filter
	NB. generate constant K to scale such that net gain is 1
	scaleFactor =: 1%+/filter
	] scaleFactor*filter
)

dfft=: 3 : '+/ y * ^ (#y) %~ (- o. 0j2 ) * */~ i.#y'
