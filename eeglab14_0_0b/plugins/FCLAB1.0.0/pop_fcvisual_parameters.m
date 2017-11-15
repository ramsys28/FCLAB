function varargout = pop_fcvisual_parameters(varargin)
% POP_FCVISUAL_PARAMETERS MATLAB code for pop_fcvisual_parameters.fig
%      POP_FCVISUAL_PARAMETERS, by itself, creates a new POP_FCVISUAL_PARAMETERS or raises the existing
%      singleton*.
%
%      H = POP_FCVISUAL_PARAMETERS returns the handle to a new POP_FCVISUAL_PARAMETERS or the handle to
%      the existing singleton*.
%
%      POP_FCVISUAL_PARAMETERS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in POP_FCVISUAL_PARAMETERS.M with the given input arguments.
%
%      POP_FCVISUAL_PARAMETERS('Property','Value',...) creates a new POP_FCVISUAL_PARAMETERS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before pop_fcvisual_parameters_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to pop_fcvisual_parameters_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help pop_fcvisual_parameters

% Last Modified by GUIDE v2.5 26-Oct-2017 15:48:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @pop_fcvisual_parameters_OpeningFcn, ...
                   'gui_OutputFcn',  @pop_fcvisual_parameters_OutputFcn, ...
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


% --- Executes just before pop_fcvisual_parameters is made visible.
function pop_fcvisual_parameters_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to pop_fcvisual_parameters (see VARARGIN)

% Choose default command line output for pop_fcvisual_parameters
handles.output = hObject;
a=varargin{1};
handles.popupmenu1.UserData=a;
handles.popupmenu2.UserData=a;
handles.popupmenu3.UserData=a;
handles.popupmenu4.UserData=a;
handles.popupmenu5.UserData=a;
handles.popupmenu6.UserData=a;
handles.pushbutton1.UserData=a;
handles.pushbutton2.UserData=a;
handles.pushbutton3.UserData=a;
handles.flag_init = 0;
% Choose default command line output for pop_fcvisual

% colormaps -- start
eeglab_path=which('eeglab');
eeglab_path=strrep(eeglab_path,'eeglab.m','');
s=dir(fullfile(eeglab_path,'plugins','FCLAB1.0.0','FC_colormap','fccolor*.m'));

% colormaps -- end
% set(gcf, 'units', 'normalized', 'outerposition', [0 0 1 1]);

% fieldnames=fields(a.FC);

%maintain only those fields that are related to the fcmetrics
eeglab_path = which('eeglab');
eeglab_path = strrep(eeglab_path,'eeglab.m','');
metrics_file = dir([eeglab_path 'plugins/FCLAB1.0.0/FC_metrics/fcmetric_*.m']);

for i = 1:length(metrics_file)
    measure_full = metrics_file(i,:).name;
    fcmetrics{i} = measure_full(10:end-2);
end

fieldnames_m = intersect(fields(a.FC), fcmetrics);

s=dir(fullfile(eeglab_path,'plugins','FCLAB1.0.0','FC_colormap','fccolor*.m'));
colors=[];
for i=1:length(s)
    aa=strsplit(s(i).name,'_');
    col=aa{1,2};
    colors{i,1}=col(1:end-2);
    clear aa col;
end
set(handles.popupmenu5, 'String', colors);

if isempty(fieldnames_m)
    error('FCLAB: Compute first a connectivity matrix!');
