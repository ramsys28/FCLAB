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

function [EEG, com] = pop_fclab( EEG, typeproc);

% the command output is a hidden output that does not have to
% be described in the header

com = ''; % this initialization ensure that the function will return something
          % if the user press the cancel button            

% display help if not enough arguments
% ------------------------------------
if nargin < 1
	help pop_sample;
    typeproc=1;
	return;
end;	

% pop up window
% -------------

% PREPEI NA EXETASOUME POIES METRIKES EINAI DIATHESIMES
% FOR EXAMPLE
metrics='Correlation|';
if exist('data2cs_event.m', 'file') == 2
    metrics=strcat(metrics,'Inverse Coherence');
end;


if nargin < 3
    g = [1 1];
    geometry = { [g 1] [1 1 1] [g 1] [g 1] [g 1] [g 1] [g 1] [g 1] [g 1] [g 1] [g 1] };
    uilist = { ...
      { 'Style', 'text', 'string', 'Choose Metric', 'fontweight', 'bold' } ...
      { 'Style', 'popupmenu', 'string', metrics 'tag' 'metric' 'Callback', @popupCallback_drp}...
      { 'Style', 'checkbox', 'string' 'All' 'value' 0 'tag' 'metric_all' 'Callback', @popupCallback_all} ...
      { 'Style', 'text', 'string', 'Brainwaves', 'fontweight', 'bold'  }...
      { 'Style', 'text', 'string', 'Frequncy [low high]', 'fontweight', 'bold'  }...
      { 'Style', 'text', 'string', 'Name (delta, theta)', 'fontweight', 'bold'  }...
      { 'Style', 'text', 'string', 'Frequency Band1 [low high]',   } ...
      { 'Style', 'edit', 'string', ' ' 'tag' 'frb1'} ...
      { 'Style', 'edit', 'string', ' ' 'tag' 'frb1_name'} ...
      { 'Style', 'text', 'string', 'Frequency Band2 [low high]',   } ...
      { 'Style', 'edit', 'string', ' ' 'tag' 'frb2'} ...
      { 'Style', 'edit', 'string', ' ' 'tag' 'frb2_name'} ...
            { 'Style', 'text', 'string', 'Frequency Band2 [low high]',   } ...
      { 'Style', 'edit', 'string', ' ' 'tag' 'frb3'} ...
      { 'Style', 'edit', 'string', ' ' 'tag' 'frb3_name'} ...
            { 'Style', 'text', 'string', 'Frequency Band2 [low high]',   } ...
      { 'Style', 'edit', 'string', ' ' 'tag' 'frb4'} ...
      { 'Style', 'edit', 'string', ' ' 'tag' 'frb4_name'} ...
            { 'Style', 'text', 'string', 'Frequency Band2 [low high]',   } ...
      { 'Style', 'edit', 'string', ' ' 'tag' 'frb5'} ...
      { 'Style', 'edit', 'string', ' ' 'tag' 'frb5_name'} ...
            { 'Style', 'text', 'string', 'Frequency Band2 [low high]',   } ...
      { 'Style', 'edit', 'string', ' ' 'tag' 'frb6'} ...
      { 'Style', 'edit', 'string', ' ' 'tag' 'frb6_name'} ...
            { 'Style', 'text', 'string', 'Frequency Band2 [low high]',   } ...
      { 'Style', 'edit', 'string', ' ' 'tag' 'frb7'} ...
      { 'Style', 'edit', 'string', ' ' 'tag' 'frb7_name'} ...
            { 'Style', 'text', 'string', 'Frequency Band2 [low high]',   } ...
      { 'Style', 'edit', 'string', ' ' 'tag' 'frb8'} ...
      { 'Style', 'edit', 'string', ' ' 'tag' 'frb8_name'} ...
            { 'Style', 'text', 'string', 'Frequency Band2 [low high]',   } ...
      { 'Style', 'edit', 'string', ' ' 'tag' 'frb9'} ...
      { 'Style', 'edit', 'string', ' ' 'tag' 'frb9_name'} ...
      };
 
      [ tmp1 tmp2 strhalt structout ] = inputgui(geometry, uilist, ...
           'pophelp(''pop_fclab'');', 'Functional Connectivity Lab');

end;


% call function sample either on raw data or ICA data
% ---------------------------------------------------
if typeproc == 1
    %handle = findobj('Tag', 'metric');
    %if(handle.Value==1)
    %    disp('asdas')
    %end
	%sample( EEG.data );
    
else
	if ~isempty( EEG.icadata )
		sample( EEG.icadata );
	else
		error('You must run ICA first');
	end;	
end;	 

% return the string command
% -------------------------
com = sprintf('pop_sample( %s, %d, [%s] );', inputname(1), typeproc );





return;

% callback for the drop-down menu
function popupCallback_drp(obj,event)
    if obj.Value==1
         handle = findobj('Tag', 'frb9');
         handle.Visible='off';
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
