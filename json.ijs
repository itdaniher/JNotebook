coclass 'json'
enc_json=: 3 : 0
select. t=. 3!:0 y
case. 2;131072 do.
  if. y-:'json_true' do. 'true'
  elseif. y-:'json_false' do. 'false'
  elseif. y-:'json_null' do. 'null'
  elseif. do.
    '"', '"',~ jsonesc utf8^:(131072=t) ,y
  end.
case. 1;4;8 do.
  ":!.17 {.,y
case. 32 do.
  if. 2>$$y do.
    if. 0=#y do.
      '[]'
    else.
      s=. '['
      for_v. y do.
        s=. s , ',',~ enc_json >v
      end.
      ']',~ }:s
    end.
  elseif. 2=$$y do.
    assert. 0 2 e.~ {.$y
    if. 0=#y do.
      '{}'
    else.
      s=. '{'
      for_i. i.{:$y do.
        s=. s , ':',~ enc_json (<0,i){::y
        s=. s , ',',~ enc_json (<1,i){::y
      end.
      '}',~ }:s
    end.
  elseif. do. 13!:8[3
  end.
case. do. 13!:8[3
end.
)
JSONESC0=: LF, CR, TAB, FF, (8{a.), '\/"'
JSONESC1=: 'nrtfb\/"'
JSONASC=: JSONESC0, 32}.127{.a.
jsonesc=: 3 : 0
txt=. y
msk=. txt e. JSONESC0
if. 1 e. msk do.
  ndx=. , ((I. msk) + i. +/ msk) +/ 0 1
  new=. , '\',.JSONESC1 {~ JSONESC0 i. msk#txt
  txt=. new ndx } (1 + msk) # txt
end.
msk=. -. txt e. JSONASC
if. 1 e. msk do.
  new=. 'u',"1 '0123456789abcdef' {~ 16 16 16 16 #: a. i. msk # txt
  ndx=., ((I. msk) + 5 * i. +/ msk) +/ i. 6
  txt=. (, '\',("1) new) ndx } (1 + msk * 5) # txt
end.
txt
)
classes=. 3<. '"\[],{}:' (#@[ |&>: i.) a.
classes=. 0 (I.a.e.' ',CRLF,TAB)} (]+4*0=])classes

words=: (0;(0 10#:10*".;._2]0 :0);classes)&;:
  0.0  1.1  2.1  3.1  4.1
  1.0  5.0  6.0  1.0  1.0
  4.0  4.0  4.0  4.0  4.0
  0.3  1.2  2.2  3.2  4.2
  0.3  1.2  2.0  3.2  4.0
  0.3  1.2  2.2  3.2  4.2
  1.0  1.0  1.0  1.0  1.0
)
jsonValue=: 3 : 0
if. 0=#y do. <y
elseif. 'true'-:y do. 'json_true'
elseif. 'false'-:y do. 'json_false'
elseif. 'null'-:y do. 'json_null'
elseif. '"'={. y do. evalbs }.}:y
elseif. '0123456789.+-' -.@e.~ {. y do. evalbs y
elseif. do. {. 0". 'Ee-_' charsub y
end.
)
subst2=: (_2<\'\"\\\/\b\f\n\r\t')&(i.{(34 92 47 8 12 10 13 9{&.><a.),])"0
hexchars=. 'ABCDEF0123456789abcdef'
dfh=: 16 #. 16 | _6 + hexchars i. ]
subst6=: (8 u:[:u:@dfh 2}.]) ::]^:(6&=@#*.('\'={.)*.'uU'e.~{.@}.)&.>

splitbs=: (0;(0 10#:10*".;._2]0 :0);(a.e.hexchars)+(2*a.='\')+3*a.e.'Uu')&;:
 1.1  1.1  2.1 1.1
 1.0  1.0  2.2 1.0
 3.0  3.0  3.0 4.0
 1.2  1.2  2.2 1.2
 1.2  5.0  2.2 1.2
 1.2  6.0  2.2 1.2
 1.2  7.0  2.2 1.2
 1.2  3.0  2.2 1.2
)
evalbs=: [:; [:subst2 [:subst6 splitbs^:(*@#)
'T_LBR T_RBR T_LCB T_RCB T_COM T_COL'=: ;:' [ ] { } , :'

token=: 3 : 0
(_1+I=: I+1){::T
)

dec_json=: 3 : 0
T=: words (LF,' ') charsub y-.CR
I=: 0
>getVal token''
)
getVal=: 3 : 0
select. y
case. T_LBR do. getList token''
case. T_LCB do. getHash token''
case. do. <jsonValue y
end.
)
getList=: 3 : 0
if. T_RBR -: y do. <0#<'' return. end.
r=. ,getVal y
while. -. T_RBR -: y=. token'' do.
  assert T_COM -: y
  r=. r,getVal token''
end.
<r
)
getHash=: 3 : 0
if. T_RCB -: y do. <0#0 0$<'' return. end.
r=. getPair y
while. -. T_RCB -: y=. token'' do.
  assert T_COM -: y
  r=. r,.getPair token''
end.
<r
)
getPair=: 3 : 0
h=. getVal y
assert T_COL -: token''
h,: getVal token''
)
gethash_json=: 4 : 0
assert. 2=$$y
assert. 32=3!:0 y
x=. ,&.> boxopen x
assert. 1=$x
if. ({.x) e. {.y do.
  ({:y){~({.y) i. {.x
else.
  _1
end.
)
emptyhash_json=: 3 : 0
(2=$$y) *. (0={.$y) *. 32=3!:0 y
)
emptyarray_json=: 3 : 0
(2>$$y) *. (0=#y) *. 32=3!:0 y
)
dec_json_z_=: dec_json_json_
enc_json_z_=: enc_json_json_
gethash_json_z_=: gethash_json_json_
emptyhash_json_z_=: emptyhash_json_json_
emptyarray_json_z_=: emptyarray_json_json_
