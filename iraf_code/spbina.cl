procedure spbina (li0) 

        string  li0             {prompt="List of observed spectra"}
        string  spa             {"A",prompt="Output spectrum of the primary star"}
        string  spb             {"B",prompt="Output spectrum of the secondary star"}
# Si B existe lo usa como primera aproximacion, si no existe parte de cero.
        int     nit             {4, prompt="Number of  iterations "}
	string	comb		{"average",prompt="Type of combine operation"}
	string 	reje		{"sigclip",prompt="Type of rejection"}
	bool	alls		{no, prompt="Calcula espectros para todas las fases?"}
#Por ahora lsig, hsig, niter de reject, etc ponerlos en el scom directamente
        string  *flist
begin
        real     x,y,z
        string   li1, sp1, spo, list

li1=li0
imdel ("tmp/ds-a//@"//li1,ver-,>& "dev$null")
imdel ("tmp/ds-b//@"//li1,ver-,>& "dev$null")
imdel ("tmp/A//@"//li1//",tmp/B//@"//li1, ver-,>& "dev$null")
del ("tmp/*.fits", ver-,>& "dev$null")

if (access(spb//".fits")) {
	flist=li1
	while (fscan (flist, spo) !=EOF) {
	imgets (spo, "VRB")
	x=-real(imgets.value)
	dopcor ( spb, "tmp/B"//spo, isvel+,red=x, add+, disper+)
	}
	sarith ("@"//li1, "-","tmp/B//@"//li1,"tmp/ds-b//@"//li1)
	} else
	imcopy ("@"//li1, "tmp/ds-b//@"//li1,>"dev$null") 


if (nit != 0){
for (i=1; i<= nit; i=i+1){
imdel ( "tmp/za//@"//li1//",tmp/zb//@"//li1//",tmp/A//@"//li1//",tmp/B//@"//li1,>& "dev$null")
imdel ("tmp/ds-a//@"//li1,ver-,>& "dev$null")
imdel (spa//","//spb,>& "dev$null")
dopcor ("tmp/ds-b//@"//li1, "tmp/za//@"//li1, red="VRA", isvel+, add+, disper+)
scombine ("tmp/za//@"//li1, spa, reje=reje, comb=comb, scale="none", group="all", logfile="", weight="")

flist=li1
while (fscan (flist, spo) !=EOF) {
imgets (spo, "VRA")
x=-real(imgets.value)
dopcor ( spa, "tmp/A"//spo, isvel+,red=x,add+, disper+)
}

sarith("@"//li1, "-", "tmp/A//@"//li1, "tmp/ds-a//@"//li1)
dopcor("tmp/ds-a//@"//li1, "tmp/zb//@"//li1, red="VRB", isvel+,add+, disper+)
scombine ("tmp/zb//@"//li1, spb, reje=reje, comb=comb, scale="none", group="all", logfile="", weight="")

flist=li1
while (fscan (flist, spo) !=EOF) {
imgets(spo, "VRB")
x=-real(imgets.value)
dopcor(spb,"tmp/B"//spo, isvel+,red=x,add+, disper+)
}
imdel("tmp/ds-b//@"//li1, ver-,>& "dev$null")
sarith("@"//li1, "-","tmp/B//@"//li1,"tmp/ds-b//@"//li1)


print ("calculo de espectros: iteracion ",i," terminada")
}
}
#esto es para cuando se quiere contruir los A+B sin recalcularlos: all+ nit=0
if (nit == 0){
	flist=li1
	while (fscan (flist, spo) !=EOF) {
	imgets (spo, "VRA")
	x=-real(imgets.value)
	dopcor ( spa, "tmp/A"//spo, isvel+,red=x,add+, disper+)
	}

	flist=li1
	while (fscan (flist, spo) !=EOF) {
	imgets (spo, "VRB")
	x=-real(imgets.value)
	dopcor ( spb, "tmp/B"//spo, isvel+,red=x,add+, disper+)
	}
}

if (alls == yes ){
imren ("tmp/ds-a//@"//li1,"ds-a//@"//li1)
imren ("tmp/ds-b//@"//li1,"ds-b//@"//li1)
imren ("tmp/A//@"//li1,"A//@"//li1)
imren ("tmp/B//@"//li1,"B//@"//li1)
sarith ("A//@"//li1,"+","B//@"//li1,"AB//@"//li1)

}
#imdel ("tmp/ds-a//@"//li1,ver-,>& "dev$null")
#imdel ("tmp/ds-b//@"//li1,ver-,>& "dev$null")
#imdel ("tmp/A//@"//li1//",tmp/B//@"//li1, ver-,>& "dev$null")
#imdel ( "tmp/za//@"//li1//",tmp/zb//@"//li1//",tmp/A//@"//li1,>& "dev$null")

end
