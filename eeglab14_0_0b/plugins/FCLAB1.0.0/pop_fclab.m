
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

function [outEEG, com] = pop_fclab(inEEG)

% the command output is a hidden output that does not have to
% be described in the header

com = ''; % this initialization ensure that the function will return something
          % if the user press the cancel button            


typeproc=1;
% pop up window
% -------------

% PREPEI NA EXETASOUME POIES METRIKES EINAI DIATHESIMES
% FOR EXAMPLE
eeglab_path = which('eeglab');
eeglab_path = strrep(eeglab_path,'eeglab.m','');
metrics_file = dir([eeglab_path 'plugins/FCLAB1.0.0/FC_metrics/fcmetric_*.m']);
metrics = [];
for i = length(metrics_file):-1:1
     metrics=strcat(metrics, strrep(strrep(metrics_file(i).name,'fcmetric_',''),'.m',''));
     metrics=strcat(metrics,'|');
end
metrics = metrics(1:end-1);

% fieldnames(strcmp(fieldnames,'parameters'))=[];

if nargin < 3
    g = [1 1 1];
    geometry = { [g] [g 1] [g 1] [g 1] [g 1] [g 1] [g 1] [g 1] [g 1] [g 1] [g 1]};
    uilist = { ...
      { 'Style', 'text', 'string', 'Choose Metric', 'fontweight', 'bold' } ...
      { 'Style', 'popupmenu', 'string', metrics 'tag' 'metric' 'Callback', @popupCallback_drp}...
      { 'Style', 'checkbox', 'string' 'All' 'value' 0 'tag' 'metric_all' 'Callback', @popupCallback_all} ...
      { 'Style', 'text', 'string', 'Brainwaves', 'fontweight', 'bold'  }...
      { 'Style', 'text', 'string', 'Frequency [low high]', 'fontweight', 'bold'  }...
      { 'Style', 'text', 'string', 'Name (delta, theta)', 'fontweight', 'bold'  }...
      { 'Style', 'checkbox', 'string' 'Auto Compete' 'value' 0 'tag' 'auto_cmpl' 'Callback', @popupCallback_autocmpl} ...
      { 'Style', 'text', 'string', 'Frequency Band1 [low high]',   } ...
      { 'Style', 'edit', 'string', '' 'tag' 'frb1'} ...
      { 'Style', 'edit', 'string', '' 'tag' 'frb1_name'} {} ...
      { 'Style', 'text', 'string', 'Frequency Band2 [low high]',   } ...
      { 'Style', 'edit', 'string', '' 'tag' 'frb2'} ...
      { 'Style', 'edit', 'string', '' 'tag' 'frb2_name'} { } ...
            { 'Style', 'text', 'string', 'Frequency Band3 [low high]',   } ...
      { 'Style', 'edit', 'string', '' 'tag' 'frb3'} ...
      { 'Style', 'edit', 'string', '' 'tag' 'frb3_name'} { }...
            { 'Style', 'text', 'string', 'Frequency Band4 [low high]',   } ...
      { 'Style', 'edit', 'string', '' 'tag' 'frb4'} ...
      { 'Style', 'edit', 'string', '' 'tag' 'frb4_name'} {} ...
            { 'Style', 'text', 'string', 'Frequency Band5 [low high]',   } ...
      { 'Style', 'edit', 'string', '' 'tag' 'frb5'} ...
      { 'Style', 'edit', 'string', '' 'tag' 'frb5_name'} {}...
            { 'Style', 'text', 'string', 'Frequency Band6 [low high]',   } ...
      { 'Style', 'edit', 'string', '' 'tag' 'frb6'} ...
      { 'Style', 'edit', 'string', '' 'tag' 'frb6_name'} {} ...
            { 'Style', 'text', 'string', 'Frequency Band7 [low high]',   } ...
      { 'Style', 'edit', 'string', '' 'tag' 'frb7'} ...
      { 'Style', 'edit', 'string', '' 'tag' 'frb7_name'} {}...
            { 'Style', 'text', 'string', 'Frequency Band8 [low high]',   } ...
      { 'Style', 'edit', 'string', '' 'tag' 'frb8'} ...
      { 'Style', 'edit', 'string',  '' 'tag' 'frb8_name'} {} ...
            { 'Style', 'text', 'string', 'Frequency Band9 [low high]',   } ...
      { 'Style', 'edit', 'string', '' 'tag' 'frb9'} ...
      { 'Style', 'edit', 'string', '' 'tag' 'frb9_name'} {} ...
      
      };
 
      [ tmp1 tmp2 strhalt structout ] = inputgui(geometry, uilist, ...
           'pophelp(''pop_fclab'');', 'Functional Connectivity Lab');
