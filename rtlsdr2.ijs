load 'dll'
load 'handlebars.ijs'
lrtlsdr =: 'librtlsdr.so rtlsdr_'

devCount =: ;(('get_device_count i',~lrtlsdr) cd '')
devIndex =: devCount-1
assert devIndex = 0

NB. dev is a pointer to the dev struct; don't muck with it
devPtr =: mema 100
echo devPtr
echo ('open i *c i',~lrtlsdr) cd (<devPtr);0

echo ('reset_buffer i *c',~lrtlsdr) cd <<devptr

namePtr =: 0{::('get_device_name *s i',~lrtlsdr) cd <0
echo memr namePtr,0,_1

NB. echo ('set_sample_rate i * i',~lrtlsdr) cd (<devPtr);2e6
echo ('close i *c i',~lrtlsdr) cd (<devPtr);0
