procedure scale (spec)
        string  spec    {"",prompt="input spectrum"}
        string  tpl     {"tplK",prompt="spectrum for tpl"}
	real	w1	{5900,prompt="low limit of range for scaling"}
	real	w2	{6490,prompt="high limit of range for scaling"}
	real	width	{300,prompt="sigma kernel for averaging (km/s)"}

 begin
	real	alpha,wei1,ow1,sig5
	string	o1,sow1,stmp1,stmp2,stmp3,stmp4,stmp5,stmp6
	string	t1,so,st,ot,tt,stt,sot,fo,ft,wei,sca,sca1
	int     n,mm,mm2,k,mm1

del ("tmp$list*", ver-,>& "dev$null")
del ("tmp$*.fits", ver-,>& "dev$null")
o1="tmp$o1"
t1="tmp$t1"
so="tmp$so"
st="tmp$st"
ot="tmp$ot"
tt="tmp$tt"
stt="tmp$stt"
sot="tmp$sot"
fo="tmp$fo"
ft="tmp$ft"
sca="tmp$sca"
wei="tmp$wei"
sca1="scale.fits"

imcopy (spec,o1,v-)
imcopy (tpl,t1,v-)

stmp1="tmp$stmp1"
stmp2="tmp$stmp2"
stmp3="tmp$stmp3"
stmp4="tmp$stmp4"
stmp5="tmp$stmp5"
stmp6="tmp$stmp6"
del ("tmp$stmp*", ver-,>& "dev$null")


#calculo de n y m para el suavizado a partir del width

	dispcor(o1,"tmp$stmp1",log+,flux-,lin+,>& "dev$null")
        imgets ("tmp$stmp1", "cdelt1")
	sig5=(width/1543550./real(imgets.value))**2.
	k=1
	while(k*(k+1)<sig5){k=k+1} 
	mm=2*k+1
	n=int(15.*sig5/k/(k+1))
	mm1=2*mm
	mm2=10*mm

sari (o1,"*",t1,ot)
sari (t1,"*",t1,tt)

imcopy (o1,so,verb-)
for (i=1; i<=n; i+=1) boxcar(so,so,mm,1)
imcopy (t1,st,verb-)
for (i=1; i<=n; i+=1) boxcar(st,st,mm,1)
imcopy (ot,sot,verb-)
for (i=1; i<=n; i+=1) boxcar(sot,sot,mm,1)
imcopy (tt,stt,verb-)
for (i=1; i<=n; i+=1) boxcar(stt,stt,mm,1)

del ("tmp$stmp*", ver-,>& "dev$null")

sarith (st,"*",so,stmp1)
sarith (sot,"-",stmp1,stmp2) #stmp2 = numerador

sarith (st,"*",st,stmp3)
sarith (stt,"-",stmp3,stmp4) #stmp4 = denominador

sarith (stmp2,"/",stmp4,sca)

#calculo de peso(lambda) para factor de escala
del ("tmp$stmp*", ver-,>& "dev$null")
sarith (o1,"-",so,fo)
sarith (t1,"-",st,ft)
sarith (ft,"*",sca,stmp1)
sarith (fo,"-",stmp1,stmp2)
sarith (stmp2,"*",stmp2,stmp3) #denominador
sarith (ft,"*",ft,stmp4)
for (i=1; i<=n; i+=1) boxcar(stmp3,stmp3,mm1,1)
for (i=1; i<=n; i+=1) boxcar(stmp4,stmp4,mm1,1)
sarith (stmp4, "/", stmp3, wei) #peso


del ("tmp$stmp*", ver-,>& "dev$null")
sarith (sca,"*",wei,stmp1)
imcopy (stmp1,stmp2,v-)
for (i=1; i<=n; i+=1) boxcar(stmp2,stmp2,mm2,1)
imcopy (wei,stmp6,v-)
for (i=1; i<=n; i+=1) boxcar(stmp6,stmp6,mm2,1)

del (sca1, ver-,>& "dev$null")
sarith (stmp2,"/",stmp6,sca1)

del ("tmp$stmp*", ver-,>& "dev$null")
sarith (t1,"*",sca1,stmp1)
sarith (o1,"-",stmp1,stmp2)
continu (stmp2,stmp4,or=20,type="fit",func="spline3",low=3,hi=3,int+)
sarith (stmp1,"+",stmp4,"tplsca")

scopy (sca1,stmp5, w1=w1, w2=w2)
imstat(stmp5,fiel="mean",forma-) |scan(alpha)

print(alpha)





end
