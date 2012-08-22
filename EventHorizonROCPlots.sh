#¡/bin/bash
# Script for Plotting LR Modelling tests
# SVN: $Id$

thesisImageDir=/Users/rob/PhDStuff/RobDonaldThesis/Results/images


cd ../LRModels
eventHorizon=10
Rscript LoopingLRModelsEDA.R EH=$eventHorizon mode=single repeats=20
Rscript LoopingLRModelsEDA.R EH=$eventHorizon mode=3X2 repeats=20
cp -v output_"$eventHorizon"/ROC_EH_"$eventHorizon"_3X2.pdf $thesisImageDir

eventHorizon=15
Rscript LoopingLRModelsEDA.R EH=$eventHorizon mode=single
Rscript LoopingLRModelsEDA.R EH=$eventHorizon mode=3X2
cp -v output_"$eventHorizon"/ROC_EH_"$eventHorizon"_3X2.pdf $thesisImageDir

eventHorizon=20
Rscript LoopingLRModelsEDA.R EH=$eventHorizon mode=single
Rscript LoopingLRModelsEDA.R EH=$eventHorizon mode=3X2
cp -v output_"$eventHorizon"/ROC_EH_"$eventHorizon"_3X2.pdf $thesisImageDir

eventHorizon=25
Rscript LoopingLRModelsEDA.R EH=$eventHorizon mode=single
Rscript LoopingLRModelsEDA.R EH=$eventHorizon mode=3X2
cp -v output_"$eventHorizon"/ROC_EH_"$eventHorizon"_3X2.pdf $thesisImageDir

eventHorizon=30
Rscript LoopingLRModelsEDA.R EH=$eventHorizon mode=single
Rscript LoopingLRModelsEDA.R EH=$eventHorizon mode=3X2
cp -v output_"$eventHorizon"/ROC_EH_"$eventHorizon"_3X2.pdf $thesisImageDir
