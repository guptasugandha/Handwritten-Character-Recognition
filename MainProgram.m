function varargout = MainProgram(varargin)
% MAINPROGRAM MATLAB code for MainProgram.fig
%      MAINPROGRAM, by itself, creates a new MAINPROGRAM or raises the existing
%      singleton*.
%
%      H = MAINPROGRAM returns the handle to a new MAINPROGRAM or the handle to
%      the existing singleton*.
%
%      MAINPROGRAM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAINPROGRAM.M with the given input arguments.
%
%      MAINPROGRAM('Property','Value',...) creates a new MAINPROGRAM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MainProgram_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MainProgram_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MainProgram

% Last Modified by GUIDE v2.5 16-Mar-2018 21:47:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @MainProgram_OpeningFcn, ...
    'gui_OutputFcn',  @MainProgram_OutputFcn, ...
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


% --- Executes just before MainProgram is made visible.
function MainProgram_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MainProgram (see VARARGIN)

% Choose default command line output for MainProgram
handles.output = hObject;

clc;
set(handles.ExtractRecognise_btn,'Enable','off')
warning off all;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MainProgram wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MainProgram_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in BrowseImage_btn.
function BrowseImage_btn_Callback(hObject, eventdata, handles)
% hObject    handle to BrowseImage_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname] = uigetfile('*.*','Select Image File');
I = strcat(pathname,filename);
I = imread(I);

axes(handles.axes1);
imshow(I);
set(handles.ExtractRecognise_btn,'Enable','on')

helpdlg('Image has been Loaded Successfully.', 'Load Image');

handles.I = I;
guidata(hObject,handles)

% --- Executes on button press in ExtractRecognise_btn.
function ExtractRecognise_btn_Callback(hObject, eventdata, handles)
% hObject    handle to ExtractRecognise_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

newStr_1 = [];
newStr_2 = [];


I = handles.I;
imagen = I;

axes(handles.axes1);
imshow(imagen);
title('INPUT IMAGE WITH NOISE')
drawnow

if size(imagen,3)==3 % RGB image
    imagen=rgb2gray(imagen);
end

%% Convert to binary image
threshold = graythresh(imagen);
imagen =~im2bw(imagen,threshold);

%% Remove all object containing fewer than 30 pixels
imagen =bwareaopen(imagen,30);

imshow(imagen);
drawnow

%% Edge detection
Iedge = edge(uint8(imagen));
imshow(~Iedge)

%% Morphology

% * *Image Dilation*
se = strel('square',3);
Iedge2 = imdilate(Iedge, se);

imshow(~Iedge2);
title('IMAGE DILATION')
drawnow

% * *Image Filling*

Ifill= imfill(Iedge2,'holes');
imshow(~Ifill)
title('IMAGE FILLING')

Ifill=Ifill & imagen;
drawnow

imshow(~Ifill);
re=Ifill;

load NeuralNetworkDataFinal
global folder_labels net

