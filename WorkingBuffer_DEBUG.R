INSTALL_DIR<-'/Users/rob'
setwd(paste(sep='',INSTALL_DIR,'/PhDStuff/ThesisSoftware/'))
# Set up logging
model.name<-'Minimum'
source('UtilScripts/Logging.R')
hostname<-system('hostname',intern=T)
smallname<-unlist(strsplit(hostname,'\\.'))[1]
log.filename<-paste(sep='',INSTALL_DIR,'/PhDStuff/ThesisSoftware/Logs/ICUDataStream-TLC-output-',smallname,'-MN-',model.name,'.log')

log.level<-3
 
# Start things off 
LogWrite('ICUDataStream_TopLevelControl.R Starting ...',3)


# Process the data files
setwd("./ICUSim")
# Load up the libraries
library('RSQLite')
library('lubridate')
 
# Source the support files
source('../BaseSetGenerator/EpisodeSupport.R')
source('../BaseSetGenerator/CalcSupport.R')
source('../BaseSetGenerator/DBSupport.R')
source('../BaseSetGenerator/BSG-Utils.R')


db.name<-'PDB-84885060.sdb'
setwd("../../BrainIT/DEBUG_Rel_2011")
    sqlite.drv <- dbDriver("SQLite")
    con <- dbConnect(sqlite.drv, dbname = db.name)
    
    all.phys<-GetPhysData(con)
     
    all.demographic<-GetPatientData(con)
    
    dbDisconnect(con)

    attach(all.phys) ### ATTACH
     
         #data.4research<-data.frame(stringsAsFactors = FALSE,Time_Stamp,HRT,BPs,BPd,BPm,TC,ICPm,SaO2,ETCO2)
         # Calculate the pulse pressure BPs - BPd
         BPp<-(BPs-BPd)
        data.4research<-data.frame(stringsAsFactors = FALSE,Time_Stamp,HRT,BPs,BPd,BPm,BPp)
     
    detach(all.phys) ### DETACH
     
     # Convert the Time_Stamp strings to data objects
     timetag<-as.POSIXct(strptime(all.phys$Time_Stamp,'%Y-%m-%d %H:%M'))
     date.part<-as.POSIXct(strptime(all.phys$Time_Stamp,'%Y-%m-%d'))
    time.part<-as.POSIXct(strptime(all.phys$Time_Stamp,'%H:%M'))
     
     working.data<-data.frame(timetag,date.part,time.part,data.4research)
     
         # This next section is vital, it must be maintained if you add in new 
    # columns to be processed, also remember to update the PrintHeaderLine function
    # Skip past the timetag bits and the studyID
    start.index<-5
    end.index<-length(working.data)
    
    # Initialise Ptrs
    
    last.time<-timetag[length(timetag)]
    case.start<-timetag[1]
    buffer.start<-case.start 
    
    
    case.start<-case.start+dminutes(5)
    
    episodeJSON<-paste(sep='',substr(db.name,1,nchar(db.name)-4),'-EpiDtls.json')
    episode.times<-LoadEpisodeTimes(episodeJSON)
    episode.check.index<-1
    
    # Some more initialisation
    display.hour<-'0x'
    hour.count<-0
    
    # Now work through the data 
    buffer.too.small.count<-0
    current.episode.index<-1
    proceed = TRUE
    
    # The actual debugging starts here ---->>>>
    
    
        LogWrite(paste('[while loop] buffer.start: ',format(buffer.start,'%Y%m%d-%H%M'),'-->'),0)
        LogWrite(paste('[while loop] case.start: ',format(case.start,'%Y%m%d-%H%M'),'-->'),0)