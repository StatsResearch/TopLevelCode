# Script for TTG Top Level Control for the All Data model
# SVN: $Id: TTG_TopLevelControl_All_Data.R 621 2012-05-13 22:24:10Z rob $

DEBUG<-FALSE

# This is all you can alter

if(DEBUG == TRUE)
{
    event.horizon<-15

    num.bootstrap.repeats<-10

    percent.training.ids<-50
    percent.positive<-10
}

# -------------

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
    
    # cmd.args[2] style, num.bootstrap.repeats=10
    num.bootstrap.repeats<-10
    if (length(cmd.args) == 2)
    {
        num.bootstrap.repeats<-as.numeric(strsplit(cmd.args[2],'=')[[1]][2])
    }
    cat("---> num.bootstrap.repeats: ", num.bootstrap.repeats, "\n", sep='')
    
    # cmd.args[3] style, percent.training.ids=50
    percent.training.ids<-50
    if (length(cmd.args) == 3)
    {
        percent.training.ids<-as.numeric(strsplit(cmd.args[3],'=')[[1]][2])
    }
    cat("---> percent.training.ids: ", percent.training.ids, "\n", sep='')
    
    # cmd.args[4] style, percent.positive=10
    percent.positive<-10
    if (length(cmd.args) == 4)
    {
        percent.positive<-as.numeric(strsplit(cmd.args[3],'=')[[1]][2])
    }
    cat("---> percent.positive: ", percent.positive, "\n", sep='')
    
}


INSTALL_DIR<-'/Users/rob'
setwd(paste(sep='',INSTALL_DIR,'/PhDStuff/ThesisSoftware/'))

# Set up timing code
source('UtilScripts/TimeUtilsNoLubridate.R')
start<-Sys.time()

# Set up logging
source('UtilScripts/Logging.R')
hostname<-system('hostname',intern=T)
smallname<-unlist(strsplit(hostname,'\\.'))[1]
log.filename<-paste(sep='',INSTALL_DIR,'/PhDStuff/ThesisSoftware/Logs/TTG-TLC-output-',smallname,'-EH-',event.horizon,'-all-data.log')
log.level<-3

LogWrite('TopLevelControl_All_Data.R Starting ...',3)

# Some global vars
BSG.results.dir<-paste(sep='',INSTALL_DIR,'/PhDStuff/ThesisSoftware/BaseSetGenerator/output_all_data_',event.horizon)

TTG.output.dir<-paste(sep='',INSTALL_DIR,'/PhDStuff/ThesisSoftware/TrgTestGenerator/output_all_data_',event.horizon)
dir.create(TTG.output.dir)

# Process the data files
setwd("./TrgTestGenerator")
source('TTG.R')

LogWrite(paste(sep='','BSG.results.dir: ',BSG.results.dir),0)
setwd(BSG.results.dir)

window.size<-'30_all_data'


BDS.file<-paste(sep='','BDS_',event.horizon,'_',window.size,'.csv')

for(sequence.code in 1:num.bootstrap.repeats)
{
    BDS.processing.stats<-GenerateTrgTestSets(BDS.file,TTG.output.dir,event.horizon,window.size,sequence.code,
                                                                            percent.training.ids,percent.positive)
}



end<-Sys.time()
timeInfo<-ElapsedTime(start,end)
LogWrite(unlist(timeInfo$printStr),0)
