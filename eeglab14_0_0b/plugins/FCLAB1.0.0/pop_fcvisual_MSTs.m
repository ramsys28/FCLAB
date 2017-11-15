function varargout = pop_fcvisual_MSTs(varargin)
% POP_FCVISUAL_MSTS MATLAB code for pop_fcvisual_MSTs.fig
%      POP_FCVISUAL_MSTS, by itself, creates a new POP_FCVISUAL_MSTS or raises the existing
%      singleton*.
%
%      H = POP_FCVISUAL_MSTS returns the handle to a new POP_FCVISUAL_MSTS or the handle to
%      the existing singleton*.
%
%      POP_FCVISUAL_MSTS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in POP_FCVISUAL_MSTS.M with the given input arguments.
%
%      POP_FCVISUAL_MSTS('Property','Value',...) creates a new POP_FCVISUAL_MSTS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before pop_fcvisual_MSTs_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to pop_fcvisual_MSTs_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help pop_fcvisual_MSTs

% Last Modified by GUIDE v2.5 15-Nov-2017 12:55:18
          
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @pop_fcvisual_MSTs_OpeningFcn, ...
                   'gui_OutputFcn',  @pop_fcvisual_MSTs_OutputFcn, ...
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


% --- Executes just before pop_fcvisual_MSTs is made visible.a
function pop_fcvisual_MSTs_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to pop_fcvisual_MSTs (see VARARGIN)

a=varargin{1};
handles.popupmenu1.UserData=a;
handles.popupmenu2.UserData=a;
handles.popupmenu3.UserData=a;
handles.popupmenu4.UserData=a;
handles.pushbutton1.UserData=a;
handles.pushbutton2.UserData=a;
handles.pushbutton3.UserData=a;
% Choose default command line output for pop_fcvisual_MSTs

% colormaps -- start
eeglab_path=which('eeglab');
eeglab_path=strrep(eeglab_path,'eeglab.m','');
s=dir(fullfile(eeglab_path,'plugins','FCLAB1.0.0','FC_colormap','fccolor*.m'));
colors=[];
for i=1:length(s)
    aa=strsplit(s(i).name,'_');
    col=aa{1,2};
    colors{i,1}=col(1:end-2);
    clear aa col
end
% set(handles.popupmenu1, 'String', colors);
% colormaps -- end

set(gcf, 'units', 'normalized', 'outerposition', [0 0 1 1]);
metrics_file = dir([eeglab_path 'plugins/FCLAB1.0.0/FC_metrics/fcmetric_*.m']);

for i = 1:length(metrics_file)
    measure_full = metrics_file(i,:).name;
    fcmetrics{i} = measure_full(10:end-2);
end


if ~isfield(a, 'FC')
    error('FCLAB: Compute first a connectivity matrix'); return;
else
    fieldnames = intersect(fields(a.FC), fcmetrics);
    fieldnames_freq = fields(a.FC.(fieldnames{1}));
end

MST_cells = strfind(fields(a.FC.(fieldnames{1}).(fieldnames_freq{1})), 'MST');
MST_GP_cells = strfind(fields(a.FC.(fieldnames{1}).(fieldnames_freq{1})), 'MST_GP');
fieldnames_total = fields(a.FC.(fieldnames{1}).(fieldnames_freq{1}));
MST_fields = find(~cellfun(@isempty, MST_cells));
MST_GP_fields = find(~cellfun(@isempty, MST_GP_cells));
[~, MST_common_fields, ~] = intersect(MST_fields, MST_GP_fields);
MST_fields(MST_common_fields) = [];
MST_fields_total = fieldnames_total(MST_fields);

if (isempty(MST_fields_total))
    error('FCLAB: Run first an MST analysis'); return;
else
    handles.popupmenu4.String = MST_fields_total;
    handles.popupmenu2.String = fieldnames;
    handles.popupmenu3.String = fieldnames_freq;
    handles.popupmenu1.String = colors;
    
    axes(handles.axes1);
    imagesc(a.FC.(fieldnames{1}).(fieldnames_freq{1}).(MST_fields_total{1}).Kruskal);
