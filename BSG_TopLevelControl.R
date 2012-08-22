# Script for BSG Top Level Control
# SVN: $Id: BSG_TopLevelControl.R 620 2012-05-13 22:19:22Z rob $

DEBUG<-FALSE

# This is all you can alter

if(DEBUG == TRUE)
{
    event.horizon<-10
    window.size<-5
    buffer.full<-0.8
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
    
    # cmd.args[3] style, buffer.full=0.8
    buffer.full<-0.8
    if (length(cmd.args) == 3)
    {
        buffer.full<-as.numeric(strsplit(cmd.args[3],'=')[[1]][2])
    }
    cat("---> buffer.full: ", buffer.full, "\n", sep='')
    
    # cmd.args[4] style, all.data=TRUE
    all.data=FALSE
    if (length(cmd.args) == 4)
    {
        all.data.str<-strsplit(cmd.args[4],'=')[[1]][2]
        if(all.data.str == 'TRUE')
        {
            all.data<-TRUE
        }
    }
    cat("---> all.data: ", all.data, "\n", sep='')
    
}


# Set up logging
source('UtilScripts/Logging.R')
log.filename<-paste(sep='',INSTALL_DIR,'/PhDStuff/ThesisSoftware/Logs/BSG-TLC-output-',event.horizon,'-',window.size,'_all_data.log')
log.level<-3

# Some global vars
if(all.data == TRUE)
{
    BSG.results.dir<-paste(sep='',INSTALL_DIR,'/PhDStuff/ThesisSoftware/BaseSetGenerator/output_all_data_',event.horizon)
}else{
    BSG.results.dir<-paste(sep='',INSTALL_DIR,'/PhDStuff/ThesisSoftware/BaseSetGenerator/output_',event.horizon)
}

dir.create(BSG.results.dir)

# Process the data files
setwd("./BaseSetGenerator")
if(all.data == TRUE)
{
    source('BSG-All-Data.R')
}else{
    source('BSG.R')
}

setwd("../../BrainIT/EventDetectionDir")
filenames<-'PDB-26240484.sdb'
#filenames<-list.files(pattern='*.sdb')
total.files<-length(filenames)
file.count<-0
for(name in filenames)
{
    file.count<-file.count+1
    msg<-paste(sep='','Processing: ',file.count,'/', total.files)
    cat(msg,'\n')
    ProcessPatientCaseRows(name,BSG.results.dir,event.horizon,window.size,buffer.full)
}

end<-now()
timeInfo<-ElapsedTime(start,end)
LogWrite(unlist(timeInfo$printStr),0)

