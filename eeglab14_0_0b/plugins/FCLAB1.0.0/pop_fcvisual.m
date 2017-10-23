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

% Last Modified by GUIDE v2.5 04-Sep-2017 14:17:42
          
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


% --- Executes just before pop_fcvisual is made visible.a
function pop_fcvisual_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to pop_fcvisual (see VARARGIN)

a=varargin{1};
handles.popupmenu1.UserData=a;
handles.pushbutton2.UserData=a;
handles.popupmenu3.UserData=a;
handles.pushbutton3.UserData=a;
handles.pushbutton4.UserData=a;
% Choose default command line output for pop_fcvisual

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
set(handles.popupmenu1, 'String', colors);
% colormaps -- end

set(gcf, 'units', 'normalized', 'outerposition', [0 0 1 1]);
fieldnames = fields(a.FC);
% fieldnames(strcmp(fieldnames,'parameters'))=[];

%maintain only those fields that are related to the fcmetrics
metrics_file = dir([eeglab_path 'plugins/FCLAB1.0.0/FC_metrics/fcmetric_*.m']);

for i = 1:length(metrics_file)
    measure_full = metrics_file(i,:).name;
    fcmetrics{i} = measure_full(10:end-2);
end

fieldnames = intersect(fields(a.FC), fcmetrics);

if isempty(fieldnames)
    error('FCLAB: Compute first a connectivity matrix')
else
    handles.popupmenu2.String=fieldnames;
    fieldnames_freq=fields(a.FC.(fieldnames{1}));
    handles.popupmenu3.String=fieldnames_freq;
    axes(handles.axes1);
    imagesc(a.FC.(fieldnames{1}).(fieldnames_freq{1}).adj_matrix);
    hold all
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
    
    if ~isempty(a.chanlocs)
        ds.chanPairs=[];
        ds.connectStrength=[];
        
        for i=1:a.nbchan-1
            for j=i+1:a.nbchan
                ds.chanPairs=[ds.chanPairs; i j];
                ds.connectStrength=[ds.connectStrength...
                    a.FC.(fieldnames{1}).(fieldnames_freq{1}).adj_matrix(i,j)]; 
            end
        end
        
        handles.ds = ds;%!!!
        axes(handles.axes2);
        eval(['topoplot_connect(ds,a.chanlocs,fccolor_' handles.popupmenu1.String{handles.popupmenu1.Value} '(64));']);
        handles.axes2.Visible='off'; %!!!
        colormap(eval(['fccolor_' handles.popupmenu1.String{handles.popupmenu1.Value} '(64);']));
        para.rot=90;
        locs(:,1)=cell2mat({a.chanlocs.X});
        locs(:,2)=cell2mat({a.chanlocs.Y});
        locs(:,3)=cell2mat({a.chanlocs.Z});
        locs_2D=mk_sensors_plane(locs,para);
        
        hp=handles.uipanel2;
        showcs(a.FC.(fieldnames{1}).(fieldnames_freq{1}).adj_matrix,locs_2D,para,hp);
        
        hp.Visible='on';
        axes(handles.axes7);
        colormap(handles.popupmenu1.String{handles.popupmenu1.Value});
        colorbar('south');
        set(gca, 'CLim', [-1 1]);
        
        handles.slider1.Min=min(min(a.FC.(fieldnames{1}).(fieldnames_freq{1}).adj_matrix));
        handles.slider1.Max=max(max(a.FC.(fieldnames{1}).(fieldnames_freq{1}).adj_matrix));
        handles.slider1.Max=handles.slider1.Max-eps;
        handles.slider1.Value=handles.slider1.Min;
        handles.edit1.String=num2str(handles.slider1.Value);
        set(gcf, 'units', 'normalized', 'outerposition', [0 0 1 1]);
    else
        %%error need channels for topoplot
    end;
     
end;

% Update handles structure
guidata(hObject, handles);


%G = evalin('base', 'EEG.FC.Correlation.adj_matrix');
%axes(handles.axes1);
%imagesc(double(G)); colormap(jet); colorbar;

% UIWAIT makes pop_fcvisual wait for user response (see UIRESUME)
 uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = pop_fcvisual_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