%     eval(['colormap(fccolor_' handles.popupmenu1.String{1} '(64));']);
    eval(['colormap(fccolor_hot(64));']);
    handles.axes1.XTick=[1:a.nbchan];
    chanlabels=[];
    
    for i=1:a.nbchan
        chanlabels{i,1}=a.chanlocs(i).labels;
    end
    
    handles.axes1.XTickLabel=chanlabels;
    handles.axes1.XTickLabelRotation=90;
    handles.axes1.Visible='on';
    handles.axes1.YTick=handles.axes1.XTick;
    handles.axes1.YTickLabel=chanlabels;
    
    aa = a.FC.(fieldnames{1}).(fieldnames_freq{1}).(MST_fields_total{1}).Kruskal;
    bb = a.FC.(fieldnames{1}).(fieldnames_freq{1}).adj_matrix .* aa;
    
    if ~isempty(a.chanlocs) 
        ds.chanPairs = [];
        ds.connectStrength = [];
        
        ds2.chanPairs = [];
        ds2.connectStrength = [];
        
        for i=1:a.nbchan-1
            for j=i+1:a.nbchan
                if(aa(i,j)~=0)
                    ds.chanPairs = [ds.chanPairs; i j];
                    ds.connectStrength = [ds.connectStrength aa(i,j)];
                end
                
                if(bb(i,j)~=0)               
                    ds2.chanPairs = [ds2.chanPairs; i j];
                    ds2.connectStrength = [ds2.connectStrength bb(i,j)]; 
                end
            end
        end    
        handles.ds = ds;
        handles.ds2 = ds2;
        
        axes(handles.axes2);
        eval(['topoplot_connect(ds,a.chanlocs,fccolor_' handles.popupmenu1.String{handles.popupmenu1.Value} '(1));']);
        handles.axes2.Visible = 'off';
        
        axes(handles.axes3);
        eval(['topoplot_connect(ds2,a.chanlocs,fccolor_' handles.popupmenu1.String{handles.popupmenu1.Value} '(64));']);
        handles.axes3.Visible = 'off';
        
        axes(handles.axes7);
        eval(['colormap(fccolor_' handles.popupmenu1.String{handles.popupmenu1.Value} '(64));']);
        colorbar('south');
        
        set(gcf, 'units', 'normalized', 'outerposition', [0 0 1 1]);
        handles.UserData = a;
    else
        error('fcvisual: need channels for topoplot!'); return;
    end  
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes pop_fcvisual_MSTs wait for user response (see UIRESUME)
%  uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = pop_fcvisual_MSTs_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
%varargout{1} = handles.output;
set(gcf, 'units', 'normalized', 'outerposition', [0 0 1 1]);


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1

% colormap(gcf, eval(['fccolor_'...
%     handles.popupmenu1.String{handles.popupmenu1.Value} '(64);']));

aa = hObject.UserData.FC.(handles.popupmenu2.String{handles.popupmenu2.Value}).(handles.popupmenu3.String{handles.popupmenu3.Value}).(handles.popupmenu4.String{handles.popupmenu4.Value}).Kruskal;
bb = hObject.UserData.FC.(handles.popupmenu2.String{handles.popupmenu2.Value}).(handles.popupmenu3.String{handles.popupmenu3.Value}).adj_matrix .* aa;
a = hObject.UserData;

if ~isempty(hObject.UserData.chanlocs)
    ds.chanPairs=[];
    ds.connectStrength=[];
    
    ds2.chanPairs=[];
    ds2.connectStrength=[];
    
    for i=1:hObject.UserData.nbchan-1
        for j=i+1:hObject.UserData.nbchan
            if(aa(i,j)~=0)
                ds.chanPairs=[ds.chanPairs; i j];
                ds.connectStrength=[ds.connectStrength;aa(i,j)];
            end
            
            if(bb(i,j)~=0)
                ds2.chanPairs=[ds2.chanPairs; i j];
                ds2.connectStrength=[ds2.connectStrength;bb(i,j)];
            end
        end
    end
    handles.ds = ds;
    handles.ds2 = ds2;
    
    axes(handles.axes7);
    eval(['colormap(handles.axes7, fccolor_' handles.popupmenu1.String{handles.popupmenu1.Value} '(64));']);
    colorbar('south');
    
    axes(handles.axes3);
    eval(['topoplot_connect(ds2,a.chanlocs,fccolor_' handles.popupmenu1.String{handles.popupmenu1.Value} '(64));']);
    handles.axes3.Visible = 'off';
