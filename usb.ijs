load 'dll'
load 'handlebars.ijs'

NB. http://www.jsoftware.com/help/user/call_procedure.htm
lusb =: 'libusb-1.0.so libusb_'

NULL =: <0
echo ('init i *',~lusb) cd <NULL
echo 'debug:'
echo ('set_debug n * i',~lusb) cd NULL;3

NB. returns pointer to non-atomic array of unspecified type
NB. use shorts for uint_16 
NB. 'dev' should be script-specific?

dbr 1
dev =: _1 { ('open_device_with_vid_pid *c * s s',~lusb) cd NULL;16b59e3;16bf000
echo dev

ctrlTransfer =: dyad : 0
	'bRequest wValue wIndex' =: x
	bmRequestType =: 192
	data =: 8$48{a.
	len =: #y
	echo (dev;(bmRequestType{a.);(bRequest{a.);wValue;wIndex;data;len;1000) 
	NB. int 	libusb_control_transfer (libusb_device_handle *dev_handle, uint8_t bmRequestType, uint8_t bRequest, uint16_t wValue, uint16_t wIndex, unsigned char *data, uint16_t wLength, unsigned int timeout)
	('control_transfer i * c c s s *c s i',~lusb) cd (dev;(bmRequestType{a.);(bRequest{a.);wValue;wIndex;data;len;1000)
)

echo (16ba0, 0, 0) ctrlTransfer (4 $ 0)

NB. use noun to hide multiline comment

bulkTransferIn =: dyad : 0
	dev =: x
	NB. make empty length 64 vector, probably unnecessary
	IOVector =: 64$0
	NB. in bulk endpoint is 0x80
	response =: 'libusb-1.0 libusb_bulk_transfer * c *c i *i i' cd dev, 16b80, IOVector, #IOVector, transferred, 1000
	assert transferred = 64
	] IOVector
)
bulkTransferOut =: dyad : 0
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
('close n *',~lusb) cd dev
('exit n *',~lusb) cd <NULL
