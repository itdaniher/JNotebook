load 'plot'
load 'trig'
load 'handlebars.ijs'

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