end

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

% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2
aa = hObject.UserData.FC.(handles.popupmenu2.String{handles.popupmenu2.Value}).(handles.popupmenu3.String{handles.popupmenu3.Value}).(handles.popupmenu4.String{handles.popupmenu4.Value}).Kruskal;
bb = hObject.UserData.FC.(handles.popupmenu2.String{handles.popupmenu2.Value}).(handles.popupmenu3.String{handles.popupmenu3.Value}).adj_matrix .* aa;

axes(handles.axes1);
imagesc(aa);
eval(['colormap(fccolor_' handles.popupmenu1.String{handles.popupmenu1.Value} '(64));']);
a = hObject.UserData;
handles.axes1.XTick = [1:a.nbchan];
chanlabels = [];
for i=1:a.nbchan
    chanlabels{i,1}=a.chanlocs(i).labels;
end
handles.axes1.XTickLabel=chanlabels;
handles.axes1.XTickLabelRotation=90;
handles.axes1.Visible='on';
handles.axes1.YTick=handles.axes1.XTick;
handles.axes1.YTickLabel=chanlabels;

ds.chanPairs = [];
ds.connectStrength = [];

ds2.chanPairs = [];
ds2.connectStrength = [];

for i=1:a.nbchan-1
    for j=i+1:a.nbchan
        if(aa(i,j)~=0)
            ds.chanPairs = [ds.chanPairs; i j];
            ds.connectStrength = [ds.connectStrength; aa(i,j)];
        end
        
        if(bb(i,j)~=0)
            ds2.chanPairs = [ds2.chanPairs; i j];
            ds2.connectStrength = [ds2.connectStrength; bb(i,j)];
        end        
    end
end
handles.ds = ds;
handles.ds2 = ds2;

axes(handles.axes2);
eval(['topoplot_connect(ds,a.chanlocs,fccolor_' handles.popupmenu1.String{handles.popupmenu1.Value} '(1));']);

axes(handles.axes3);
eval(['topoplot_connect(ds2,a.chanlocs,fccolor_' handles.popupmenu1.String{handles.popupmenu1.Value} '(64));']);

% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.

%set(hObject,'String',fieldnames(varargin))
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end

% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3
aa = hObject.UserData.FC.(handles.popupmenu2.String{handles.popupmenu2.Value}).(handles.popupmenu3.String{handles.popupmenu3.Value}).(handles.popupmenu4.String{handles.popupmenu4.Value}).Kruskal;
bb = hObject.UserData.FC.(handles.popupmenu2.String{handles.popupmenu2.Value}).(handles.popupmenu3.String{handles.popupmenu3.Value}).adj_matrix .* aa;
a = hObject.UserData;

axes(handles.axes1);
imagesc(aa);
handles.axes1.XTick=[1:a.nbchan];
chanlabels=[];
for i=1:a.nbchan
    chanlabels{i,1}=a.chanlocs(i).labels;
end
handles.axes1.XTickLabel=chanlabels;
handles.axes1.XTickLabelRotation=90;
handles.axes1.Visible='on';
handles.axes1.YTick=handles.axes1.XTick;
handles.axes1.YTickLabel=chanlabels;

ds.chanPairs = [];
ds.connectStrength = [];

ds2.chanPairs = [];
ds2.connectStrength = [];

for i=1:a.nbchan-1
    for j=i+1:a.nbchan
        if(aa(i,j)~=0)
            ds.chanPairs = [ds.chanPairs; i j];
            ds.connectStrength = [ds.connectStrength; aa(i,j)];
        end
        
        if(bb(i,j)~=0)
            ds2.chanPairs = [ds2.chanPairs; i j];
            ds2.connectStrength = [ds2.connectStrength; bb(i,j)];
        end        
    end
