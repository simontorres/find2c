procedure find2c (lio) 

        string  lio             {"@objetos",prompt="List of observed spectra"}
	string	lit		{"@template",prompt="List of templates"}
        string  spa             {"A",prompt="Output spectrum of the primary star"}
        string  spb             {"B",prompt="Output spectrum of the secondary star"}
	real	vo		{25,prompt="vgamma"}
	real	q1		{0.02,prompt=" q min"}
	real	q2		{0.5,prompt=" q max"}
	real	dq		{0.01,prompt="delta q"}
	string	sam		{"*",prompt="spectral regions"}
        string  *flist
begin
        real     x,y,z,v0,q,lo1,lo2,bb, tb,tt
        string   li1, sp1, spo, list, lit1, tem,sa
	int	j,nord,npix

del("tmp/lio,tmp/lit",ver-,>& "dev$null")
li1="tmp/lio"
lit1="tmp/lit"
files (lio, >li1)
files (lit,>lit1)

hedit("@"//li1,"apnum1","1 1",up+,show+,del-,ver-,>& "dev$null")
hedit("@"//lit1,"apnum1","1 1",up+,show+,del-,ver-,>& "dev$null")
v0=vo
sa=sam

#deberia chequearse que q2>q1, espectros existan y que todos tengan vra en header
#sacar las extensiones
#usar vsini para ensanchar espectros antes de hacer el producto para detectar compañeras con alta rotacion

for (q=q1; q<=q2; q= q + dq){
	flist=li1
	while (fscan (flist, spo) !=EOF) {
	imgets (spo, "VRA")
	x=real(imgets.value)
	y = v0 - (x-v0)/q
#	print("vra=",x,"vrb=",y,q)
	hedit(spo, "VRB", y,add+,up+,show-,del-,ver-)
#	hedit(spo, "VRB,VRA", ".", up-, show+)
	}
print("calculating B spectrum for q=",q)
del(spb//q//".fits",ver-,>& "dev$null")
spbina(li1, spa=spa, spb=spb//q, nit=1, all-,>& "dev$null")
}# end for q

#Calculation of the spectral windows spectrum
print ("apodizing spectral windows")
j=strlen (sa)
for (i=1; i<=j; i+=10) {
lo1=real(substr (sa,i,i+3))
lo2=real(substr (sa,i+5,i+8))
del("tmp/part*", ver- ,>& "dev$null")
scopy (spo,"tmp/part",w1=lo1,w2=lo2,merge-,ver-)
imreplace ("tmp/part",val=1,imagi=0,low=INDEF,upp=INDEF,rad=0)
#splot ("tmp/part")

imgets ("tmp/part","i_naxis1")
npix=real(imgets.value)
nord=int(npix/200.)
#print ("npix=",npix,"nord=",nord)
del("tmp/amortigua*", ver- ,>& "dev$null")
flpr
del("amortigua.fits", ver- ,>& "dev$null")
imexpr ("(abs(real(I)/"//npix//"-0.5)>0.4) ? 0.5*(1.-cos(real(I)*10.*3.14159/"//npix//")) : 1","amortigua",
 dims=npix,>& "dev$null")
#splot ("amortigua")
del("tmp/spo"//i//"*", ver- ,>& "dev$null")



#print("Extraccion de la region "//lo1//"-"//lo2//" ")
imarith("tmp/part","*","amortigua","tmp/spo"//i,calctype=1,ver-)

flpr
} #fin del for


del("amortigua.fits", ver- ,>& "dev$null")
scombine ("tmp/spo*","amortigua",reje-,comb="sum",grou="all", aper="",log+,blank=0,>& "dev$null")
#splot ("amortigua")

#Filtering and apodizing
print ("Filtering and apodizing")
	for (q=q1; q<=q2; q= q + dq){
continuum(spb//q,out=spb//q,type="diff",func="spline3",ord=nord,low=2.8,high_r=3.5,
         nite=5,band="*",lines="*",replace-,inte-,ov+)
del ("a"//spb//q//"*",ver-)
sarith (spb//q,"*","amortigua","a"//spb//q)
#print("espectro a//spb//q=","a"//spb//q)
#splot ("a"//spb//q)
} #fin for q filtering&apodizing



#calculation of correlation
print("calculating f2c image")

flist=lit1
	while (fscan (flist, tem) !=EOF) {
del ("tmp/*"//tem//"*", ver-, >&"dev$null")
continuum(tem,out="tmp/a"//tem,type="diff",func="spline3",ord=nord,low=2.5,high_r=6,
         nite=5,band="*",lines="*",replace-,inte-,ov+)
	sarith ("tmp/a"//tem,"*","amortigua","tmp/a"//tem, clobb+)
	sarith("tmp/a"//tem, "*", "tmp/a"//tem, "tmp/2"//tem)
imstat ("tmp/2"//tem,field="mean",low=INDEF,upp=INDEF,ncli=0,format-)|scan(tt)
print ("template=",tem)
	for (q=q1; q<=q2; q= q + dq){
	del ("tmp/*"//spb//q//"*", ver-, >&"dev$null")
	sarith("a"//spb//q,"*","a"//spb//q,"tmp/2"//spb//q)
	sarith("tmp/a"//tem,"*","a"//spb//q,"tmp/"//tem//spb//q)
#splot ("tmp/"//tem//spb//q)
#splot ("tmp/2"//spb//q)
	imstat ("tmp/"//tem//spb//q,field="mean",low=INDEF,upp=INDEF,ncli=0,format-)|scan(tb)
	imstat ("tmp/2"//spb//q,field="mean",low=INDEF,upp=INDEF,ncli=0,format-)|scan(bb)
#	print ("tb=",tb)
#	print ("bb=",bb)
	printf("%10.6f %12.6f\n", q, tb/sqrt(bb)/sqrt(tt),>>"tmp/dat"//tem)
	}
imdel ("q"//tem,ver-,>&"dev$null")
rspect ("tmp/dat"//tem, "q"//tem, dtyp="nonli")
#splot ("tmp/q"//tem)
	}
imdel("f2c",ver-,>&"dev$null")
scopy ("q//@"//lit1, "f2c",renum+)

end
