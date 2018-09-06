from pyraf import iraf
import os
import glob
import asciitable
import numpy as np
from scipy.interpolate import griddata
import matplotlib.pyplot as plt

#cargo paquetes  
iraf.noao.rv()
iraf.task(fn2="iraf/find2c.cl")
iraf.task(spbina="iraf/spbina.cl")
iraf.task(scale="iraf/scale.cl")
iraf.noao.onedspec()
iraf.noao.imred()
iraf.noao.ccdred()
iraf.noao.echelle()

def f2c(res_tem="S",step_tem=100): # es el programa en si, todo en iraf
  #valores para los template
  if res_tem=="h" or res_tem=="H":
    lit="@template"
    print("Working with template spectra in hihg resolution")
  else:
    lit="@template"
    print("Working with template spectra in low resolution")

  #parametros de entrada
  lio="@objetos"
  lit="@template"
  spa="A"
  spb="B"
  vo=24.86
  q1=0.1
  q2=0.7
  dq=0.05
  sam="4120-4340,4360-4840,4880-5700"
  flist="tmp/lit"
  
  #ejecuto fn2
  iraf.fn2(lio=lio,lit=lit,spa=spa,spb=spb,vo=vo,q1=q1,q2=q2,dq=dq,sam=sam,flist=flist) 
  os.chdir("tmp")
  
  #recupero los datos de fn2
  archivos=glob.glob("datT*") #archivos de salida de f2c
  temps=[]
  pasos=[]
  intensidad=[]
  for archivo in archivos:
    temp=float(archivo[4:])
    data = asciitable.read(archivo)
    for paso,inte in zip(data["col1"],data["col2"]): #recupero de los archivos la info que necesito
      #print temp,paso,inte
      temps.append(temp)
      pasos.append(paso)
      intensidad.append(inte)
  return temps,pasos,intensidad    
      


