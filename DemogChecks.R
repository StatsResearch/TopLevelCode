# Script for Checking Demographic Attributes
# SVN: $Id: DemogChecks.R 470 2012-01-02 21:08:59Z rob $

INSTALL_DIR<-'/Users/rob'

setwd(paste(sep='',INSTALL_DIR, '/PhDStuff/ThesisSoftware/')

library('RSQLite')

source('UtilScripts/Logging.R')
log.filename<-paste(sep='', INSTALL_DIR,'/PhDStuff/ThesisSoftware/Logs/DemogChecks.log'
log.level<-3

CheckDemographicAttributes<-function(db.name)
{
    # create a SQLite instance and create one connection.
    sqlite.drv <- dbDriver("SQLite")
    con <- dbConnect(sqlite.drv, dbname = db.name)
    
    all.demographic<-GetPatientData(con)
    
    dbDisconnect(con)  
    
    return(all.demographic)
}


# Process the data files
setwd("./BaseSetGenerator")
source('DBSupport.R')

setwd("../../BrainIT/EventDetectionDir")

filenames<-list.files(pattern='*.sdb$')
for(name in filenames)
{
    demog.data<-CheckDemographicAttributes(name)
    
    if(is.na(demog.data$Age))
    {
        msg<-paste('Age is NA', name)
        LogWrite(msg,0)
        file.rename(name,paste(sep='',name,'.INVALID-AGE'))
        stem<-substring(name,1,nchar(name)-4)
        file.remove(paste(sep='',stem,'-EpiDtls.json'))
    } 
    else if(demog.data$Age <16)
    {
        msg<-paste('Age < 16', name, 'Age= ', demog.data$Age)
        LogWrite(msg,0)
        file.rename(name,paste(sep='',name,'.INVALID-AGE'))
        stem<-substring(name,1,nchar(name)-4)
        file.remove(paste(sep='',stem,'-EpiDtls.json'))
    }
}



