/*
    main.do
    Main file to calculate forecast errors using the Michigan Survey of Consumers.
*/

do ./codes/000_installPackages.do
do ./codes/00_createVariablesAggregate.do
do ./codes/01_createVariablesSOC.do
do ./codes/02_mergePanelInfoSOC.do
do ./codes/03_constructErrors.do
do ./codes/04_selectSample.do
do ./codes/05_winsorizeData.do
do ./codes/06_ImputeActual.do
do ./codes/07_getRealErrors.do
do ./codes/08_winsorizeImputations.do
do ./codes/09_calculateMovingAverage.do
do ./codes/10_plotFigures.do