end

handles.ds = ds;
handles.ds2 = ds2;

axes(handles.axes2);
eval(['topoplot_connect(ds,a.chanlocs,fccolor_' handles.popupmenu1.String{handles.popupmenu1.Value} '(1));']);

axes(handles.axes3);
eval(['topoplot_connect(ds2,a.chanlocs,fccolor_' handles.popupmenu1.String{handles.popupmenu1.Value} '(64));']);

guidata(hObject, handles);

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
aa = hObject.UserData.FC.(handles.popupmenu2.String{handles.popupmenu2.Value}).(handles.popupmenu3.String{handles.popupmenu3.Value}).(handles.popupmenu4.String{handles.popupmenu4.Value}).Kruskal;
bb = hObject.UserData.FC.(handles.popupmenu2.String{handles.popupmenu2.Value}).(handles.popupmenu3.String{handles.popupmenu3.Value}).adj_matrix .* aa;
a = hObject.UserData;

axes(handles.axes1);
imagesc(aa);
handles.axes1.XTick=[1:a.nbchan];
chanlabels=[];
for i=1:a.nbchan
    chanlabels{i,1}=a.chanlocs(i).labels;
end
handles.axes1.XTickLabel=chanlabels;
handles.axes1.XTickLabelRotation=90;
handles.axes1.Visible='on';
handles.axes1.YTick=handles.axes1.XTick;
handles.axes1.YTickLabel=chanlabels;

ds.chanPairs = [];
ds.connectStrength = [];

ds2.chanPairs = [];
ds2.connectStrength = [];

for i=1:a.nbchan-1
    for j=i+1:a.nbchan
        if(aa(i,j)~=0)
            ds.chanPairs = [ds.chanPairs; i j];
            ds.connectStrength = [ds.connectStrength; aa(i,j)];
        end
        
        if(bb(i,j)~=0)
            ds2.chanPairs = [ds2.chanPairs; i j];
            ds2.connectStrength = [ds2.connectStrength; bb(i,j)];
        end        
    end
end

axes(handles.axes2);
eval(['topoplot_connect(ds,a.chanlocs,fccolor_' handles.popupmenu1.String{handles.popupmenu1.Value} '(1));']);

axes(handles.axes3);
eval(['topoplot_connect(ds2,a.chanlocs,fccolor_' handles.popupmenu1.String{handles.popupmenu1.Value} '(64));']);

guidata(hObject, handles);

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


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

h = figure('units','normalized','outerposition',[0.2 0.2 0.6 0.8]);
aa = hObject.UserData.FC.(handles.popupmenu2.String{handles.popupmenu2.Value}).(handles.popupmenu3.String{handles.popupmenu3.Value}).(handles.popupmenu4.String{handles.popupmenu4.Value}).Kruskal;
a = hObject.UserData;

imagesc(aa); eval(['colormap(fccolor_hot(64));']);
chanlabels = [];
for i = 1:a.nbchan
    chanlabels{i,1} = a.chanlocs(i).labels;
end
set(gca, 'XTick', [1:a.nbchan], 'XTickLabel', chanlabels, 'XTickLabelRotation', 90);
set(gca, 'YTick', [1:a.nbchan], 'YTickLabel', chanlabels);
title('Adjacency matrix', 'FontSize', 18);
set(h, 'color', [0.6430 0.7760 1.0000]);

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

figure('units','normalized','outerposition',[0.2 0.2 0.6 0.8]);
eval(['topoplot_connect(handles.ds,hObject.UserData.chanlocs,fccolor_hot(1));']);
title('Head Model', 'FontSize', 18);

% --- Executes on button press in pushbutton4.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

figure('units','normalized','outerposition',[0.2 0.2 0.6 0.8]);
eval(['topoplot_connect(handles.ds2,hObject.UserData.chanlocs,fccolor_' handles.popupmenu1.String{handles.popupmenu1.Value} '(64));']);
title('Weighted Head Model', 'FontSize', 18);

% --- Executes when figure1 is resized.
function figure1_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
