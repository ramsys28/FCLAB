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

function [EEG, com] = pop_fclab( EEG, typeproc );

% the command output is a hidden output that does not have to
% be described in the header

com = ''; % this initialization ensure that the function will return something
          % if the user press the cancel button            


typeproc=1;
% pop up window
% -------------

% PREPEI NA EXETASOUME POIES METRIKES EINAI DIATHESIMES
% FOR EXAMPLE
metrics='Correlation|';
if exist('data2cs_event.m', 'file') == 2
    metrics=strcat(metrics,'Inverse Coherence');
end;


if nargin < 3
    g = [1 1 1];
    geometry = { [g] [g 1] [g 1] [g 1] [g 1] [g 1] [g 1] [g 1] [g 1] [g 1] [g 1] 1};
    uilist = { ...
      { 'Style', 'text', 'string', 'Choose Metric', 'fontweight', 'bold' } ...
      { 'Style', 'popupmenu', 'string', metrics 'tag' 'metric' 'Callback', @popupCallback_drp}...
      { 'Style', 'checkbox', 'string' 'All' 'value' 0 'tag' 'metric_all' 'Callback', @popupCallback_all} ...
      { 'Style', 'text', 'string', 'Brainwaves', 'fontweight', 'bold'  }...
      { 'Style', 'text', 'string', 'Frequncy [low high]', 'fontweight', 'bold'  }...
      { 'Style', 'text', 'string', 'Name (delta, theta)', 'fontweight', 'bold'  }...
      { 'Style', 'checkbox', 'string' 'Auto Compete' 'value' 0 'tag' 'auto_cmpl' 'Callback', @popupCallback_autocmpl} ...
      { 'Style', 'text', 'string', 'Frequency Band1 [low high]',   } ...
      { 'Style', 'edit', 'string', '' 'tag' 'frb1'} ...
      { 'Style', 'edit', 'string', '' 'tag' 'frb1_name'} {} ...
      { 'Style', 'text', 'string', 'Frequency Band2 [low high]',   } ...
      { 'Style', 'edit', 'string', '' 'tag' 'frb2'} ...
      { 'Style', 'edit', 'string', '' 'tag' 'frb2_name'} {}...
            { 'Style', 'text', 'string', 'Frequency Band3 [low high]',   } ...
      { 'Style', 'edit', 'string', '' 'tag' 'frb3'} ...
      { 'Style', 'edit', 'string', '' 'tag' 'frb3_name'} {}...
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
      { 'Style', 'checkbox', 'string' 'Compute all graph theoretical parameters' 'value' 0 'tag' 'graph'} ...
      };
 
      [ tmp1 tmp2 strhalt structout ] = inputgui(geometry, uilist, ...
           'pophelp(''pop_fclab'');', 'Functional Connectivity Lab');

end;

switch structout.metric
    case 1
        param.metric='cor';
    case 2
        param.metric='icoh';
end;

fields=fieldnames(structout);

if structout.metric_all==1
    param.metric='all';
end;
k=1;
if prod([isempty(structout.frb1),isempty(structout.frb2),isempty(structout.frb3),...
        isempty(structout.frb4),isempty(structout.frb5),isempty(structout.frb6),...
         isempty(structout.frb7),isempty(structout.frb8),isempty(structout.frb9)])
    param.spectrum='all';
else
    for i=4:2:20
        if ~isempty(getfield(structout,fields{i}))
            param.bands{k,1}=getfield(structout,fields{i});
            param.bands{k,2}=getfield(structout,fields{i+1});
            k=k+1;
        end;
    end;
end;

param.graph=structout.graph;

[EEG, com] = fclab(EEG, param);

% return the string command
% -------------------------
com = sprintf('pop_fclab( %s, %d );', inputname(1), typeproc);





return;

% callback for the drop-down menu
function popupCallback_drp(obj,event)
    if obj.Value==1
       %  handle = findobj('Tag', 'frb9');
       % handle.Visible='off';
    end
return;

function popupCallback_all(obj,event)
   

    if obj.Value==1
         handle = findobj('Tag', 'metric');
         set(handle,'Visible','Off')
    else
        handle = findobj('Tag', 'metric');
        set(handle,'Visible','On')
    end
return;

function popupCallback_autocmpl(obj,event)
    if obj.Value==1
         set(findobj('Tag', 'frb1'),'String','[0.5 4]')
         set(findobj('Tag', 'frb1_name'),'String','Delta')
         set(findobj('Tag', 'frb2'),'String','[4 8]')
         set(findobj('Tag', 'frb2_name'),'String','Theta')
         set(findobj('Tag', 'frb3'),'String','[8 10]')
         set(findobj('Tag', 'frb3_name'),'String','Alpha1')
         set(findobj('Tag', 'frb4'),'String','[10 12]')
         set(findobj('Tag', 'frb4_name'),'String','Alpha2')
         set(findobj('Tag', 'frb5'),'String','[13 30]')
         set(findobj('Tag', 'frb5_name'),'String','Beta')
         set(findobj('Tag', 'frb6'),'String','[30 45]')
         set(findobj('Tag', 'frb6_name'),'String','Gamma')
    else
         set(findobj('Tag', 'frb1'),'String',' ')
         set(findobj('Tag', 'frb1_name'),'String',' ')
         set(findobj('Tag', 'frb2'),'String',' ')
         set(findobj('Tag', 'frb2_name'),'String',' ')
         set(findobj('Tag', 'frb3'),'String',' ')
         set(findobj('Tag', 'frb3_name'),'String',' ')
         set(findobj('Tag', 'frb4'),'String',' ')
         set(findobj('Tag', 'frb4_name'),'String',' ')
         set(findobj('Tag', 'frb5'),'String',' ')
         set(findobj('Tag', 'frb5_name'),'String',' ')
         set(findobj('Tag', 'frb6'),'String',' ')
         set(findobj('Tag', 'frb6_name'),'String',' ')
    end
return;
