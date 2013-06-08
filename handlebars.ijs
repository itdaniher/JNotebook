deriv =: monad : '-~/ |: (2 +\ y)'
linspace =: monad : '(0{y)+(1{y)*(i.(2{y)) % (2{y)'

convolve =: +//.@:(*/) 
movingAverage =: dyad : '(x$(1%x)) convolve y'

mean =: +/%"1#

noise =: monad : 0
        'low high count' =: y
        (high-low)*(? count $ 0) + low
)



types =: 'bool';'string';'int';'float';'complex';'ext int';'rational'   
type  =: > @: ({ & types) @: (1 2 4 8 16 64 128 & i.) @: (3 !: 0)

hexit =: monad : '_1 ({:: 3!:3) y'

le =: monad : '3 ic <. y'
byte =: monad : '0 { (le y)'
int =: monad : '(4+(i.4)) { (|. le y)' 
b2i =: monad : '0 ic y,byte 0'
