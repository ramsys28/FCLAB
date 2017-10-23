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

% Last Modified by GUIDE v2.5 22-Oct-2017 01:32:09

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
handles.pushbutton1.UserData=a;
handles.pushbutton2.UserData=a;
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

fieldnames = intersect(fields(a.FC), fcmetrics);

if isempty(fieldnames)
    error('FCLAB: Compute first a connectivity matrix!');
else
    fieldnames_freq = fields(a.FC.(fieldnames{1}));
    fieldnames_local_params = fields(a.FC.(fieldnames{1}).(fieldnames_freq{1}).adj_matrix_GP.local);
    fieldnames_global_params = fields(a.FC.(fieldnames{1}).(fieldnames_freq{1}).adj_matrix_GP.global);
    fieldnames_local_MST_params = fields(a.FC.(fieldnames{1}).(fieldnames_freq{1}).MST_params.local);
    fieldnames_global_MST_params = fields(a.FC.(fieldnames{1}).(fieldnames_freq{1}).MST_params.global);
    fieldnames_total_local_params = vertcat(fieldnames_local_params, fieldnames_local_MST_params);
    fieldnames_total_global_params = vertcat(fieldnames_global_params, fieldnames_global_MST_params);
    
    if (isempty(fieldnames_local_params) | isempty(fieldnames_global_params))
        error('FCLAB: Run first a graph analysis!');
    else  
        handles.popupmenu1.String = fieldnames;
        handles.popupmenu2.String = fieldnames_freq;
        handles.popupmenu3.String = fieldnames_total_local_params;
        handles.popupmenu4.String = fieldnames_total_global_params;
        
        axes(handles.axes1);
        local_measure = handles.popupmenu3.Value;
        if(local_measure <= 5)
            local_measure_data = a.FC.(fieldnames{1}).(fieldnames_freq{1}).adj_matrix_GP.local.(fieldnames_local_params{local_measure});
        else
            local_measure_data = a.FC.(fieldnames{1}).(fieldnames_freq{1}).MST_params.local.(fieldnames_local_MST_params{local_measure});
        end
        
        [f, xi] = ksdensity(local_measure_data);
        plot(xi,f, 'b'); grid on;
        
        axes(handles.axes2);
        h = histogram(local_measure_data, 15); grid on;
        set(h, 'EdgeColor', 'k', 'FaceColor', 'b');
        
        global_measure = handles.popupmenu4.Value;
        if(global_measure <= 11)
            global_measure_data = a.FC.(fieldnames{1}).(fieldnames_freq{1}).adj_matrix_GP.global.(fieldnames_global_params{global_measure});
        else
            global_measure_data = a.FC.(fieldnames{1}).(fieldnames_freq{1}).MST_params.global.(fieldnames_global_MST_params{global_measure});
        end 
    end
    
    handles.edit1.String = min(local_measure_data);
    handles.edit2.String = max(local_measure_data);
    handles.edit3.String = mean(local_measure_data);
    handles.edit4.String = std(local_measure_data);
    handles.edit5.String = global_measure_data;
end

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
if(handles.popupmenu3.Value <= 5)
    local_measure_data = hObject.UserData.FC.(fieldname).(fieldname_freqband).adj_matrix_GP.local.(handles.popupmenu3.String{handles.popupmenu3.Value}); %retrieve local measure
else
    local_measure_data = hObject.UserData.FC.(fieldname).(fieldname_freqband).MST_params.local.(handles.popupmenu3.String{handles.popupmenu3.Value}); %retrieve local measure
end
[f, xi] = ksdensity(local_measure_data);
plot(xi,f, 'b'); grid on;

axes(handles.axes2);
h = histogram(local_measure_data, 15); grid on;
set(h, 'EdgeColor', 'k', 'FaceColor', 'b');

handles.edit1.String = min(local_measure_data);
handles.edit2.String = max(local_measure_data);
handles.edit3.String = mean(local_measure_data);
handles.edit4.String = std(local_measure_data);

if(handles.popupmenu4.Value <= 11)
    global_measure_data = hObject.UserData.FC.(fieldname).(fieldname_freqband).adj_matrix_GP.global.(handles.popupmenu4.String{handles.popupmenu4.Value}); %retrieve local measure
else
    global_measure_data = hObject.UserData.FC.(fieldname).(fieldname_freqband).MST_params.global.(handles.popupmenu4.String{handles.popupmenu4.Value}); %retrieve local measure
end
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
if(hObject.Value <= 5)
    local_measure_data = hObject.UserData.FC.(fieldname).(fieldname_freqband).adj_matrix_GP.local.(handles.popupmenu3.String{hObject.Value}); %retrieve local measure
else
    local_measure_data = hObject.UserData.FC.(fieldname).(fieldname_freqband).MST_params.local.(handles.popupmenu3.String{hObject.Value}); %retrieve local measure
end
[f, xi] = ksdensity(local_measure_data);
plot(xi,f, 'b'); grid on;

axes(handles.axes2);
h = histogram(local_measure_data, 15); grid on;
set(h, 'EdgeColor', 'k', 'FaceColor', 'b');

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
if(hObject.Value <= 11)
    global_measure_data = hObject.UserData.FC.(fieldname).(fieldname_freqband).adj_matrix_GP.global.(handles.popupmenu4.String{hObject.Value}); %retrieve local measure
else
    global_measure_data = hObject.UserData.FC.(fieldname).(fieldname_freqband).MST_params.global.(handles.popupmenu4.String{hObject.Value}); %retrieve local measure
end

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
if(handles.popupmenu3.Value <= 5)
    local_measure_data = hObject.UserData.FC.(fieldname).(fieldname_freqband).adj_matrix_GP.local.(handles.popupmenu3.String{handles.popupmenu3.Value}); %retrieve local measure
else
    local_measure_data = hObject.UserData.FC.(fieldname).(fieldname_freqband).MST_params.local.(handles.popupmenu3.String{handles.popupmenu3.Value}); %retrieve local measure
end
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
if(handles.popupmenu3.Value <= 5)
    local_measure_data = hObject.UserData.FC.(fieldname).(fieldname_freqband).adj_matrix_GP.local.(handles.popupmenu3.String{handles.popupmenu3.Value}); %retrieve local measure
else
    local_measure_data = hObject.UserData.FC.(fieldname).(fieldname_freqband).MST_params.local.(handles.popupmenu3.String{handles.popupmenu3.Value}); %retrieve local measure
end
h1 = histogram(local_measure_data, 15); grid on;
set(h1, 'EdgeColor', 'k', 'FaceColor', 'b');
set(h, 'color', [0.6430 0.7760 1.0000]);