else
    fieldnames_freq = fields(a.FC.(fieldnames_m{1}));
    fieldnames_adj_matrix = fields(a.FC.(fieldnames_m{1}).(fieldnames_freq{1}));
    MST_cells = strfind(fieldnames_adj_matrix, 'MST_GP');
    MST_cells_pos = find(~cellfun(@isempty, MST_cells));
    MST_cells_final = fieldnames_adj_matrix(MST_cells_pos);
    
    GP_cells = strfind(fieldnames_adj_matrix, '_GP');
    GP_cells_pos = find(~cellfun(@isempty, GP_cells));
    GP_cells_final = fieldnames_adj_matrix(GP_cells_pos);
    
    fieldnames_adj_matrix_final = unique(vertcat(GP_cells_final, MST_cells_final));
    fieldnames_local_params = fields(a.FC.(fieldnames_m{1}).(fieldnames_freq{1}).(fieldnames_adj_matrix_final{1}).local);
    fieldnames_global_params = fields(a.FC.(fieldnames_m{1}).(fieldnames_freq{1}).(fieldnames_adj_matrix_final{1}).global);
    
    if (isempty(fieldnames_local_params) || isempty(fieldnames_global_params))
        error('FCLAB: Run first a graph analysis!');
    else  
        handles.popupmenu1.String = fieldnames_m;
        handles.popupmenu2.String = fieldnames_freq;
        handles.popupmenu3.String = fieldnames_local_params;
        handles.popupmenu4.String = fieldnames_global_params;
        handles.popupmenu6.String = fieldnames_adj_matrix_final;
        
        %disable option when only one version of the adjacency matrix is up
        if(length(fieldnames_adj_matrix_final) == 1)
            handles.popupmenu6.Visible = 'off';
            handles.text25.String = ' ';
        end
        
        axes(handles.axes1);
        adj_matrix = handles.popupmenu6.Value;
        local_measure = handles.popupmenu3.Value;
        local_measure_data = a.FC.(fieldnames_m{1}).(fieldnames_freq{1}).(fieldnames_adj_matrix_final{adj_matrix}).local.(fieldnames_local_params{local_measure});
        
        [f, xi] = ksdensity(local_measure_data);
        plot(xi,f, 'b'); grid on;

        axes(handles.axes2);
        h = histogram(local_measure_data, 15); grid on;
        set(h, 'EdgeColor', 'k', 'FaceColor', 'b');
        
        axes(handles.axes3);
        topoplot(local_measure_data, a.chanlocs, 'conv', 'on', 'colormap', eval(['fccolor_' handles.popupmenu5.String{handles.popupmenu5.Value} '(64)']));
        handles.axes3.Visible = 'off'; colorbar();
        handles.axes3.XLim = [handles.axes3.XLim(1)-0.05 handles.axes3.XLim(2)+0.05];
        handles.axes3.YLim = [handles.axes3.YLim(1)-0.05 handles.axes3.YLim(2)+0.05];
        
        global_measure = handles.popupmenu4.Value;
        global_measure_data = a.FC.(fieldnames_m{1}).(fieldnames_freq{1}).(fieldnames_adj_matrix_final{adj_matrix}).global.(fieldnames_global_params{global_measure});
    end
    
    handles.edit1.String = min(local_measure_data);
    handles.edit2.String = max(local_measure_data);
    handles.edit3.String = mean(local_measure_data);
    handles.edit4.String = std(local_measure_data);
    handles.edit5.String = global_measure_data;
end

handles.figure1.Color = [0.6431 0.7765 1.0000];

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes pop_fcvisual_parameters wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = pop_fcvisual_parameters_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


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


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2
axes(handles.axes1);
fieldname = handles.popupmenu1.String{handles.popupmenu1.Value}; %retrieve similarity measure
fieldname_freqband = handles.popupmenu2.String{hObject.Value}; %retrieve band
adj_matrix = handles.popupmenu6.String{handles.popupmenu6.Value}; %retrieve adjacency matrix
local_measure = handles.popupmenu3.String{handles.popupmenu3.Value}; %retrieve local measure name
local_measure_data = hObject.UserData.FC.(fieldname).(fieldname_freqband).(adj_matrix).local.(local_measure); %retrieve local measure data

[f, xi] = ksdensity(local_measure_data);
plot(xi,f, 'b'); grid on;

axes(handles.axes2);
h = histogram(local_measure_data, 15); grid on;
set(h, 'EdgeColor', 'k', 'FaceColor', 'b');

axes(handles.axes3);
topoplot(local_measure_data, hObject.UserData.chanlocs, 'conv', 'on', 'colormap', eval(['fccolor_' handles.popupmenu5.String{handles.popupmenu5.Value} '(64)']));
handles.axes3.Visible = 'off';  colorbar();
handles.axes3.XLim = [handles.axes3.XLim(1)-0.05 handles.axes3.XLim(2)+0.05];
handles.axes3.YLim = [handles.axes3.YLim(1)-0.05 handles.axes3.YLim(2)+0.05];

handles.edit1.String = min(local_measure_data);
handles.edit2.String = max(local_measure_data);
handles.edit3.String = mean(local_measure_data);
handles.edit4.String = std(local_measure_data);

global_measure = handles.popupmenu4.String{handles.popupmenu4.Value}; %retrieve global measure name
global_measure_data = hObject.UserData.FC.(fieldname).(fieldname_freqband).(adj_matrix).global.(global_measure); %retrieve global measure data
handles.edit5.String = global_measure_data;

% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3
axes(handles.axes1);
fieldname = handles.popupmenu1.String{handles.popupmenu1.Value}; %retrieve similarity measure
fieldname_freqband = handles.popupmenu2.String{handles.popupmenu2.Value}; %retrieve band
adj_matrix = handles.popupmenu6.String{handles.popupmenu6.Value}; %retrieve adjacency matrix
local_measure = hObject.String{hObject.Value}; %retrieve local measure name
local_measure_data = hObject.UserData.FC.(fieldname).(fieldname_freqband).(adj_matrix).local.(local_measure); %retrieve local measure

[f, xi] = ksdensity(local_measure_data);
plot(xi,f, 'b'); grid on;

axes(handles.axes2);
h = histogram(local_measure_data, 15); grid on;
set(h, 'EdgeColor', 'k', 'FaceColor', 'b');

% axes(handles.axes4); 
% colormap(eval([handles.popupmenu5.String{handles.popupmenu5.Value} '(64)']));
% h = colorbar('south'); set(h, 'ylim', [min(local_measure_data) max(local_measure_data)]);
% axis off;

axes(handles.axes3);
topoplot(local_measure_data, hObject.UserData.chanlocs, 'conv', 'on', 'colormap', eval(['fccolor_' handles.popupmenu5.String{handles.popupmenu5.Value} '(64)']));
handles.axes3.Visible = 'off'; colorbar();
handles.axes3.XLim = [handles.axes3.XLim(1)-0.05 handles.axes3.XLim(2)+0.05];
handles.axes3.YLim = [handles.axes3.YLim(1)-0.05 handles.axes3.YLim(2)+0.05];

handles.edit1.String = min(local_measure_data);
handles.edit2.String = max(local_measure_data);
handles.edit3.String = mean(local_measure_data);
handles.edit4.String = std(local_measure_data);
        
% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu4.
function popupmenu4_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu4
fieldname = handles.popupmenu1.String{handles.popupmenu1.Value}; %retrieve similarity measure
fieldname_freqband = handles.popupmenu2.String{handles.popupmenu2.Value}; %retrieve band
adj_matrix = handles.popupmenu6.String{handles.popupmenu6.Value}; %retrieve adjacency matrix
global_measure = hObject.String{hObject.Value}; %retrieve global measure name
global_measure_data = hObject.UserData.FC.(fieldname).(fieldname_freqband).(adj_matrix).global.(global_measure); %retrieve global measure data

handles.edit5.String = global_measure_data;

% --- Executes during object creation, after setting all properties.
function popupmenu4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in popupmenu5.
function popupmenu5_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu5
colormap(gcf, eval(['fccolor_' hObject.String{hObject.Value} '(64);']));
fieldname = handles.popupmenu1.String{handles.popupmenu1.Value}; %retrieve similarity measure
fieldname_freqband = handles.popupmenu2.String{handles.popupmenu2.Value}; %retrieve band
adj_matrix = handles.popupmenu6.String{handles.popupmenu6.Value}; %retrieve adjacency matrix
local_measure = handles.popupmenu3.String{handles.popupmenu3.Value}; %retrieve local measure name
local_measure_data = hObject.UserData.FC.(fieldname).(fieldname_freqband).(adj_matrix).local.(local_measure); %retrieve local measure data

axes(handles.axes3);
topoplot(local_measure_data, hObject.UserData.chanlocs, 'conv', 'on', 'colormap', eval(['fccolor_' hObject.String{hObject.Value} '(64)']));
handles.axes3.Visible = 'off'; colorbar();
handles.axes3.XLim = [handles.axes3.XLim(1)-0.05 handles.axes3.XLim(2)+0.05];
handles.axes3.YLim = [handles.axes3.YLim(1)-0.05 handles.axes3.YLim(2)+0.05];

% --- Executes during object creation, after setting all properties.
function popupmenu5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in popupmenu6.
function popupmenu6_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu6 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu6
axes(handles.axes1);
fieldname = handles.popupmenu1.String{handles.popupmenu1.Value}; %retrieve similarity measure
fieldname_freqband = handles.popupmenu2.String{handles.popupmenu2.Value}; %retrieve band
adj_matrix = hObject.String{hObject.Value}; %retrieve adjacency matrix
handles.popupmenu3.String = fieldnames(hObject.UserData.FC.(fieldname).(fieldname_freqband).(adj_matrix).local);
handles.popupmenu3.Value = 1;
local_measure = handles.popupmenu3.String{handles.popupmenu3.Value}; %retrieve local measure name
local_measure_data = hObject.UserData.FC.(fieldname).(fieldname_freqband).(adj_matrix).local.(local_measure); %retrieve local measure data

