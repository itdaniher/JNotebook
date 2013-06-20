load 'dll'
lrtlsdr =: 'librtlsdr.so rtlsdr_'
devCount =: ;(('get_device_count i',~lrtlsdr) cd '')
assert 0 = devIndex =: devCount-1

NB. devPtrPtr is a pointer to a pointer to the dev struct
devPtrPtr =: mema 4
assert 0 = ('open > i * i',~lrtlsdr) cd (<devPtrPtr);0

NB. dereference devPtrPtr to devPtr by reading it as an int
NB. library pointer assignment at https://github.com/steve-m/librtlsdr/blob/master/src/librtlsdr.c#L1464
devPtr =: memr devPtrPtr,0,1,4

NB. namePtr is pointer to name as a string
echo namePtr =: 0 {:: ('get_device_name *s i',~lrtlsdr) cd <0
echo name =: memr namePtr,0,_1

NB. why is this needed!?
devPtr =: < ". ": devPtr

NB. housekeeping
assert 0 = ('reset_buffer > i *',~lrtlsdr) cd <devPtr

samplingRate =: 2.048e6

NB. good compromise
assert 0 = ('set_sample_rate > i * i',~lrtlsdr) cd devPtr;samplingRate

NB. disable manual gain -> enable automatic gain
assert 0 = ('set_tuner_gain_mode > i * i',~lrtlsdr) cd devPtr;0

CC=: ({.@] <: [)*.([ <: {:@])

NB. tune
tune =: monad : 0 
	assert y CC (24e6,1900e6)
	assert 0 = ('set_center_freq > i * i',~lrtlsdr) cd devPtr;y
)

xfer =: < mema 4
0 memw (;xfer),0,1,4
buffer =: < mema samplingRate
(samplingRate$0{a.) memw (;buffer),0,samplingRate,2
echo memr (;xfer),0,1,4

getBytes =: monad : 0
	length =: y
	assert 0 = ('read_sync > i * *s i *i',~lrtlsdr) cd devPtr;buffer;length;<xfer
	memr (;buffer),0,length,2
)

normalizeBytes =: monad : 0 
    bytes =: y
    length =: # bytes
    assert ((2 | length) = 0)
    NB. it's super effective! 'a.&i' : find index against character list
    data =: _1 + (a.&i.bytes) % 127 
    NB. convert an interleaved list of real,imag numbers to a half-length list of complex numbers
    data =: ((length%2), 2) $ data
    samples =: +/"1 (1, 0j1) *"1 data
)
