function varargout = imPreProcess(varargin)
% IMPREPROCESS MATLAB code for imPreProcess.fig
%      IMPREPROCESS, by itself, creates a new IMPREPROCESS or raises the existing
%      singleton*.
%
%      H = IMPREPROCESS returns the handle to a new IMPREPROCESS or the handle to
%      the existing singleton*.
%
%      IMPREPROCESS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMPREPROCESS.M with the given input arguments.
%
%      IMPREPROCESS('Property','Value',...) creates a new IMPREPROCESS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before imPreProcess_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to imPreProcess_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help imPreProcess

% Last Modified by GUIDE v2.5 26-Apr-2021 16:19:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @imPreProcess_OpeningFcn, ...
                   'gui_OutputFcn',  @imPreProcess_OutputFcn, ...
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


% --- Executes just before imPreProcess is made visible.
function imPreProcess_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to imPreProcess (see VARARGIN)

% Choose default command line output for imPreProcess
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Create gdata to save;
gdata.Ax1Im = [];
gdata.ImRaw = [];
gdata.imType = 'Unspecified';
setappdata(0,'gdata',gdata);

% UIWAIT makes imPreProcess wait for user response (see UIRESUME)
uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = imPreProcess_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = getappdata(0,'gdata');


% --- Executes on button press in LoadButton.
function LoadButton_Callback(hObject, eventdata, handles)
% Ask the user to choose an image
[path, user_cancel]=imgetfile();

% Catch errors when the user cancels the image selection
if user_cancel
    msgbox(sprintf('Error'),'Error','Error');
    return
end

ImRaw = imread(path);
[ImX,ImY,ImZ] = size(ImRaw);
setappdata(0,'imraw',ImRaw);
setappdata(0,'Ax1Im',ImRaw);
setappdata(0,'SelIm',ImRaw);

mindim = min([ImX ImY]);
handles.ScaleSlider.Max = log10(mindim/10);

% Save images in gdata
gdata = getappdata(0,'gdata');
gdata.ImRaw = ImRaw;
gdata.Ax1Im = ImRaw;
setappdata(0,'gdata',gdata);

displayImage(handles);


% --- Executes on button press in SaveButton.
function SaveButton_Callback(hObject, eventdata, handles)
% hObject    handle to SaveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename,foldername] = uiputfile('*.png','Save Image As');

% Catch cancels
if filename == 0
    % user pressed cancel
    return % Return control to gui
end


% Write full file name
complete_name = fullfile(foldername,filename);

% Obtain image from app data.
Ax1Im = getappdata(0,'Ax1Im');

% Save the image.
imwrite(Ax1Im,complete_name);


% --- Executes on button press in CloseButton.
function CloseButton_Callback(hObject, eventdata, handles)
% hObject    handle to CloseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(gcf)

% --- Executes on selection change in ImTypePopup.
function ImTypePopup_Callback(hObject, eventdata, handles)
% hObject    handle to ImTypePopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents = cellstr(get(hObject,'String'));
imType = contents{get(hObject,'Value')};

% Save imtype
gdata = getappdata(0,'gdata');
gdata.imType = imType;


imraw = getappdata(0,'imraw');

switch imType
    case 'RGB'
        Ax1Im = imraw;
        setappdata(0,'Ax1Im',Ax1Im);
    case 'Grayscale'
        Ax1Im = rgb2gray(imraw);
        setappdata(0,'Ax1Im',Ax1Im);
    case 'Red'
        Ax1Im = imraw(:,:,1);
        setappdata(0,'Ax1Im',Ax1Im);
    case 'Green'
        Ax1Im = imraw(:,:,2);
        setappdata(0,'Ax1Im',Ax1Im);
    case 'Blue'
        Ax1Im = imraw(:,:,3);
        setappdata(0,'Ax1Im',Ax1Im);
end
setappdata(0,'SelIm',Ax1Im);

displayImage(handles);

% Save Ax1Im
gdata.Ax1Im = Ax1Im;
setappdata(0,'gdata',gdata);


% --- Executes during object creation, after setting all properties.
function ImTypePopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ImTypePopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function ScaleSlider_Callback(hObject, eventdata, handles)
% hObject    handle to ScaleSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
value = get(hObject,'Value');
handles.ScaleEdit.String = num2str(value);

updateImage(handles)

% --- Executes during object creation, after setting all properties.
function ScaleSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ScaleSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function ScaleEdit_Callback(hObject, eventdata, handles)
% hObject    handle to ScaleEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ScaleEdit as text
%        str2double(get(hObject,'String')) returns contents of ScaleEdit as a double
value = str2double(get(hObject,'String'));
if value<=handles.ScaleSlider.Max && value>=handles.ScaleSlider.Min
    handles.ScaleSlider.Value = value;
elseif value<handles.ScaleSlider.Min
    handles.ScaleEdit.Value = 0;
elseif value>handles.ScaleSlider.Max
    handles.ScaleEdit.Value = handles.ScaleSlider.Max;
end

updateImage(handles)


% --- Executes during object creation, after setting all properties.
function ScaleEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ScaleEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% CustomFunctions
function displayImage(handles)
axes(handles.axes1)
im = getappdata(0,'Ax1Im');
imshow(im)

function updateImage(handles)
selIm = getappdata(0,'SelIm');
scale = handles.ScaleSlider.Value;

if scale~=0
    Ax1Im = ImagePreProcess(selIm,10^scale);
else
    Ax1Im = selIm;
end

setappdata(0,'Ax1Im',Ax1Im);
setappdata(0,'Scale',scale)
displayImage(handles);




