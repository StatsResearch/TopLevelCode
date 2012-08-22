# Script for TTG Top Level Control
# SVN: $Id: TTG_TopLevelControl.R 494 2012-02-09 23:06:03Z rob $


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

# Read in the command line arguments
LogWrite('TopLevelControl.R Starting ...',3)
LogWrite('-- reading arguments',3)

cmd.args<-commandArgs(TRUE);
all.args<-'Command Line Args:'
for (arg in cmd.args)
{
    all.args<-paste(sep='', all.args, '  ', arg);
}

# Some global vars
BSG.results.dir<-paste(sep='',INSTALL_DIR,'/PhDStuff/ThesisSoftware/BaseSetGenerator/output')

SSG.output.dir<-paste(sep='',INSTALL_DIR,'/PhDStuff/RobDonaldThesis/MedicalBackground/images')


imageWidth<-130
imageHeight<-130
dpiRes<-600

measure.names<-'HRT'

# DEBUG
# Read in the BDS file
input.BDS<-paste(sep='',BSG.results.dir,'/BDS_',10,'_',5,'.csv')
all.cases<-read.table(input.BDS,header=T, sep=",", na.strings="NA", dec=".", strip.white=TRUE)
pos.cases<-all.cases[all.cases$case_label == 1,]
neg.cases<-all.cases[all.cases$case_label == 0,]

for(measure in measure.names)
{

    plotFileName<-paste(sep='',SSG.output.dir,'/',measure,'_SSG.png')
    bitmap(plotFileName,width=imageWidth,height=imageHeight,res= dpiRes,units='mm')
    par(mfrow=c(5,6), oma=c(5,5,5,5), mar=c(0.2,0.2,0.2,0.2),font.main=1,cex.main=1.2,cex.lab=1.5)
    
    for(window.size in seq(5,30,by=5))
    {
        
        for(event.horizon in seq(10,30, by=5))
        {
           #  input.BDS<-paste(sep='',BSG.results.dir,'/BDS_',event.horizon,'_',window.size,'.csv')
#     
#             # Read in the BDS file
#             all.cases<-read.table(input.BDS,header=T, sep=",", na.strings="NA", dec=".", strip.white=TRUE)
#             pos.cases<-all.cases[all.cases$case_label == 1,]
#             neg.cases<-all.cases[all.cases$case_label == 0,]
#     
#             sm.density(na.omit(pos.cases$HRT_mean_10_5),col='red',xlab='',ylab='')
#             sm.density(na.omit(neg.cases$HRT_mean_10_5),col='black',add=T)
            
            plot(density(na.omit(neg.cases$HRT_mean_10_5)),axes=FALSE, frame.plot=TRUE,xlab='',ylab='',main='',col='black')
            lines(density(na.omit(pos.cases$HRT_mean_10_5)),col='red')
           
            
        }
        
    }
    
    mtext(outer=T,adj=0,text='    30                   25                    20                    15                    10',side=2)
    mtext(outer=T,text='Event Horizon',side=2,line=2)
    
    mtext(outer=T,adj=0,text='  5                  10                 15                 20                 25                   30',side=3)
    mtext(outer=T,text='Window Size',side=3,line=2)
    mtext(outer=T,text='HRT - Single Signal Grid', side = 1, cex=1.2, line = 3)

    dev.off()
}

end<-now()
timeInfo<-ElapsedTime(start,end)
LogWrite(unlist(timeInfo$printStr),0)