[f, xi] = ksdensity(local_measure_data);
plot(xi,f, 'b'); grid on;

axes(handles.axes2);
h = histogram(local_measure_data, 15); grid on;
set(h, 'EdgeColor', 'k', 'FaceColor', 'b');

axes(handles.axes3);
topoplot(local_measure_data, hObject.UserData.chanlocs, 'conv', 'on', 'colormap', eval(['fccolor_' handles.popupmenu5.String{handles.popupmenu5.Value} '(64)']));
handles.axes3.Visible = 'off';  colorbar();
handles.axes3.XLim = [handles.axes3.XLim(1)-0.05 handles.axes3.XLim(2)+0.05];
handles.axes3.YLim = [handles.axes3.YLim(1)-0.05 handles.axes3.YLim(2)+0.05];

handles.edit1.String = min(local_measure_data);
handles.edit2.String = max(local_measure_data);
handles.edit3.String = mean(local_measure_data);
handles.edit4.String = std(local_measure_data);

handles.popupmenu4.String = fieldnames(hObject.UserData.FC.(fieldname).(fieldname_freqband).(adj_matrix).global);
global_measure = handles.popupmenu4.String{handles.popupmenu4.Value}; %retrieve global measure name
global_measure_data = hObject.UserData.FC.(fieldname).(fieldname_freqband).(adj_matrix).global.(global_measure); %retrieve global measure data
handles.edit5.String = global_measure_data;

% --- Executes during object creation, after setting all properties.
function popupmenu6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


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



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
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
h = figure('units','normalized','outerposition',[0.2 0.2 0.6 0.8]);
fieldname = handles.popupmenu1.String{handles.popupmenu1.Value}; %retrieve similarity measure
fieldname_freqband = handles.popupmenu2.String{handles.popupmenu2.Value}; %retrieve band
adj_matrix = handles.popupmenu6.String{handles.popupmenu6.Value}; %retrieve adjacency matrix
local_measure = handles.popupmenu3.String{handles.popupmenu3.Value}; %retrieve local measure name
local_measure_data = hObject.UserData.FC.(fieldname).(fieldname_freqband).(adj_matrix).local.(local_measure); %retrieve local measure data

[f, xi] = ksdensity(local_measure_data);
plot(xi,f, 'b'); grid on;
set(h, 'color', [0.6430 0.7760 1.0000]);


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h = figure('units','normalized','outerposition',[0.2 0.2 0.6 0.8]);
fieldname = handles.popupmenu1.String{handles.popupmenu1.Value}; %retrieve similarity measure
fieldname_freqband = handles.popupmenu2.String{handles.popupmenu2.Value}; %retrieve band
adj_matrix = handles.popupmenu6.String{handles.popupmenu6.Value}; %retrieve adjacency matrix
local_measure = handles.popupmenu3.String{handles.popupmenu3.Value}; %retrieve local measure name
local_measure_data = hObject.UserData.FC.(fieldname).(fieldname_freqband).(adj_matrix).local.(local_measure); %retrieve local measure data

h1 = histogram(local_measure_data, 15); grid on;
set(h1, 'EdgeColor', 'k', 'FaceColor', 'b');
set(h, 'color', [0.6430 0.7760 1.0000]);

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h = figure('units','normalized','outerposition',[0.2 0.2 0.6 0.8]);
fieldname = handles.popupmenu1.String{handles.popupmenu1.Value}; %retrieve similarity measure
fieldname_freqband = handles.popupmenu2.String{handles.popupmenu2.Value}; %retrieve band
adj_matrix = handles.popupmenu6.String{handles.popupmenu6.Value}; %retrieve adjacency matrix
local_measure = handles.popupmenu3.String{handles.popupmenu3.Value}; %retrieve local measure name
local_measure_data = hObject.UserData.FC.(fieldname).(fieldname_freqband).(adj_matrix).local.(local_measure); %retrieve local measure data

topoplot(local_measure_data, hObject.UserData.chanlocs, 'conv', 'on', 'colormap', eval(['fccolor_' handles.popupmenu5.String{handles.popupmenu5.Value} '(64)']));
% handles.axes3.Visible = 'off'; colorbar();
% handles.axes3.XLim = [handles.axes3.XLim(1)-0.05 handles.axes3.XLim(2)+0.05];
% handles.axes3.YLim = [handles.axes3.YLim(1)-0.05 handles.axes3.YLim(2)+0.05];
