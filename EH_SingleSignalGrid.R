# Script for Single Signal Grid Density plots
# SVN: $Id: EH_SingleSignalGrid.R 653 2012-06-03 21:17:59Z rob $


library(sm)

INSTALL_DIR<-'/Users/rob'

setwd(paste(sep='',INSTALL_DIR,'/PhDStuff/ThesisSoftware/'))

#options(error=utils::recover)

# Set up timing code
source('UtilScripts/TimeUtils.R')
start<-now()

# Set up logging
source('UtilScripts/Logging.R')
log.filename<-paste(sep='',INSTALL_DIR,'/PhDStuff/ThesisSoftware/Logs/SSG-TLC.log')
log.level<-3


# Some global vars
BSG.results.dir<-paste(sep='',INSTALL_DIR,'/PhDStuff/ThesisSoftware/BaseSetGenerator/output2')

SSG.output.dir<-paste(sep='',INSTALL_DIR,'/PhDStuff/RobDonaldThesis/MedicalBackground/images')


# imageWidth<-130
# imageHeight<-130
# dpiRes<-600

#imageWidth<-100/25.4
#imageHeight<-100/25.4

imageWidth<-135/25.4
imageHeight<-135/25.4

measure.names<-c('HRT','BPs','BPd','BPm','BPp')
#measure.names<-c('HRT')

window.size<-5

for(measure.var in measure.names)
{

#     plotFileName<-paste(sep='',SSG.output.dir,'/',measure.var,'_SSG.png')
#     bitmap(plotFileName,width=imageWidth,height=imageHeight,res= dpiRes,units='mm')
#     #par(mfrow=c(3,2), oma=c(2,2,2,2), mar=c(0.8,0.8,0.8,0.8),font.main=1,cex.main=1.2,cex.lab=1.5)
#     par(mfrow=c(3,2),font.main=1,cex.main=1.2,cex.lab=1.5)

    plotFileName<-paste(sep='',SSG.output.dir,'/',measure.var,'_SSG.pdf')
    pdf(plotFileName,width=imageWidth,height=imageHeight,pointsize=10)
    #par(mfrow=c(3,2),font.main=1,cex.main=0.8,cex.lab=1.2)
    #par(mfrow=c(3,2),font.main=1,cex.main=1.2,cex.lab=1.5)
    par(mfrow=c(3,2),font.main=1,cex.main=1.2,cex.lab=1.5,cex.axis=1.2, mar=c(2.5,2.5,3,2))
       
        for(event.horizon in seq(10,30, by=5))
        {
           input.BDS<-paste(sep='',BSG.results.dir,'/BDS_',event.horizon,'_',window.size,'.csv')
    
            cat('input.BDS:',input.BDS,'\n')
            # Read in the BDS file
            all.cases<-read.table(input.BDS,header=T, sep=",", na.strings="NA", dec=".", strip.white=TRUE)
            pos.cases<-all.cases[all.cases$case_label == 1,]
            neg.cases<-all.cases[all.cases$case_label == 0,]
            cat('pos, neg\n')
            
            ylimits<-c(0,0.04)
            units<-''
            if(measure.var == 'HRT')
            {
                ylimits<-c(0,0.025)
                xlimits<-c(0,200)
                #units<-'beats/min'
                units<-''
            }
            else
            {
                xlimits<-c(0,300)
                units<-'mmHg'
            }
            attach(pos.cases)
                measure.pos<-get(paste(sep='',measure.var,'_spot_',event.horizon,'_',window.size))
                densityCalc<-sm.density(na.omit(measure.pos),col='red', xlab=units,ylab='', rugplot=F, ylim=ylimits,xlim=xlimits)
                
                modeCalc<-densityCalc$eval.points[order(densityCalc$estimate)]
                modeIndex<-length(modeCalc)
                modeLine.pos<-modeCalc[modeIndex]
                abline(v=modeLine.pos,lty=2,lwd=0.5)
                cat('pos ... complete\n')
            detach(pos.cases)

            attach(neg.cases)
                measure.neg<-get(paste(sep='',measure.var,'_spot_',event.horizon,'_',window.size))
                densityCalc<-sm.density(na.omit(measure.neg),col='black',add=T, ylim=ylimits,xlim=xlimits)
                
                modeCalc<-densityCalc$eval.points[order(densityCalc$estimate)]
                modeIndex<-length(modeCalc) 
                modeLine.neg<-modeCalc[modeIndex]
                abline(v=modeLine.neg,lty=4,lwd=0.5)
                cat('neg ... complete\n')
    
            detach(neg.cases)
            
            mode.sep<-(modeLine.pos-modeLine.neg)
         
            title(paste(sep='', measure.var,' - EH:',event.horizon, '; Separation: ',sprintf('%.2f',mode.sep)),cex.main=1.2)
              
        }
        
        par(mar=c(0.5,0.5,0.5,0.5))
        plot(1, type="n", axes=F, xlab="", ylab="") 
        legend('center',fill=c('red','black'),legend=c('positive cases','negative cases'),cex=1.5, bty='n')

    dev.off()
}

end<-now()
timeInfo<-ElapsedTime(start,end)
LogWrite(unlist(timeInfo$printStr),0)
