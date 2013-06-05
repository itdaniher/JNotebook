NB. httpget - requests resource by url, r3
NB.
NB. install   copy 'httpget.ijs' to '~user/'
NB. execute   load 'user/httpget.ijs'
NB.           httpget 'http://address.com/folder/file.ext'
NB. 08/12/2006 Oleg Kobchenko - Happy birthday, PC
NB. 08/14/2006 Oleg Kobchenko - correct version, other configed headers
NB. 08/15/2006 Oleg Kobchenko - attempts, implicit '/'
NB. 04/16/2007 Oleg Kobchenko - POST, SOAP client

require 'socket files strings'

coclass 'phttpget'
coinsert 'jdefs jsocket'

scgethostbyname=: sdcheck@sdgethostbyname
sccleanup=:       sdcheck@sdcleanup
scsocket=:  0&{::@sdcheck@sdsocket
scbind=:          sdcheck@sdbind
sclisten=:        sdcheck@sdlisten
scconnect=:       sdcheck@sdconnect
srselect=:  0&{::@sdcheck@sdselect
swselect=:  1&{::@sdcheck@sdselect
scaccept=:  0&{::@sdcheck@sdaccept
scioctl=:   0&{::@sdcheck@sdioctl
upto=: (<. #) {. ]


NB. =========================================================
NB. config
Port=:      80
ChunkSize=: <.2^16
Timeout=:   2000
Attempts=:  10
Log=:       jpath '~temp/httpget-log.txt'  NB. 2 (session)
Ver=:       '0.9'  NB. protocol version, also 1.0 or 1.1
Lang=:      'en-us'
Agent=:     'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1)'
Ref=:       ''     NB. 'http://1.2.3.4'
Conn=:      ''     NB. 'Keep-Alive'
Heads=:     ''     NB. custom headers

NB. =========================================================
httpget=: 3 : 0
  '' httpget y
:
  init ''
  'host port path'=. parseUrl y
  log ;:^:_1 host;(":port);path
  sk=. port connect host
  q=. x request host;port;path
  q write sk
  r=. read sk
  finilize sk
  trim r
)

NB. =========================================================
NB. HTTP

request=: 3 : 0
  '' request y
:
  'host port path'=. y
  Ver=: 0j1&":^:(2~:3!:0) Ver
  t=. ((*#x){::;:'GET POST'),' ',path
  if. (0=#Ver)+.'0.9'-:Ver do.
    if. #x do. Ver=: '1.0'
      else. t,CRLF return. end. end.
  t=. t,' HTTP/',Ver,CRLF
  t=. t,'Accept: */*',CRLF
  t=. t,'Host: ',host,CRLF
  if. #Lang  do. t=. t,'Accept-Language: ',Lang,CRLF end.
  if. #Agent do. t=. t,'User-Agent: ',Agent,CRLF end.
  if. #Ref   do. t=. t,'Referrer: ',Ref,CRLF end.
  if. #Conn  do. t=. t,'Connection: ',Conn,CRLF end.
  if. #Heads do.     for_h. Heads do. 'n v'=. h
                 t=. t,n,': ',v,CRLF end. end.
  if. #x     do. t=. t,'Content-Length: ',(":#x),CRLF end.
                 t=. t,CRLF
  if. #x do.     t=. t,x     end.
  t
)

parseUrl=: 3 : 0
  if. #i=. '://' I.@E. y do.
    if. -.'http'-:prot=. i{.y do.
      _1 [ log 'unsuported protocol ',prot return.
    end.
    y=. 7}.y
  end.
  if. (#y)<:i=. y i.'/' do.
    y=. y,'/'
  end.
  'host path'=. i ({. ; }.) y
  port=. Port
  if. (#y)>i=. host i.':' do.
    port=. Port>.{.0 ".host}.~>:i
    host=. i{.host
  end.
  host ; port ; path
)

trim=: 3 : 0
  if. -.'HTTP/'-:5{.y do.
    y return. end.
  p=. (CRLF,CRLF) (E.i.1:) y
  head=. p {. y
  body=. (p+4) }. y
  if. -. 'Transfer-Encoding: chunked'+./@E.head do.
    body return. end.
  r=. ''
  while. #body do.
    p=. CRLF (E.i.1:) body
    s=. {.0 ".'16b',p{.body
    p=. p+2
    r=. r, (p,:s) ];.0 body
    body=. (p+s+2) }.  body
  end.
  r
)

NB. =========================================================
NB. sockets

init=: 3 : 0
  log=: [: fappend&Log ,&LF
  sccleanup ''
)

finilize=: 3 : 0
  sdclose y
  sccleanup ''
)

connect=: 80&$: : (4 : 0)
  ip=. scgethostbyname y
  sk=. scsocket ''
  scconnect sk;ip,<x
  sk
)

write=: 4 : 0
  sa=. '';(,y);'';Timeout
  nsa=. '' [ err=. 0
  while. *#x do.
    if. y e. swselect sa do.
      'err numsent'=. (ChunkSize upto x) sdsend y,0
      nsa=. nsa,numsent
      x=. numsent}.x
      if. err do. break. end.
    end.
  end.
  log (":nsa),'->',":y
  if. 0< err + #x do.
    log 'write underflow ',":err,#x end.
  err
)

read=: 3 : 0
  Timeout read y
  :
  z=. ''
  log (":y),'<-...'
  a=. Attempts
  while. 1 do.
    if. -. y e. srselect (,y);'';'';x do.
      if. a=. a-1 do.
        log '  .' continue. end.
      log '  read timeout'
      break.
    end.
    a=. Attempts
    if. 0=#d=. readblock y do. break. end.
    z=. z,d
  end.
  log '-|',(":y,#z)
  z
)

readblock=: 3 : 0
  if. 0=n=. scioctl y,FIONREAD,0 do.
    log '  read oef'
    '' return.
  end.
  'error d'=. sdrecv y,n
  if. error+.0=#d do.
    log '  read error/oef'
    '' return.
  end.
  log '  ',":#d
  d
)

httpget_z_=: httpget_phttpget_

NB. =========================================================
soapBody=: 0 : 0
<?xml version="1.0" encoding="UTF-8"?>
<SOAP-ENV:Envelope
  xmlns:xsd="http://www.w3.org/2001/XMLSchema"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/"
  SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"
  xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">
<SOAP-ENV:Body>
  <m:DoR xmlns:m="http://schemas.microsoft.com/clr/nsassem/JDLLServerLib/JDLLServerLib%2C%20Version%3D3.0.0.0%2C%20Culture%3Dneutral%2C%20PublicKeyToken%3D4a20487b5a2222ad">
    <input xsi:type="xsd:string">%1</input>
  </m:DoR>
</SOAP-ENV:Body>
</SOAP-ENV:Envelope>
)

soapTest=: 3 : 0
  require 'regex'
  Heads_phttpget_=: ,:'SoapAction';'http://schemas.microsoft.com/clr/nsassem/JDLLServerLib.JDLLServerClass/JDLLServerLib#DoR'
  q=. soapBody rplc '%1';y
  r=. q httpget'http://localhost/JApp/JDLLServer.3.soap'
  '<v [^>]+>([^<]+)</v>' (,.@{:@rxmatch ];.0 ]) r
)

NB. =========================================================
0 : 0
Ver_phttpget_=: '0.9'
httpget 'ichart.finance.yahoo.com/table.csv?s=^DJI&a=07&b=7&c=2006&d=07&e=11&f=2006'
httpget 'http://www.jsoftware.com/jwiki/Scripts/HTTP_Get?action=AttachFile&do=get&target=httpget.ijs'
httpget 'http://www.jsoftware.com/jwiki/RecentChanges?action=rss_rc&ddiffs=1&unique=1'
httpget 'www.jsoftware.com'

Ver_phttpget_=: '1.0'
httpget 'http://minutewar.gpsgames.org:80/Game032/board.htm'

Ver_phttpget_=: '1.1'  NB. process Transfer-Encoding: chunked
Attempts_phttpget_=: 2  NB. shorten end wait
httpget 'www.jsoftware.com:80/cgi-bin/fortune.cgi'

NB. POST queries

'action=rss_rc&ddiffs=1&unique=1&items=1' httpget 'http://www.jsoftware.com/jwiki/RecentChanges'

q=. 'all=httpget&exa=&one=&exc=&add=&sub=&fid=&tim=0&rng=0&dbgn=1&mbgn=1&ybgn=1998&dend=31&mend=12&yend=2007'
q httpget 'http://www.jsoftware.com/cgi-bin/forumsearch.cgi'

soapTest_phttpget_']a=: i.2 3'
soapTest_phttpget_'+/ a'
)
