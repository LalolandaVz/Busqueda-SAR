function [opciones_avanzadas,opciones_lonlat,opciones_horizonte] = advanceddialog

OPCIONES={'Modo predeterminado','Mercator (global-analysis-forecast-phy-001-024-hourly-merged-uv)','Mercator (global-analysis-forecast-phy-001-024-hourly-t-u-v-ssh)','HyCOM (GOFS 3.1)','Utilizar pronóstico ya descargado'};

hfig=figure('CloseRequestFcn',@close_req_fun,'menu','none');

x0=350;
y0=350;
width=600;
height=200;

    try
        %create GUI
        set(hfig,'menu','none','position',[x0,y0,width,height])
        
        text_asking1=uicontrol('Style', 'text', 'String', 'Elija el modo de descarga de pronóstico de corrientes','FontSize',11,...
            'Parent',hfig,'Units','Normalized', ...
            'Position', [.1, .90, .8, .08]);    
        
        Popmenu1=uicontrol('Style', 'popupmenu', 'String', OPCIONES, ...
            'Parent',hfig,'Units','Normalized', ...
            'Position', [.1, .82, .8, .04]);
        
        text_asking2=uicontrol('Style', 'text', 'String', '¿Qué rango de longitud y latitud (en grados) desea cubrir?','FontSize',11,...
            'Parent',hfig,'Units','Normalized', ...
            'Position', [.1, .62, .8, .08]);    
        
        Popmenu2=uicontrol('Style', 'popupmenu', 'String', {8,12,16,20,24}, ...
            'Parent',hfig,'Units','Normalized', ...
            'Position', [.45, .52, .1, .08]);  

        text_asking3=uicontrol('Style', 'text', 'String', '¿Qué horizontes de pronóstico (en horas) desea?','FontSize',11,...
            'Parent',hfig,'Units','Normalized', ...
            'Position', [.1, .40, .8, .08]);    
        
        Popmenu3=uicontrol('Style', 'popupmenu', 'String', {'24 y 48 hs','24, 48 y 72 hs', '24, 48, 72 y 96 hs', '24, 48, 72, 96 y 120 hs'}, ...
            'Parent',hfig,'Units','Normalized', ...
            'Position', [.35, .30, .3, .08]);  
        
        
        uicontrol('Style', 'pushbutton', 'String', 'OK', ...
            'Parent',hfig,'Units','Normalized', ...
            'Position', [.42 .1 .15 .1],...
            'Callback','close(gcbf)');
%         cancel=uicontrol('Style', 'pushbutton', 'String', 'cancel', ...
%             'Parent',hfig,'Units','Normalized', ...
%             'Position', [.55 .1 .05 .05],...
%             'Tag','0','Callback',@cancelfun);

        %wait for figure being closed (with OK button or window close)
        uiwait(hfig)
        %figure is now closing

        opciones_avanzadas = Popmenu1.Value;
        opciones_lonlat = Popmenu2.Value;
        opciones_horizonte = Popmenu3.Value;

        %actually close the figure
        delete(hfig)

    catch
        delete(hfig)
    end
end
function cancelfun(h,~)
set(h,'Tag','1')
uiresume
end
function close_req_fun(~,~)
uiresume
end