while 1
    %Fcn 'lines' separate lines in text
    [fl, re]=lines(re);
    imgn=fl;
    
    % Label and count connected components
    [L, Ne] = bwlabel(imgn);
    %Uncomment line below to see lines one by one
    imshow(~fl);pause(0.5);
    
    %% Measure properties of image regions
    propied=regionprops(L,'BoundingBox');
    hold on
    
    %% Plot Bounding Box
    for n=1:size(propied,1)
        rectangle('Position',propied(n).BoundingBox,'EdgeColor','g','LineWidth',2)
    end
    hold off
    
    drawnow
    
    %% Objects extraction
    axes(handles.axes2);
    
    %% Find index of spaces to be put between words using
    %  a threshold value for distance between letters
    
    dist = [];
    for n=1:Ne-1
        
        temp = propied(n+1).BoundingBox(1) - propied(n).BoundingBox(1);
        dist = [dist;temp];
        
    end
    
    index_of_spaces = find(dist>50);
    
    
    
    for n=1:Ne
        n1 = imcrop(imgn,propied(n).BoundingBox);
        
        imshow(~n1);
        drawnow
        
        z=imresize(n1,[50 50]);
        z = ~z;
        imshow(z);
        drawnow
        
        [test_features,test_visual] = extractHOGFeatures(z,'CellSize',[2 2]);
        [label_num,label_text] = nnclassify(test_features, folder_labels, net);
        
        final_label_text_1{n} = label_text;
        
        
    end
    
    newStr_1 = char(final_label_text_1)';

    for k = 1:length(index_of_spaces)
        newStr_1 = insertAfter(newStr_1,index_of_spaces(k) + (k-1)," ");
    end

    final_str = newStr_1;
    
    if isempty(re)  %See variable 're' in Fcn 'lines'   
        break
    else
        axes(handles.axes1);
        imgn=re;
        
        % Label and count connected components
        [L, Ne] = bwlabel(imgn);
        %Uncomment line below to see lines one by one
        imshow(~re);pause(0.5);
        
        %% Measure properties of image regions
        propied=regionprops(L,'BoundingBox');
        hold on
        
        %% Plot Bounding Box
        for n=1:size(propied,1)
            rectangle('Position',propied(n).BoundingBox,'EdgeColor','g','LineWidth',2)
        end
        hold off
        
        drawnow
        
        %% Objects extraction
        axes(handles.axes2);
        
        %% Find index of spaces to be put between words using
        %  a threshold value for distance between letters
        
        dist = [];
        for n=1:Ne-1
            
            temp = propied(n+1).BoundingBox(1) - propied(n).BoundingBox(1);
            dist = [dist;temp];
            
        end
        
        index_of_spaces = find(dist>50);
        
        load NeuralNetworkDataFinal
        
        for n=1:Ne
            n1 = imcrop(imgn,propied(n).BoundingBox);
            
            imshow(~n1);
            drawnow
            
            z=imresize(n1,[50 50]);
            z = ~z;
            imshow(z);
            drawnow
            
            [test_features,test_visual] = extractHOGFeatures(z,'CellSize',[2 2]);
            [label_num,label_text] = nnclassify(test_features, folder_labels, net);
            
            final_label_text_2{n} = label_text;
            
        end
        
        newStr_2 = char(final_label_text_2)';

        for k = 1:length(index_of_spaces)
            newStr_2 = insertAfter(newStr_2,index_of_spaces(k) + (k-1)," ");
        end
        
        final_str = sprintf('%s\n\r%s',newStr_1,newStr_2);
        
        break;
    end
    
end

if ~isempty(newStr_2)
    fid = fopen('.\output.txt','wt');
    fprintf(fid,'%s\n%s',newStr_1,newStr_2);
    fclose(fid);    
else
    fid = fopen('.\output.txt','w');
    fprintf(fid,'%s',newStr_1);
    fclose(fid);
end

winopen('output.txt');

% --- Executes on button press in Exit_btn.
function Exit_btn_Callback(hObject, eventdata, handles)
% hObject    handle to Exit_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close all;


% --- Executes on button press in CameraOpenSnapPhoto_btn.
function CameraOpenSnapPhoto_btn_Callback(hObject, eventdata, handles)
% hObject    handle to CameraOpenSnapPhoto_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.BrowseImage_btn,'Enable','off')

cla reset

vid = videoinput('winvideo', 1, 'MJPG_640x480');
src = getselectedsource(vid);
vid.FramesPerTrigger = Inf;
vid.ReturnedColorspace = 'rgb';

axes(handles.axes1);
h1 = image(zeros(480,640));         % create image object
axis ij;            % flip the image
preview(vid,h1)     % display webcam preview

h = msgbox('Press OK to take Photo !');
uiwait(h);

I = getsnapshot(vid);
set(handles.ExtractRecognise_btn,'Enable','on')

stop(vid);

imshow(I);

handles.I = I;
guidata(hObject,handles);
