% pop_fclab() - Functional Connectivity Lab for EEGLAB  
%
% Usage:

%   >>  OUTEEG = pop_fclab( INEEG, type );
%
% Inputs:
%   INEEG   - input EEG dataset
%   type    - type of processing. 1 process the raw
%             data and 0 the ICA components.
%   
%    
% Outputs:
%   OUTEEG  - output dataset
%
% See also:
%   SAMPLE, EEGLAB 

% Copyright (C) <year>  <name of author>
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

function [outEEG, com] = pop_fcgraph(inEEG)

% the command output is a hidden output that does not have to
% be described in the header

com = ''; % this initialization ensure that the function will return something
          % if the user press the cancel button            

if(isfield(inEEG, 'FC') == 0)
    error('Run a graph analysis first!'); return;
end
          
temEEG = inEEG;

%maintain only those fields that are related to the fcmetrics
eeglab_path = which('eeglab');
eeglab_path = strrep(eeglab_path,'eeglab.m','');
metrics_file = dir([eeglab_path 'plugins/FCLAB1.0.0/FC_metrics/fcmetric_*.m']);
for i = 1:length(metrics_file)
    measure_full = metrics_file(i,:).name;
    fcmetrics{i} = measure_full(10:end-2);
end

if(isfield(temEEG.FC, 'parameters'))
    temEEG.FC = rmfield(temEEG.FC, {'parameters'});
end

if(isfield(temEEG.FC, 'graph_prop'))
    temEEG.FC = rmfield(temEEG.FC, {'graph_prop'});
end

matrices = fieldnames(temEEG.FC);

%clear any past graph analysis results
metrics = intersect(fields(inEEG.FC), fcmetrics);
bands = fieldnames(inEEG.FC.(metrics{1}));
GP_fields = fieldnames(inEEG.FC.(metrics{1}).(bands{1}));
previous_GP_fields_indx = find(~strcmp(GP_fields, 'adj_matrix'));
previous_GP_fields = GP_fields(previous_GP_fields_indx);

for i = 1:length(metrics)
    for j = 1:length(bands)
        for k = 1:length(previous_GP_fields)
            inEEG.FC.(metrics{i}).(bands{j}) = rmfield(inEEG.FC.(metrics{i}).(bands{j}), previous_GP_fields{k});
        end
    end
end
%end

clear temEEG;

if nargin < 3
    g = [1 1];
    geometry = { [g] [g 1] [g 1] [g 1]};
    uilist = { ...
      { 'Style', 'text', 'string', 'Choose FC matrix', 'fontweight', 'bold' } ...
      { 'Style', 'popupmenu', 'string', matrices 'tag' 'metric'}...
      { 'Style', 'checkbox', 'string' 'Threshold?' 'value' 0 'tag' 'threshold' 'Callback', @popupCallback_threshquest} ...
      { 'Style', 'checkbox', 'string' 'MST?' 'value' 0 'tag' 'mst'}...
      { 'Style', 'checkbox', 'string' '+/-' 'value' 0 'tag' 'plus_minus' 'Callback', @popupCallback_plusminus} ...
      { 'Style', 'text', 'string', 'Absolute Threshold', 'visible' 'off' 'tag' 'absthr_label'  } ...
      { 'Style', 'edit', 'string', '' 'tag' 'absthr' 'visible' 'off' } ...
      { 'Style', 'checkbox', 'string' 'Symmetrize?' 'value' 0 'tag' 'symmetrize'} ...
      { 'Style', 'text', 'string', 'Proportional Threshold (%)', 'visible' 'off' 'tag' 'prop_label'  } ...
      { 'Style', 'edit', 'string', '' 'tag' 'propthr' 'visible' 'off' } ...
      { 'Style', 'checkbox', 'string' 'Binarize?' 'value' 0 'tag' 'binarize' 'Callback', @popupCallback_binarize} ...
      };
 
      [ tmp1 tmp2 strhalt structout ] = inputgui(geometry, uilist, ...
           'pophelp(''pop_fclab'');', 'Functional Connectivity Lab');
       
       inEEG.FC.graph_prop=structout;
       clear inEEG.FC.graph_prop.metric
       inEEG.FC.graph_prop.metric = matrices{structout.metric};
       
       outEEG = fcgraph(inEEG);
else
    error('Too many inputs');
end


% return the string command
% -------------------------
com = sprintf('pop_fcgraph( %s);', inputname(1));

return


function popupCallback_threshquest(obj,event)
    if obj.Value==1
       handle = findobj('Tag', 'absthr');
       handle(1).Visible='on';
       handle = findobj('Tag', 'absthr_label');
       handle(1).Visible='on';
       handle = findobj('Tag', 'propthr');
       handle(1).Visible='on';
       handle = findobj('Tag', 'prop_label');
       handle(1).Visible='on';
       handle = findobj('Tag', 'binarize');
       handle(1).Visible='on';
       handle = findobj('Tag', 'plus_minus');
       handle(1).Value = 0;
    else
       handle = findobj('Tag', 'absthr');
       handle(1).Visible='off';
       handle = findobj('Tag', 'absthr_label');
       handle(1).Visible='off';
       handle = findobj('Tag', 'propthr');
       handle(1).Visible='off';
       handle = findobj('Tag', 'prop_label');
       handle(1).Visible='off';
       handle = findobj('Tag', 'binarize');
       handle(1).Value = 0;
    end
return

function popupCallback_plusminus(obj, event)
handle = findobj('Tag', 'threshold');
if handle(1).Value == 1
    handle(1).Value = 0;
    popupCallback_threshquest(handle(1),event);
else
    popupCallback_threshquest(handle(1),event);
end
return

function popupCallback_binarize(obj,event)
handle = findobj('Tag', 'plus_minus');
handle(1).Value = 0;
return