def gen_ar():
  #cargo resultado de f2c
  temps,pasos,intensidad=f2c(res_tem="S",step_tem=100)
  x=pasos
  y=temps
  z=intensidad
  print(x[z.index(max(z))],y[z.index(max(z))])
  os.chdir("../")
  # obtengo parametros para para fxcor
  obfx="aB"+str(x[z.index(max(z))])
  temp=str(int(y[z.index(max(z))]))
  if len(temp)==4:
    temp="0"+temp
  iraf.imdel("ss")
  iraf.imdel("tem")
  iraf.sarit("T"+temp,"-",1,"ss")
  iraf.sarit("ss","*","amortigua","tem")
  fig = plt.figure(figsize = (12,9.0))
  fig.subplots_adjust(hspace=0.4, bottom=0.06, top=0.94, left=0.12, right=0.94)
  
  #ejecuto y ploteo fxcor
  ax2 = plt.subplot2grid((4,1), (0,0)) # grafico la func, de correlacion

  program_dir = os.getcwd() + "/"
  ccf_command = program_dir + "fxcor_cursor_command.txt" #comando para extraeer los datos del grafico
  interact = 1
  iraf.imdel("new_ccf.txt")
  iraf.fxcor(object=obfx,templates="tem",cursor=ccf_command,ccftype = "text",interactive=interact) #fxcor de irad
  data = asciitable.read("new_ccf.txt") #archivo de salida del fxcor
  ax2.set_xlim(-2000,2000)
  plt.axhline(linewidth=2, color='r')
  plt.plot(data["col1"],data["col2"],"-",color="black")
  plt.axvspan(-100, 100, facecolor='grey', alpha=0.5)
  #plt.axhspan(0.9, 1.00, facecolor='grey', alpha=0.5)
  ax2.yaxis.set_major_locator(plt.MaxNLocator(5))
  ax2.set_xlabel(r'Velocity',fontsize=18)
  ax2.set_ylabel(r'Correlation',fontsize=18)
  
  #datos para scale
  iraf.imdel("scale")
  iraf.imdel("tplsca")
  obscale="B"+str(x[z.index(max(z))])
  temp="T"+temp
  w1=5900
  w2=6490
  wi=300
  iraf.imdel("scale.txt")
  iraf.imdel("tplsca.txt")
  iraf.scale(spec=obscale,tpl=temp,w1=w1,w2=w2,width=wi)
  iraf.wspectext("scale.fits","scale.txt",header="no")
  iraf.wspectext("tplsca.fits","tplsca.txt",header="no")
  iraf.wspectext(obscale,"obscale.txt",header="no")
  

  
  #ploteo resultados de f2c
  ax1 = plt.subplot2grid((4,1), (1,0), rowspan=3)
  # define grid.
  xi = np.linspace(min(x),max(x),1000)
  yi = np.linspace(min(y),max(y),1000)
  # grid the data.
  zi = griddata((x, y), z, (xi[None,:], yi[:,None]), method='linear')
  # contour the gridded data, plotting dots at the randomly spaced data points.
  CS = plt.contour(xi,yi,zi,15,linewidths=0.5,colors='k')
  CS = plt.contourf(xi,yi,zi,15,cmap=plt.cm.jet)
  cb=plt.colorbar(orientation = 'horizontal',pad=0.1,aspect=30) # draw colorbar
  cb.set_label('Intensity',fontsize=18)
  # plot data points.
  plt.scatter(x,y,marker='o',c='b',s=5)
  plt.scatter(x[z.index(max(z))],y[z.index(max(z))],marker='o',color="w",s=20)
  plt.xlabel('Mass ratio')
  plt.ylabel('Secondary Temperature (K)')
  ax1.set_xlabel(r'Mass ratio',fontsize=18)
  ax1.set_ylabel(r'Secondary Temperature (K)',fontsize=18)
  ax1.set_xlim(min(pasos),max(pasos))
  ax1.set_ylim(min(temps),max(temps))
  ax1.yaxis.set_major_locator(plt.MaxNLocator(6))
  ax1.xaxis.set_major_locator(plt.MaxNLocator(8))
  
  ax2.text(0.03, 0.96,"T=%s K"%y[z.index(max(z))],ha='left', va='top',transform=ax2.transAxes,fontsize=20)
  ax2.text(0.04, 0.5,"q=%s"%x[z.index(max(z))],ha='left', va='top',transform=ax2.transAxes,fontsize=20)
  
  
  #plot scale
  fig = plt.figure(figsize = (12,9.0))
  fig.subplots_adjust(hspace=0.4, bottom=0.06, top=0.94, left=0.12, right=0.94)
  ax2 = plt.subplot2grid((4,1), (0,0))  
  
  data = asciitable.read("tplsca.txt") #archivo de salida del scale
  #ax2.set_xlim(min(data["col1"]),max(data["col1"]))
  plt.plot(data["col1"],data["col2"],"-",color="red")
  data = asciitable.read("obscale.txt")
  plt.plot(data["col1"],data["col2"],"-",color="black")
  ax2.yaxis.set_major_locator(plt.MaxNLocator(5))
  ax2.set_xlabel(r'Wavelength ($\AA$)',fontsize=18)
  ax2.set_ylabel(r'Intensity',fontsize=18)  
  
  data = asciitable.read("scale.txt") #archivo de salida del scale
  ax2.set_xlim(min(data["col1"]),max(data["col1"])-1)
  plt.plot(data["col1"],data["col2"]*100,"-",color="black")
  ax2.yaxis.set_major_locator(plt.MaxNLocator(5))
  ax2.set_xlabel(r'Wavelength ($\AA$)',fontsize=18)
  ax2.set_ylabel(r'$I_2/I_T$ (%)',fontsize=18)
  
  

  
  #plt.savefig('mass_temp.pdf',format="pdf", bbox_inches='tight',dpi = 300)
  plt.show()


if __name__ == '__main__':
  gen_ar()
  