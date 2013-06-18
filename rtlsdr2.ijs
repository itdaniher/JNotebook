load 'dll'
load 'handlebars.ijs'
lrtlsdr =: 'librtlsdr.so rtlsdr_'

devCount =: ;(('get_device_count i',~lrtlsdr) cd '')
devIndex =: devCount-1
assert devIndex = 0
NB. devPtrPtr is a pointer to a pointer to the dev struct
devPtrPtr =: mema 4
echo ('open i * i',~lrtlsdr) cd (<devPtrPtr);0
echo devPtrPtr
NB. dereference devPtrPtr to devPtr by reading it as an int
NB. library pointer assignment at https://github.com/steve-m/librtlsdr/blob/master/src/librtlsdr.c#L1464
devPtr =: memr devPtrPtr,0,1,4
echo devPtr

NB. namePtr is pointer to name as a string
namePtr =: 0{::('get_device_name *s i',~lrtlsdr) cd <0
name =: memr namePtr,0,_1
echo name

NB. why is this needed!?
devPtr =: ". ": devPtr

echo ('set_sample_rate i * i',~lrtlsdr) cd (<devPtr);2e6

results =: ('reset_buffer i *',~lrtlsdr) cd <<devPtr

echo ('close i *',~lrtlsdr) cd <<devPtr