else
    error('Too many inputs');
end

map = (length(metrics_file):-1:1);
structout.metric = map(structout.metric);

inEEG.FC.parameters.metric = strrep(metrics_file(structout.metric).name,'.m','');

if (structout.metric_all == 1)
   inEEG.FC.parameters.metric = 'all';
end

fields = fieldnames(structout);
k = 1;
if prod([isempty(structout.frb1),isempty(structout.frb2),isempty(structout.frb3),...
         isempty(structout.frb4),isempty(structout.frb5),isempty(structout.frb6),...
         isempty(structout.frb7),isempty(structout.frb8),isempty(structout.frb9)])
    error('Please fill a specific bandwidth or click to Auto Complete');
else
    inEEG.FC.parameters.bands = [];
    for i = 4:2:20
        if ~isempty(getfield(structout,fields{i}))
            inEEG.FC.parameters.bands{k,1} = getfield(structout,fields{i});
            inEEG.FC.parameters.bands{k,2} = getfield(structout,fields{i+1});
            k = k+1;
        end
    end
end

[outEEG, com] = fclab(inEEG);

% return the string command
% -------------------------
com = sprintf('pop_fclab( %s);', inputname(1));

return

% callback for the drop-down menu
function popupCallback_drp(obj,event)
    if ((obj.Value==3) || (obj.Value==5))
        msgbox('Plase note that this similarity measure might be influenced by volume conduction!', 'Notification', 'warn');
    end
return

function popupCallback_all(obj,event)
    if (obj.Value == 1) 
        handle = findobj('Tag', 'metric');
        set(handle,'Visible','Off')
    else
        handle = findobj('Tag', 'metric');
        set(handle,'Visible','On')
    end
return


function popupCallback_autocmpl(obj,event)
    if (obj.Value == 1)
         set(findobj('Tag', 'frb1'),'String','[0.5 4]');
         set(findobj('Tag', 'frb1_name'),'String','Delta');
         set(findobj('Tag', 'frb2'),'String','[4 8]');
         set(findobj('Tag', 'frb2_name'),'String','Theta');
         set(findobj('Tag', 'frb3'),'String','[8 10]');
         set(findobj('Tag', 'frb3_name'),'String','Alpha1');
         set(findobj('Tag', 'frb4'),'String','[10 12]');
         set(findobj('Tag', 'frb4_name'),'String','Alpha2');
         set(findobj('Tag', 'frb5'),'String','[13 30]');
         set(findobj('Tag', 'frb5_name'),'String','Beta');
         set(findobj('Tag', 'frb6'),'String','[30 45]');
         set(findobj('Tag', 'frb6_name'),'String','Gamma');
         set(findobj('Tag', 'frb7'),'String','[0.5 45]');
         set(findobj('Tag', 'frb7_name'),'String','All Spectrum');
    else
         set(findobj('Tag', 'frb1'),'String',' ');
         set(findobj('Tag', 'frb1_name'),'String',' ');
         set(findobj('Tag', 'frb2'),'String',' ');
         set(findobj('Tag', 'frb2_name'),'String',' ');
         set(findobj('Tag', 'frb3'),'String',' ');
         set(findobj('Tag', 'frb3_name'),'String',' ');
         set(findobj('Tag', 'frb4'),'String',' ');
         set(findobj('Tag', 'frb4_name'),'String',' ');
         set(findobj('Tag', 'frb5'),'String',' ');
         set(findobj('Tag', 'frb5_name'),'String',' ');
         set(findobj('Tag', 'frb6'),'String',' ');
         set(findobj('Tag', 'frb6_name'),'String',' ');
         set(findobj('Tag', 'frb7'),'String',' ');
         set(findobj('Tag', 'frb7_name'),'String',' ');
    end
return
