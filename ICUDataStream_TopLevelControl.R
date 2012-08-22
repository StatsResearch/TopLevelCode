# Script for ICU Data Stream Top Level Control
# SVN: $Id: ICUDataStream_TopLevelControl.R 630 2012-05-20 21:50:38Z rob $


DEBUG<-FALSE

# This is all you can alter

if(DEBUG == TRUE)
{
    event.horizon<-10
    window.size<-5
    model.name<-'Full'
    score.type<-'AUC'
}

# -------------

INSTALL_DIR<-'/Users/rob'
setwd(paste(sep='',INSTALL_DIR,'/PhDStuff/ThesisSoftware/'))

# Set up timing code
source('UtilScripts/TimeUtils.R')
start<-Sys.time()

if(DEBUG == FALSE)
{
    cmd.args<-commandArgs(TRUE);
    all.args<-'Command Line Args:'
    index<-0
    for (arg in cmd.args)
    {
        index<-index+1
        all.args<-paste(sep=',', all.args,':index = ', index, '  ', arg)
    }
    
    for (arg in cmd.args) cat("  ", arg, "\n", sep="")
    
    # cmd.args[1] style, EH=10
    event.horizon<-as.numeric(strsplit(cmd.args[1],'=')[[1]][2])
    cat("---> event.horizon: ", event.horizon, "\n", sep='')
    
    # cmd.args[2] style, WS=10
    window.size<-as.numeric(strsplit(cmd.args[2],'=')[[1]][2])
    cat("---> window.size: ", window.size, "\n", sep='')
    
    # cmd.args[3] style, model.name=FullQuadMean
    model.name<-'NOT-SET'
    model.name<-strsplit(cmd.args[3],'=')[[1]][2]
    cat("---> model.name: ", model.name, "\n", sep='')
    
    # cmd.args[4] style, score.type=AUC or H_Score
    score.type<-'NOT-SET'
    score.type<-strsplit(cmd.args[4],'=')[[1]][2]
    cat("---> score.type: ", score.type, "\n", sep='')
}

# Set up logging
source('UtilScripts/Logging.R')
hostname<-system('hostname',intern=T)
smallname<-unlist(strsplit(hostname,'\\.'))[1]
log.filename<-paste(sep='',INSTALL_DIR,'/PhDStuff/ThesisSoftware/Logs/ICUDataStream-TLC-output-',smallname,'-MN-',model.name,'.log')
log.level<-3

# Start things off 
LogWrite('ICUDataStream_TopLevelControl.R Starting ...',3)

if(DEBUG == FALSE)
{
    # Log the command line arguments
    LogWrite(paste('all.args',all.args),3)
}

setwd(paste(sep='',INSTALL_DIR,'/PhDStuff/ThesisSoftware/'))
# Load the working files
setwd("./ICUDataStream")
source('ICUDataStream.R')

ICUDataStream.results.dir<-paste(sep='',INSTALL_DIR,'/PhDStuff/ThesisSoftware/ICUDataStream/output/MN_'
                                    ,model.name,'_',event.horizon,'_', window.size)
dir.create(ICUDataStream.results.dir)

model.dir<-paste(sep='',INSTALL_DIR,'/PhDStuff/ThesisSoftware/LRModels/output_',event.horizon,'/MN_',model.name)
msg<-paste(sep='','ICUDataStream model.dir: ', model.dir) 
cat(sep='',msg, '\n') 
LogWrite(msg,3)
setwd(model.dir)

median.model<-paste(sep='','Median_',score.type,'_Model_*_',event.horizon,'_',window.size,'_Index_*.rda')

median.model.file<-Sys.glob(median.model)
cat(sep='','ICUDataStream using model file: ', median.model.file) 
LogWrite(median.model.file,3)

if(length(median.model.file) != 1)
{
    msg<-'\n\nERROR! ICUDataStream length(median.model.file) != 1' 
    cat(msg,'\n') 
    LogWrite(msg,0)
    quit(save='no',status = -2)
}

# Loading a pre-saved model ... NOTE: the get() after the load()
model.name.from.file<-load(median.model.file)
LogWrite(model.name.from.file,3)
model.to.use<-get(model.name.from.file)
#summary(model.to.use)

ICUDataStream.patient.dir<-paste(sep='',INSTALL_DIR,'/PhDStuff/BrainIT/Rel_2011')
#ICUDataStream.patient.dir<-paste(sep='',INSTALL_DIR,'/PhDStuff/BrainIT/DEBUG_Rel_2011')
msg<-paste(sep='','ICUDataStream using patient data from: ', ICUDataStream.patient.dir) 
cat(sep='',msg, '\n') 
LogWrite(msg,3)

setwd(ICUDataStream.patient.dir)
buffer.full<-0.8

filenames<-list.files(pattern='*.sdb')
for(patient.db in filenames)
{
    # Has this file already been processed
    db.name.stem<-substr(patient.db,1,nchar(patient.db)-4)
    ICUDataStream.results.file<-paste(sep='',ICUDataStream.results.dir,'/ICU-DataStream-',db.name.stem,'.csv')
    if (file.exists(ICUDataStream.results.file) == FALSE)
    {
        cat(paste(sep='','Still to process: ', patient.db,'\n'))
        SimPatientStay(patient.db,ICUDataStream.results.dir,event.horizon,window.size,buffer.full,model.to.use)
    }
    else
    {
        cat(paste(sep='','Already processed: ', patient.db,'\n'))
    }
}
end<-Sys.time()
timeInfo<-ElapsedTime(start,end)
LogWrite(unlist(timeInfo$printStr),0)
#Rprof(NULL)
