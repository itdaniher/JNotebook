load 'handlebars.ijs'
load 'dsputils.ijs'

echo Ts 'plot |: (i.#data),.data =: (50 * i.50%~10e3) { ((1,10e3)lpf i.256) convolve noise 0,1,10e3'
