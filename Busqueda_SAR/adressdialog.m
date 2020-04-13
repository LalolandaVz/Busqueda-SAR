function [DIRECCION,que_pronostico]=adressdialog

OPCIONES={'Mercator (+mareas+olas)';'Mercator';'HyCOM'};

hfig=figure('CloseRequestFcn',@close_req_fun,'menu','none');

x0=350;
y0=350;
width=600;
height=300;

    try
        %create GUI
        set(hfig,'menu','none','position',[x0,y0,width,height])
        
        text_asking=uicontrol('Style', 'text', 'String', 'Ingrese la ubicación del archivo de pronóstico de corrientes','FontSize',11,...
            'Parent',hfig,'Units','Normalized', ...
            'Position', [.1, .84, .80, .08]);
        field1=uicontrol('Style', 'Edit', 'String', '/home/lalolanda/', ...
            'Parent',hfig,'Units','Normalized', ...
            'Position', [.10, .64, .80, .08]);
        text_asking=uicontrol('Style', 'text', 'String', '¿El pronóstico elegido es HyCOM o Mercator?','FontSize',11,...
            'Parent',hfig,'Units','Normalized', ...
            'Position', [.1, .44, .80, .08]);
        Popmenu=uicontrol('Style', 'popupmenu', 'String', OPCIONES, ...
            'Parent',hfig,'Units','Normalized', ...
            'Position', [.1, .34, .8, .04]);
        
        uicontrol('Style', 'pushbutton', 'String', 'OK', ...
            'Parent',hfig,'Units','Normalized', ...
            'Position', [.42 .12 .15 .1],...
            'Callback','close(gcbf)');
%         cancel=uicontrol('Style', 'pushbutton', 'String', 'cancel', ...
%             'Parent',hfig,'Units','Normalized', ...
%             'Position', [.55 .1 .05 .05],...
%             'Tag','0','Callback',@cancelfun);

        %wait for figure being closed (with OK button or window close)
        uiwait(hfig)
        %figure is now closing

        DIRECCION=field1.String;
        que_pronostico=Popmenu.Value;


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