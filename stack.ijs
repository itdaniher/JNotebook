load 'plot'
load 'trig'

mean =: +/%"1#

NB. generate 'count' equally spaced numbers between 'start' and 'end'
linspace =: 3 : 0
	'start end count' =: y
	start+end*(i.count) % count
)

NB. generate 'count' random numbers between 'low' and 'high'
noise =: 3 : 0
	'low high count' =: y
	(high-low)*(? count $ 0) + low
)

NB. generate vector containing a sine wave having 'periods', with each period having 'sampleRate' samples
getData =: 3 : 0 
	'periods sampleRate' =: y
	sin ( linspace 0, (o.(2*periods)), (sampleRate*periods)) + noise _0.5, 0.5, (sampleRate*periods)
)

trials =: 100 
points =: 500

data =: (trials, points) $ getData trials, points

pd 'new'
pd (linspace 0, 1, points); mean data
pd 'canvas 1000 500'
