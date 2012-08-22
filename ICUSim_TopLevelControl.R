# Script for ICU Sim Top Level Control
# SVN: $Id$

INSTALL_DIR<-'/Users/rob'

use.min.model<-TRUE
event.horizon<-10
window.size<-5
buffer.full<-0.8

setwd(paste(sep='',INSTALL_DIR,'/PhDStuff/ThesisSoftware/'))

# Set up timing code
source('UtilScripts/TimeUtils.R')
start<-Sys.time()


# Set up logging
source('UtilScripts/Logging.R')
log.filename<-paste(sep='',INSTALL_DIR,'/PhDStuff/ThesisSoftware/Logs/ICUSim-TLC-output.log')
log.level<-3

# Read in the command line arguments
LogWrite('ICUSim TopLevelControl.R Starting ...',3)

# Some global vars
model.type<-'Median'
min.str<-''
if(use.min.model == TRUE)
{
    min.str<-'min_'
}
ICUSim.results.dir<-paste(sep='',INSTALL_DIR,'/PhDStuff/ThesisSoftware/ICUSim/output/',
                                            model.type,'Model_',min.str,event.horizon,'_',window.size)
dir.create(ICUSim.results.dir)


# Process the data files
setwd("./ICUSim")
source('ICUSim.R')

setwd("../LRModels")
# Loading a pre-saved model ... NOTE: the get() after the load()
model.file<-'./output_10/Best_Model_juno_10_5_Index_4.rda'
#model.file<-'./output_15/Best_Model_juno_15_5_Index_9.rda'
model.file<-'./min_output_10/Best_Model_juno_10_5_Index_10.rda'
LogWrite(model.file,3)
model.name<-load(model.file)
LogWrite(model.name,3)
model.to.use<-get(model.name)
#summary(model.to.use)

#setwd("../../BrainIT/Rel_2011")
setwd("../../BrainIT/DEBUG_Rel_2011")
#setwd("../../BrainIT/EventDetectionDir")

#patient.db<-'PDB-71573727.sdb'
# This one was from training file
#patient.db<-'PDB-83708373.sdb'
#patient.db<-'PDB-16138373.sdb'
#SimPatientStay(patient.db,ICUSim.results.dir,event.horizon,window.size,buffer.full,model.to.use)

filenames<-list.files(pattern='*.sdb')
for(patient.db in filenames)
{
    # Has this file already been processed
    db.name.stem<-substr(patient.db,1,nchar(patient.db)-4)
    ICUSim.results.file<-paste(sep='',ICUSim.results.dir,'/ICUSim-',db.name.stem,'.csv')
    if (file.exists(ICUSim.results.file) == FALSE)
    {
        print(paste(sep='','Still to process: ', patient.db))
        SimPatientStay(patient.db,ICUSim.results.dir,event.horizon,window.size,buffer.full,model.to.use)
    }
    else
    {
        print(paste(sep='','Already processed: ', patient.db))
    }
}
end<-Sys.time()
timeInfo<-ElapsedTime(start,end)
LogWrite(unlist(timeInfo$printStr),0)
#Rprof(NULL)