%varargout{1} = handles.output;
set(gcf, 'units', 'normalized', 'outerposition', [0 0 1 1]);


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
handles.slider1.Value=str2num(hObject.String);
slider1_Callback(handles.slider1, eventdata, handles);
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

% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1

colormap(gcf, eval(['fccolor_'...
    handles.popupmenu1.String{handles.popupmenu1.Value} '(64);']));

aa=hObject.UserData.FC.(handles.popupmenu2.String{handles.popupmenu2.Value}).(handles.popupmenu3.String{handles.popupmenu3.Value}).adj_matrix;
aa(aa<handles.slider1.Value)=0;

if ~isempty(hObject.UserData.chanlocs)
    ds.chanPairs=[];
    ds.connectStrength=[];

    for i=1:hObject.UserData.nbchan-1
        for j=i+1:hObject.UserData.nbchan
            if(aa(i,j)~=0)
                ds.chanPairs=[ds.chanPairs; i j];
                ds.connectStrength=[ds.connectStrength;aa(i,j)];
            end
        end
    end
    
    handles.ds = ds;%!!!    
    axes(handles.axes2);
    eval(['topoplot_connect(ds,hObject.UserData.chanlocs,fccolor_' handles.popupmenu1.String{handles.popupmenu1.Value} '(64));']);
    
    handles.slider1.Min=min(min(aa));
    handles.slider1.Max=max(max(aa));
    handles.slider1.Max=handles.slider1.Max-eps;
    handles.slider1.Value=handles.slider1.Min;
    handles.edit1.String=num2str(handles.slider1.Value);
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
metrics = cellstr(get(hObject,'String'));
bands = cellstrt(get(handles.popupmenu3,'String'));
%a=varargin{1};
axes(handles.axes1); 
eval(['imagesc(double(a.FC.' metrics{get(hObject,'Value')} '.' bands '.adj_matrix)); colormap(jet); colorbar;']);     

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

% band = handles.popupmenu2.Value;
% % figure('units','normalized','outerposition',[0 0 1 1]);
% eval(['imagesc(double(a.FC.Correlation.' band '.adj_matrix)); colormap(jet); colorbar;']);

% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3
aa=hObject.UserData.FC.(handles.popupmenu2.String{handles.popupmenu2.Value}).(handles.popupmenu3.String{handles.popupmenu3.Value}).adj_matrix;
aa(aa<handles.slider1.Value)=0;
axes(handles.axes1);
imagesc(aa,[-1,1]);
a=hObject.UserData;
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
handles.edit1.String=num2str(handles.slider1.Value);

ds.chanPairs=[];
ds.connectStrength=[];
for i=1:a.nbchan-1
    for j=i+1:a.nbchan
        if(aa(i,j)~=0)
            ds.chanPairs=[ds.chanPairs; i j];
            ds.connectStrength=[ds.connectStrength;aa(i,j)];
        end
    end
end
ds.connectStrengthLimits=[-1 1];
handles.ds = ds;%!!!

axes(handles.axes2);
eval(['topoplot_connect(ds,a.chanlocs,fccolor_' handles.popupmenu1.String{handles.popupmenu1.Value} '(64));']);
para.rot=90;
locs(:,1)=cell2mat({a.chanlocs.X});
locs(:,2)=cell2mat({a.chanlocs.Y});
locs(:,3)=cell2mat({a.chanlocs.Z});
locs_2D=mk_sensors_plane(locs,para);

hp=handles.uipanel2;
showcs(aa, locs_2D, para, hp);

handles.slider1.Min=min(min(aa));
handles.slider1.Max=max(max(aa));
handles.slider1.Max=handles.slider1.Max-eps;
handles.slider1.Value=handles.slider1.Min;
handles.edit1.String=num2str(handles.slider1.Value);
    
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

% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
aa=hObject.UserData.FC.(handles.popupmenu2.String{handles.popupmenu2.Value}).(handles.popupmenu3.String{handles.popupmenu3.Value}).adj_matrix;
axes(handles.axes1);
aa(aa<hObject.Value)=0;
imagesc(aa,[-1,1]);
a=hObject.UserData;
handles.axes1.XTick=[1:a.nbchan];
chanlabels=[];
for i=1:a.nbchan
    chanlabels{i,1}=a.chanlocs(i).labels;
