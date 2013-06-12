load 'dll'
load 'handlebars.ijs'

lusb =: 'libusb-1.0.so libusb_'

NB. ctx is a 32b wide string literal zero
echo ('init i *',~lusb) cd <''
echo 'debug:'
echo ('set_debug n i i',~lusb) cd 0;3

NB. returns pointer to non-atomic array of unspecified type
NB. use shorts for uint_16 
NB. 'dev' should be script-specific?

dbr 1
mema 10
short =: monad : '1 (3!:4) y'
(short 16b59e3);(short 16bf000)
NULL =: 8$0{a.
echo dev =: ('open_device_with_vid_pid *c * s s',~lusb) cd NULL;16b59e3;16bf001

ctrlTransfer =: dyad :
	'libusb-1.0 libusb_control_transfer * c c s s *c s i' cd 


NB. use noun to hide multiline comment
0 :0
int libusb_control_transfer	(	libusb_device_handle * 	dev_handle,
uint8_t 	bmRequestType,
uint8_t 	bRequest,
uint16_t 	wValue,
uint16_t 	wIndex,
unsigned char * 	data,
uint16_t 	wLength,
unsigned int 	timeout 
)	

bulkTransferIn =: dyad :
	dev =: x
	NB. make empty length 64 vector, probably unnecessary
	IOVector =: 64$0
	NB. in bulk endpoint is 0x80
	response =: 'libusb-1.0 libusb_bulk_transfer * c *c i *i i' cd dev, 16b80, IOVector, #IOVector, transferred, 1000
	assert transferred = 64
	] IOVector
)
bulkTransferOut =: dyad :
	dev =: x
	NB. Y must be length 64 byte literal or possibly vector
	assert 64 = #y
	IOVector =: y
	NB. out bulk endpoint is 0x00
	response =: 'libusb-1.0 libusb_bulk_transfer > * c *c i *i i' cd dev; 16b00; IOVector; #IOVector; transferred; 1000
	assert transferred = 64
)

0 : 0
int libusb_bulk_transfer	(	struct libusb_device_handle * 	dev_handle,
unsigned char 	endpoint,
unsigned char * 	data,
int 	length,
int * 	transferred,
unsigned int 	timeout 
)	

'libusb-1.0 libusb_exit i' cd NULL
