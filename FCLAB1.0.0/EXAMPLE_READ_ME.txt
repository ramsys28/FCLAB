The following series of steps comprise an alternative way for executing FCLAB using simple MATLAB commands:

load('EEG_test.mat'); %load the sample dataset which is is located in the parent folder
EEG = pop_fclab(EEG); %this will create the FC structure according to the specified FC measure
pop_fcvisual(EEG); %this will open the graph panel for visualization
EEG = pop_fcgraph(EEG); %this will compute graph theoretical properties
pop_fcvisual_parameters(EEG); %this will open the graph panel for visualization of the graph parameters
pop_fcvisual_MSTs(EEG); %this will open the graph panel for visualization of the MST parameters (in case you selected it in pop_fcgraph)


P.S. In general, try to formulate your data so as to match the format of the EEG_test.mat.

Best,
The FCLAB's developers team