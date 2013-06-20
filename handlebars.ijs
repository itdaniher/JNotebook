load 'trig'
load 'graphics/plot'

deriv =: monad : '-~/ |: (2 +\ y)'
linspace =: monad : '(0{y)+((1{y-0{y)%(2{y))*(i.(2{y))'
logspace =: monad : '10^ linspace y'
convolve =: +//.@:(*/) 
movingAverage =: dyad : '(x$(1%x)) convolve y'

mean =: +/%"1#

noise =: monad : 0
        'low high count' =: y
        (high-low)*(? count $ 0) + low
)

dcheck =: monad : '_2 + 1 { $ 0,.|:y' 

d1 =: monad : 0
	echo y
	pd (i.#y);y
)
d2 =: monad : 0
	pd (0{y);(1{y)
)
d3 =: monad : 0
	pd (0{y);1{y
	pd 'y2axis'
	pd (0{y);2{y
)
plot =: monad : 0
	samples =: |: y
	pd 'new'
	(d1 ` d2 ` d3) @. dcheck samples
	pd 'canvas 1100 500'
)

types =: 'bool';'string';'int';'float';'complex';'boxed';'ext int';'rational'   
type  =: > @: ({ & types) @: (1 2 4 8 16 32 64 128 & i.) @: (3 !: 0)
Ts =: 6!:2 , 7!:2@]


hexit =: monad : '_1 ({:: 3!:3) y'

le =: monad : '3 ic <. y'
byte =: monad : '0 { (le y)'
int =: monad : '(4+(i.4)) { (|. le y)' 
