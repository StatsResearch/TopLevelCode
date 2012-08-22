# Python Script to build up all 5 min blocks for a given training or test file

# SVN: $Id: CombineWindowSizeBlocks.py 545 2012-03-13 22:25:40Z rob $

import csv
import os
import glob
from time import strftime
from datetime import datetime
from datetime import timedelta 

start = datetime.now()
print 'Start: ' + str(start)

InstallDir = '/Users/rob'
BDSTopLevel = InstallDir + '/PhDStuff/ThesisSoftware/BaseSetGenerator'
TTGTopLevel = InstallDir + '/PhDStuff/ThesisSoftware/TrgTestGenerator'
outputDir = InstallDir + '/PhDStuff/ThesisSoftware/TrgTestGenerator/output_All_EH5'

TTG_EH=10
TTG_WS=5
numRepeats=10

allEventHorizons=[15,20,25,30]
WS=5

# The main code
print 'Starting ...'
print 'Pre-loading BDS files ...'


currentSID = 'NOT-SET'

All_BDS = {}

BDS_15_dictionary = {}
All_BDS['EH_15'] = BDS_15_dictionary

BDS_20_dictionary = {}
All_BDS['EH_20'] = BDS_20_dictionary

BDS_25_dictionary = {}
All_BDS['EH_25'] = BDS_25_dictionary

BDS_30_dictionary = {}
All_BDS['EH_30'] = BDS_30_dictionary

CombinedOutput = {}


for EH in allEventHorizons:

    dName = 'EH_' + str(EH)
    
    # Read the BDS into a clean dictionary
    All_BDS[dName].clear()
                
    fileDir = BDSTopLevel + '/output_' + str(EH) 
    fileName = 'BDS_' + str(EH) + '_' + str(WS) + '.csv'
    fullFile = fileDir + '/' + fileName                
                            
    print 'Loading Base Data Set file ... ' + fileName
                
    BDS_data=open(fullFile)
    BDS_lineCount = 0
    
    lineTokens = []
    
    for line in BDS_data:
                
        BDS_lineCount += 1
        lineTokens = line.split(',')
        
        if(BDS_lineCount == 1):
            All_BDS[dName]['HeaderColumns'] = line
            
            
        key = lineTokens[0] + '-' + lineTokens[1]
        
        #BDS_dictionary[key] = lineTokens[2:(len(lineTokens)-1)]
        All_BDS[dName][key] = line
    
    end = datetime.now()
    elapsed = end - start
    print 'End: ' + str(end)
    
    print 'Elasped: ' + str(elapsed)
    print 'BDS Dictionary ' + dName + ' load processed: ' + str(BDS_lineCount) + ' lines'

    print 'Pre-load of BDS dictionaries complete'
# Read the training file
# TTG_Training_10_5_seq_1.csv

#outFileName = outputDir 

allModes = ['Training','Test']

for sequence in range(1,numRepeats + 1):

    for mode in allModes:

        outFileName = outputDir + '/All_' + mode + '_EH_5_seq_' + str(sequence) + '.csv'
        out = open(outFileName,'w')
    
        TTG_fileDir = TTGTopLevel + '/output_' + str(TTG_EH) 
        TTG_fileName = 'TTG_' + mode + '_' + str(TTG_EH) + '_' + str(TTG_WS) + '_seq_'+ str(sequence) + '.csv'
        TTG_fullFile = TTG_fileDir + '/' + TTG_fileName
    
        print 'Processing: ' + TTG_fileName
        
        TTG_file = open(TTG_fullFile)
        lineCount = 0
    
        for TTG_line in TTG_file:
            lineCount += 1
            if(lineCount == 1):
                # Write out the header line, first the line from the 10_5 file
                hdrLine = TTG_line
                hdrTokens = hdrLine.split(',')
                # In the TTG files the first column in an empty string but it is 
                # actually the index from the BDS 
                out.write('OrgIndex' + ',')
                for count in range(1,len(hdrTokens)-1):
                    cleanStr = hdrTokens[count].replace('"', '').strip()
                    out.write("%s," % cleanStr )
    
                # Now the measurement columns from each of the other EH_5 files
                for EH in allEventHorizons:
                    dName = 'EH_' + str(EH)
                    hdrLine = All_BDS[dName]['HeaderColumns']
                    hdrTokens = hdrLine.split(',')
                    for count in range(6,len(hdrTokens)-1):
                        cleanStr = hdrTokens[count].replace('"', '').strip()
                        out.write("%s," % cleanStr )        
                        
                    if(EH == 30):
                        out.write(hdrTokens[len(hdrTokens)-1])

            # -------- End of header line section
            
            else:
                # A bit of feedback
                if ( lineCount%100 == 0):
                    print 'Processed ' + str(lineCount) + ' lines'
                # Save the EH_10 line without the caselabel and \n    
                CombinedOutput['EH_10_Values'] = TTG_line[:-2]
                CombinedOutput['EH_10_CaseLabel'] = TTG_line[-2:len(TTG_line)]
                    
                TTG_tokens = []
                TTG_tokens = TTG_line.split(',')
                
                #"","study_id","timetag",
                #2004-05-28T14:14
                TTG_sid = TTG_tokens[1]
                if (TTG_sid != currentSID):
                    currentSID = TTG_sid
                    print '>>> Processing: ' +  currentSID
                    
                TTG_ttag_raw = TTG_tokens[2]
                TTG_ttag = TTG_ttag_raw[1:len(TTG_ttag_raw)-1]
                
                TTG_ttag_obj = datetime.strptime(TTG_ttag, '%Y-%m-%dT%H:%M')
                #print 'TTG_ttag_obj = ' + str(TTG_ttag_obj)
                  
                
                # Now process the other base data files 
                for EH in allEventHorizons:
                
                    BDS_ttag_to_find = TTG_ttag_obj + timedelta(minutes=(TTG_EH-EH)) 
                    #print 'Looking for: ' + TTG_sid + ', ttag = ' + str(BDS_ttag_to_find)
                    #print 'BDS_ttag_to_find = ' + str(BDS_ttag_to_find)
                    formattedTime = datetime.strftime(BDS_ttag_to_find, '%Y-%m-%dT%H:%M')
         
                    dName = 'EH_' + str(EH)
        
                    BDS_Key = currentSID + '-' + formattedTime
                    # Find the line in the appropriate pre-loaded BDS dictionary
                    try:    
                        BDS_Line = All_BDS[dName][BDS_Key]
                        CombinedOutput['EH_'+str(EH) + '_Values'] = BDS_Line
                          
                        if(EH == 30):
                            # If we get here we have all the data
                            # First the line from the EH_10 TTG file 
                            out.write(CombinedOutput['EH_10_Values'])
                            
                            # Now all random drawn EH_5 BDS matched lines
                            for EH in allEventHorizons:
                                BDS_line = CombinedOutput['EH_'+str(EH) + '_Values']
                                dataTokens = BDS_Line.split(',')
                                for count in range(6,len(hdrTokens)-1):
                                    cleanStr = dataTokens[count].replace('"', '').strip()
                                    out.write("%s," % cleanStr ) 
                             
                            # Finally the case label
                            out.write(CombinedOutput['EH_10_CaseLabel'])
    
                    except:
                        print 'Failed to get BDS_Key: ' + BDS_Key        
                
    out.close()

end = datetime.now()
elapsed = end - start
print 'End: ' + str(end)

formattedTime = datetime.strftime(end, '%Y-%m-%dT%H:%M')
print 'formattedTime: ' + formattedTime
print 'Elasped: ' + str(elapsed)
print '... Processing complete' 