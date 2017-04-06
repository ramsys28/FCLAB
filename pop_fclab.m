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

function [EEG, com] = pop_fclab( EEG, typeproc, param3 );

% the command output is a hidden output that does not have to
% be described in the header

com = ''; % this initialization ensure that the function will return something
          % if the user press the cancel button            

% display help if not enough arguments
% ------------------------------------
if nargin < 2
	help pop_sample;
	return;
end;	

% pop up window
% -------------

%  PREPEI NA EXETASOUME POIES METRIKES EINAI DIATHESIMES
% FOR EXAMPLE
metrics='Correlation|';
if exist('data2cs_event.m', 'file') == 2
    metrics=strcat(metrics,'Inverse Coherence');
end;


if nargin < 3
    g = [0.5 1];
    geometry = { g g g g g g g g g };
    uilist = { ...
      { 'Style', 'text', 'string', 'Choose Metric', 'fontweight', 'bold'  } ...
      { 'Style', 'popupmenu', 'string', metrics, 'tag' 'metric' } ...
      
      { 'Style', 'text', 'string', 'Frequency Band1 [low high]', 'fontweight', 'bold'  } ...
      { 'Style', 'edit', 'string', ' ' 'tag' 'frb1'} ...
      
      { 'Style', 'text', 'string', 'Frequency Band2 [low high]', 'fontweight', 'bold'  } ...
      { 'Style', 'edit', 'string', ' ' 'tag' 'frb1'} ...
      
      { 'Style', 'text', 'string', 'Frequency Band3 [low high]', 'fontweight', 'bold'  } ...
      { 'Style', 'edit', 'string', ' ' 'tag' 'frb1'} ...
      
      { 'Style', 'text', 'string', 'Frequency Band4 [low high]', 'fontweight', 'bold'  } ...
      { 'Style', 'edit', 'string', ' ' 'tag' 'frb1'} ...
      
      { 'Style', 'text', 'string', 'Frequency Band5 [low high]', 'fontweight', 'bold'  } ...
      { 'Style', 'edit', 'string', ' ' 'tag' 'frb1'} ...
      
      { 'Style', 'text', 'string', 'Frequency Band6 [low high]', 'fontweight', 'bold'  } ...
      { 'Style', 'edit', 'string', ' ' 'tag' 'frb1'} ...
      
      { 'Style', 'text', 'string', 'Frequency Band7 [low high]', 'fontweight', 'bold'  } ...
      { 'Style', 'edit', 'string', ' ' 'tag' 'frb1'} ...
      
      { 'Style', 'text', 'string', 'Frequency Band8 [low high]', 'fontweight', 'bold'  } ...
      { 'Style', 'edit', 'string', ' ' 'tag' 'frb1'} ...
      
      };
 
      [ tmp1 tmp2 strhalt structout ] = inputgui( geometry, uilist, ...
           'pophelp(''pop_newtimef'');', 'Plot channel time frequency -- pop_newtimef()');

end;

% call function sample either on raw data or ICA data
% ---------------------------------------------------
if typeproc == 1
	sample( EEG.data );
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
