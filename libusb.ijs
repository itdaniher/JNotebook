load 'dll'
load 'handlebars.ijs'

NB. http://www.jsoftware.com/help/user/call_procedure.htm
lusb =: 'libusb-1.0.so libusb_'

NULL =: <0

('init i *',~lusb) cd <NULL

dev =: 0 { ('open_device_with_vid_pid *c * s s',~lusb) cd NULL;16b59e3;16bf000

ctrlTransfer =: dyad : 0
	'bRequest wValue wIndex' =: x
	bmRequestType =: 192 NB. MSB = 1 =: IN; MSB = 0 =: OUT
	data =: y
	len =: #y 
	NB. int libusb_control_transfer (libusb_device_handle *dev_handle, uint8_t bmRequestType, uint8_t bRequest, uint16_t wValue, uint16_t wIndex, unsigned char *data, uint16_t wLength, unsigned int timeout)
	a.&i. 6 {:: ('control_transfer i * c c s s *c s i',~lusb) cd (dev;(bmRequestType{a.);(bRequest{a.);wValue;wIndex;data;len;1000)
)

NB. int libusb_bulk_transfer (struct libusb_device_handle *dev_handle, unsigned char endpoint, unsigned char *data, int length, int *transferred, unsigned int timeout)

maxRead =: 1024

xfer =: < mema 4

buffer =: < mema maxRead
(maxRead$0{a.) memw (;buffer),0,maxRead,2 

bulkTransferIn =: dyad : 0
	len =: x
	echo assert len = 4 {:: ('bulk_transfer i * c *c i *i i',~lusb) cd dev;((16b81{a.));buffer;(len);(xfer);10
	echo memr (;buffer),0,len,2
)

bulkTransferOut =: dyad : 0
	data =: y
	len =: #data
	y memw (;buffer),0,(#data),2
	assert len = 4 {:: ('bulk_transfer i * c *c i *i i',~lusb) cd dev;(1{a.);buffer;(len);(xfer);10
	
)
'' bulkTransferOut 12$(97+i.10){a.
512 bulkTransferIn ''
NB. ('close n *',~lusb) cd <dev
NB. ('exit n *',~lusb) cd <NULL
