load 'dll'
load 'handlebars.ijs'

NB. http://www.jsoftware.com/help/user/call_procedure.htm
lusb =: 'libusb-1.0.so libusb_'

NULL =: <0
echo ('init i *',~lusb) cd <NULL
echo ('set_debug n * i',~lusb) cd NULL;3

NB. returns pointer to non-atomic array of unspecified type
NB. use shorts for uint_16 
NB. 'dev' should be script-specific?

dbr 1
dev =: 0 { ('open_device_with_vid_pid *c * s s',~lusb) cd NULL;16b59e3;16bf000
echo dev
echo ('get_device_speed i *c',~lusb) cd <dev
NB. echo ('get_device_descriptor i * *',~lusb) cd (dev;<<mema 1000)

echo dev;1
ctrlTransfer =: dyad : 0
	'bRequest wValue wIndex' =: x
	bmRequestType =: 192 NB. MSB = 1 =: IN; MSB = 0 =: OUT
	NB. build len-8
	data =: y
	len =: #y 
	NB. int 	libusb_control_transfer (libusb_device_handle *dev_handle, uint8_t bmRequestType, uint8_t bRequest, uint16_t wValue, uint16_t wIndex, unsigned char *data, uint16_t wLength, unsigned int timeout)
	a.&i. 6 {:: ('control_transfer i * c c s s *c s i',~lusb) cd (dev;(bmRequestType{a.);(bRequest{a.);wValue;wIndex;data;len;1000)
)

load 'dates'
max31855 =: monad : 0 
	response =: (16ba0, 0, 0) ctrlTransfer (4 $ '0')
	ts =: 0 tsrep 6!:0 ''
	usleep 1e4
	temp =: (2^4)%~  +/ (255, 1) *"1 (2,3) { response
	] ts,temp
)

echo data =: |: max31855"0 i.1000
tempSeries =: data -"0 (0 { 0 { data),0
load 'plot'
plot ;/tempSeries

0 : 0
int libusb_bulk_transfer	(	struct libusb_device_handle * 	dev_handle,
unsigned char 	endpoint,
unsigned char * 	data,
int 	length,
int * 	transferred,
unsigned int 	timeout 
)	
('close n *',~lusb) cd <dev
('exit n *',~lusb) cd <NULL
