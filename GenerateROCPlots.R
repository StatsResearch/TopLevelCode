INSTALL_DIR<-'/Users/rob'
setwd(paste(sep='',INSTALL_DIR,'/PhDStuff/ThesisSoftware/'))

ProcessArgs<-function(args)
{

    arg.elements<-strsplit(args,'-')
    
    for(count in 1:length(arg.elements[[1]]))
    {
        LogWrite(paste(sep='','Processing arg: ',count),0)
        arg.pair<-strsplit(arg.elements[[1]][count],' ')
        
        if(nchar(arg.pair[[1]]) > 0)
        {
            if( arg.pair[[1]][1] == 'EH')
            {
                LogWrite('Arg EH',0)
                event.horizon<<-as.numeric(arg.pair[[1]][2])
            }
            else if ( arg.pair[[1]][1] == 'WS')
            {
                window.size<<-as.numeric(arg.pair[[1]][2])
            }
            else if ( arg.pair[[1]][1] == 'F')
            {
                filename<<-arg.pair[[1]][2]
            }
        }
    }

}



# Set up timing code
source('UtilScripts/TimeUtils.R')
start<-now()

#options(error=utils::recover)
#Rprof()

event.horizon<-10
window.size<-5
filename<-'The/default/file'


#cmd.args<-commandArgs(TRUE);
#all.args<-'Command Line Args:'
#for (arg in cmd.args)
#{
 #   all.args<-paste(sep='', all.args, '  ', arg);
#}

#all.args<-'Command Line Args:  -EH  10  -WS  5'
all.args<-'-EH  10  -WS  5'

# Set up logging
source('UtilScripts/Logging.R')
log.filename<-paste(sep='',INSTALL_DIR,'/PhDStuff/ThesisSoftware/Logs/GenerateROC-EH-',event.horizon,'.log')
log.level<-3

# Read in the command line arguments
LogWrite('LoopingLRModelsEDA.R Starting ...',3)
LogWrite('-- reading arguments',3)

LogWrite(all.args,0)

ProcessArgs(all.args)

LogWrite(paste(sep='','event.horizon = ',event.horizon),0)
LogWrite(paste(sep='','window.size = ',window.size),0)
LogWrite(paste(sep='','filename = ',filename),0)

