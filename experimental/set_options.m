function set_options()

figname='setoptions';
fig_props = { ...
    'name'                   figname ...
    'color'                  get(0,'defaultUicontrolBackgroundColor') ...
    'resize'                 'off' ...
    'numbertitle'            'off' ...
    'menubar'                'none' ...
    'windowstyle'            'modal' ...
    'visible'                'off' ...
    'createfcn'              ''    ...
    'closerequestfcn'        'delete(gcbf)' ...
            };
%    'position'               fp   ...

fig = figure(fig_props{:});

ok_btn = uicontrol('style','pushbutton',...
                   'string','OK',...
                   'position',[10 10 20 20],...
                   'callback',{@doOK});

               
% Make ok_btn the default button.
%setdefaultbutton(fig, ok_btn);

% make sure we are on screen
movegui(fig)
set(fig, 'visible','on'); drawnow;
               


return 

function doOK(ok_btn, event)
disp('OK');


function test
d = dir;
str = {d.name};
[s,v] = listdlg('PromptString','Select a file:',...
                'SelectionMode','single',...
                'ListString',str)