end;
handles.axes1.XTickLabel=chanlabels;
handles.axes1.XTickLabelRotation=90;
handles.axes1.Visible='on';
handles.axes1.YTick=handles.axes1.XTick;
handles.axes1.YTickLabel=chanlabels;
handles.edit1.String=num2str(hObject.Value);

ds.chanPairs=[];
ds.connectStrength=[];

for i=1:a.nbchan-1
    for j=i+1:a.nbchan
        if(aa(i,j)~=0)
            ds.chanPairs=[ds.chanPairs; i j];
            ds.connectStrength=[ds.connectStrength;aa(i,j)];
        end;
    end;
end;
ds.connectStrengthLimits=[-1 1];
handles.ds = ds;%!!!
axes(handles.axes2);
eval(['topoplot_connect(ds,a.chanlocs,fccolor_' handles.popupmenu1.String{handles.popupmenu1.Value} '(64));']);
para.rot=90;
locs(:,1)=cell2mat({a.chanlocs.X});
locs(:,2)=cell2mat({a.chanlocs.Y});
locs(:,3)=cell2mat({a.chanlocs.Z});
locs_2D=mk_sensors_plane(locs,para);

hp=handles.uipanel2;
showcs(aa,locs_2D,para,hp);

guidata(hObject, handles);


% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% band = handles.popupmenu2.Value;
h = figure('units','normalized','outerposition',[0.2 0.2 0.6 0.8]);
aa = hObject.UserData.FC.(handles.popupmenu2.String{handles.popupmenu2.Value}).(handles.popupmenu3.String{handles.popupmenu3.Value}).adj_matrix;
aa(aa<handles.slider1.Value) = 0;
imagesc(aa, [-1,1]);
eval(['colormap(fccolor_' handles.popupmenu1.String{handles.popupmenu1.Value} '(64));']);
a = hObject.UserData;
chanlabels = [];
for i = 1:a.nbchan
    chanlabels{i,1} = a.chanlocs(i).labels;
end
set(gca, 'XTick', [1:a.nbchan], 'XTickLabel', chanlabels, 'XTickLabelRotation', 90);
set(gca, 'YTick', [1:a.nbchan], 'YTickLabel', chanlabels);
title('Adjacency matrix', 'FontSize', 18);
set(h, 'color', [0.6430 0.7760 1.0000]);

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

figure('units','normalized','outerposition',[0.2 0.2 0.6 0.8]);
colormap(eval(['fccolor_' handles.popupmenu1.String{handles.popupmenu1.Value} '(64);']));
eval(['topoplot_connect(handles.ds,hObject.UserData.chanlocs,fccolor_' handles.popupmenu1.String{handles.popupmenu1.Value} '(64));']);
title('Head Model', 'FontSize', 18);

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

h_new3 = figure('units','normalized','outerposition',[0.2 0.2 0.6 0.8]);
aa = hObject.UserData.FC.(handles.popupmenu2.String{handles.popupmenu2.Value}).(handles.popupmenu3.String{handles.popupmenu3.Value}).adj_matrix;
aa(aa<handles.slider1.Value)=0;
a = hObject.UserData;
chanlabels = [];
for i = 1:a.nbchan
    chanlabels{i,1} = a.chanlocs(i).labels;
end;
colormap(eval(['fccolor_' handles.popupmenu1.String{handles.popupmenu1.Value} '(64);']));
para.rot = 90;
locs(:,1) = cell2mat({a.chanlocs.X});
locs(:,2) = cell2mat({a.chanlocs.Y});
locs(:,3) = cell2mat({a.chanlocs.Z});
locs_2D = mk_sensors_plane(locs,para);

hp_new = handle(h_new3);
h = title('Head in Head model', 'FontSize', 18); axis off;
% P = get(h,'Position'); 
% set(h,'Position',[P(1) P(2)+0.03 P(3)]);
% set(h_new3, 'normalized', 'position', [0.1 0.1 0.8 0.1]);

showcs(aa, locs_2D, para, hp_new);
set(h_new3, 'color', [0.6430 0.7760 1.0000]);

% --- Executes when figure1 is resized.
function figure1_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
