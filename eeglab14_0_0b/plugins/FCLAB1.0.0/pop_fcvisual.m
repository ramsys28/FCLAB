function varargout = pop_fcvisual(varargin)
% POP_FCVISUAL MATLAB code for pop_fcvisual.fig
%      POP_FCVISUAL, by itself, creates a new POP_FCVISUAL or raises the existing
%      singleton*.
%
%      H = POP_FCVISUAL returns the handle to a new POP_FCVISUAL or the handle to
%      the existing singleton*.
%
%      POP_FCVISUAL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in POP_FCVISUAL.M with the given input arguments.
%
%      POP_FCVISUAL('Property','Value',...) creates a new POP_FCVISUAL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before pop_fcvisual_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to pop_fcvisual_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help pop_fcvisual

% Last Modified by GUIDE v2.5 12-Apr-2017 00:56:12   
          
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @pop_fcvisual_OpeningFcn, ...
                   'gui_OutputFcn',  @pop_fcvisual_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before pop_fcvisual is made visible.
function pop_fcvisual_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to pop_fcvisual (see VARARGIN)

% Choose default command line output for pop_fcvisual
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

G = evalin('base', 'EEG.FC.Correlation.adj_matrix');
axes(handles.axes1);
imagesc(double(G)); colormap(jet); colorbar;

% UIWAIT makes pop_fcvisual wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = pop_fcvisual_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
G = evalin('base', 'EEG.FC.correlation.adj_matrix');
thresh = str2num(char(get(handles.edit1, 'String'))); %#ok<ST2NM>

if(isempty(thresh) ~= 1)
    G(G<thresh) = 0;
else
    ;
end

axes(handles.axes1); imagesc(double(G)); colorbar;
guidata(hObject, handles);

% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1

cmap = get(handles.popupmenu1, 'Value');
axes(handles.axes1);
if(cmap == 1)
    colormap(jet);
elseif(cmap == 2)
    colormap(hsv);
elseif(cmap == 3)
    colormap(hot);
end
colorbar;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
