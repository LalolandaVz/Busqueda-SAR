close all
clear all
%% ******************Busqueda SAR******************************* 
%Script para busqueda de objetos perdidos en el mar

%% Apertura de paquetes necesarios

% Dirección de paquetes para matlab predeterminada
dir = '/home/lalolanda/Busqueda SAR-12042020/';

Prompt = {'Dirección de paquetes para Matlab'};
direccion = inputdlg(Prompt,'Busqueda_SAR',1,{dir});

addpath([direccion{1}, 'm_map']) %paquete para poder dibujar sobre mapas
addpath(genpath([direccion{1},'TPXO']))%mareas
addpath([direccion{1},'Busqueda_SAR'])%funciones hechas para este script
addpath([direccion{1},'googleearth'])%paquete para exportar datos a google earth

%% Consulta de datos del caso SAR

% Dirección de carpeta de descarga predeterminada
dir = '/home/lalolanda/';

% Apertura de consulta

[dia,mes,ano,hora,latitud,longitud,direccion,opciones_avanzadas] = inputdialog(dir);

dir=direccion;

% Opciones avanzadas (elección de uso de pronósticos, rango de longitudes y latitudes, horizonte de pronóstico). 

%Modo predeterminado significa descargar el último disponible, siguiendo la jerarquía Mercator
% (+olas+mareas) - Mercator - HyCOM
%La opción horizonte de pronóstico aún no esta funcionando. 

opciones_latlon = 1; %Indices que siguen las opciones del popup en la ventana de diálogo
opciones_horizonte = 1;

if opciones_avanzadas == 1
    
    [opciones_avanzadas,opciones_latlon,opciones_horizonte] = advanceddialog;
    
end

% Opción de utilizar un pronóstico ya descargado

if opciones_avanzadas == 5
    
    [DIRECCION , que_pronostico] = adressdialog; %DIRECCION es la dirección del pronóstico, que_pronóstico indica si es HyCOM o Mercator
    
end

% Genero parametros necesarios para descargar pronósticos netcdf 

DIA_i = str2num(dia);
MES_i = str2num(mes);
ANO_i = str2num(ano);
ans = hora;
HORA_i = str2num(ans(1:2));
MINUTO_i= str2num(ans(4:5));
fecha_i = datenum(ANO_i,MES_i,DIA_i,HORA_i,MINUTO_i,0);
Latitud = str2num(latitud);
Longitud = str2num(longitud);
dir = direccion;


% Defino que latitudes y longitudes cubrira el pronóstico a descargar

OPCIONES_LONLAT = [4 6 8 10 12];
DELTA_LONLAT = OPCIONES_LONLAT(opciones_latlon);

latitude_sum = Latitud;
latitude_min = latitude_sum - DELTA_LONLAT;
latitude_max = latitude_sum + DELTA_LONLAT; %Voy 4 grados para cada lado      

longitude_sum = Longitud;
longitude_min = longitude_sum - DELTA_LONLAT;
longitude_max = longitude_sum + DELTA_LONLAT; %Voy 4 grados para cada lado   
  
date_vec_ini = datevec(fecha_i);
fecha_f = fecha_i+4;
HorizonteT=4*24; %Horizonte de pronóstico. Predeterminado a 4 días.
date_vec_end = datevec(fecha_f);

date_str_ini = datestr(date_vec_ini,'yyyy-mm-dd');
date_str_end = datestr(date_vec_end,'yyyy-mm-dd');

output_name = ['Corriente_Busqueda_SAR_',date_str_ini]; %Nombre del archivo de pronóstico

user='sveliz'; %Usuario de Copernicus
password='SergiogabrielCMEMS2018';  %Contraseña de Copernicus


%% Descarga y apertura de pronósticos

%Indices que indican distintos casos:
status=0; %Indica que el modelo predeterminado es el Mercator (+olas+mareas)
status_30 = 0; %Cuando sea modificado a "1" este valor, indica que se uso modelo Mercator, y que en el horario inicial, minutos<30. Importante para los cálculos iniciales.
status_tiempo = 0; %Indice relacionado a la necesidad de alinear o no el vector de tiempos del objeto y del modelo
status_dia = 0;%Indice relacionado al modelo HyCOM. Comienzan siempre a las 12 hs los pronósticos, y si el horario inicial es de un horario menor, debe descargarse el pronóstico del día previo. Si este índice vale 1, se realiza dicha acción

if opciones_avanzadas == 1 || opciones_avanzadas ==0 % Si se eligió Modo predeterminado

    status=0; % Indice que, en caso de no haber pronóstico disponible para la fecha, permite ir al siguiente en la jerarquía

    for M1 =1:3

        try    

            product_id = 'global-analysis-forecast-phy-001-024-hourly-merged-uv' %Mercator + olas + mareas
            
            if MINUTO_i < 30
                
                [HORA_mod,DIA_mod,MES_mod,ANO_mod] = FECHAMENOSUNAHORA(HORA_i,DIA_i,MES_i,ANO_i);
                [U,V,T,lon,lat]=MOTU_MERCATOR_SAR(product_id,DIA_mod,MES_mod,ANO_mod,HORA_mod,HorizonteT+1,longitude_min,longitude_max,latitude_min,latitude_max,dir,output_name,user,password);
            
                status_30 = 1 ;
                
            else
                
                [U,V,T,lon,lat]=MOTU_MERCATOR_SAR(product_id,DIA_i,MES_i,ANO_i,HORA_i,HorizonteT,longitude_min,longitude_max,latitude_min,latitude_max,dir,output_name,user,password);
            
            end
            
            DeltaT=1; % Intervalo temporal en modelo Mercator en superficie
            
            break

        catch

            disp(['No hay pronóstico GLOBAL_ANALYSIS_FORECAST_PHY_001_024-HOURLY-MERGED-U-V de la fecha',date_str_ini])

            status=1; % No hay pronóstico disponible, ir al siguiente en la jerarquía de modelos.

        end

    end

    if status==1

        for M2 =1:3

            try 

                product_id = 'global-analysis-forecast-phy-001-024-hourly-t-u-v-ssh'; % Modelo Mercator 

                if MINUTO_i < 30
    
                    [HORA_mod,DIA_mod,MES_mod,ANO_mod] = FECHAMENOSUNAHORA(HORA_i,DIA_i,MES_i,ANO_i);
                    [U,V,T,lon,lat]=MOTU_MERCATOR_SAR(product_id,DIA_mod,MES_mod,ANO_mod,HORA_mod,HorizonteT+1,longitude_min,longitude_max,latitude_min,latitude_max,dir,output_name,user,password);

                    status_30 = 1 ;
                    
                else

                    [U,V,T,lon,lat]=MOTU_MERCATOR_SAR(product_id,DIA_i,MES_i,ANO_i,HORA_i,HorizonteT,longitude_min,longitude_max,latitude_min,latitude_max,dir,output_name,user,password);

                end
            
                DeltaT=1;  % Intervalo temporal en modelo Mercator en superficie
                
                break

            catch

                disp(['No hay pronóstico GLOBAL_ANALYSIS_FORECAST_PHY_001_024-HOURLY-T-U-V-SSH de la fecha',date_str_ini])

                status=2; % No hay pronóstico disponible, ir al siguiente en la jerarquía de modelos.

            end

        end

    end

    if status==2

        for H3 =1:3

            try    

                if HORA_i<12

                    [DIA_mod,MES_mod,ANO_mod,dia_mod,mes_mod,ano_mod] = FECHAMENOSUNO(DIA_i,MES_i,ANO_i);

                    [U,V,T,lon,lat]=GOFS31(dia_mod,mes_mod,ano_mod,HorizonteT+27,longitude_min,longitude_max,latitude_min,latitude_max);

                    status_dia = 1;

                else

                    [U,V,T,lon,lat]=GOFS31(dia,mes,ano,HorizonteT+3,longitude_min,longitude_max,latitude_min,latitude_max);

                end
                
                DeltaT=3;  % Intervalo temporal en modelo HyCOM en superficie
                
                break

            catch

                disp(['No hay pronóstico GOFS 3.1 de la fecha ',date_str_ini])

                status=3; % No hay pronóstico disponible.

            end

        end

    end
    
elseif opciones_avanzadas == 2 % Se eligió opción Mercator (+mareas+olas)
    
        for M1 =1:3

        try    

            if MINUTO_i < 30
                
                [HORA_mod,DIA_mod,MES_mod,ANO_mod] = FECHAMENOSUNAHORA(HORA_i,DIA_i,MES_i,ANO_i);
                [U,V,T,lon,lat]=MOTU_MERCATOR_SAR(product_id,DIA_mod,MES_mod,ANO_mod,HORA_mod,HorizonteT+1,longitude_min,longitude_max,latitude_min,latitude_max,dir,output_name,user,password);

                status_30 = 1 ;
            
            else
                
                [U,V,T,lon,lat]=MOTU_MERCATOR_SAR(product_id,DIA_i,MES_i,ANO_i,HORA_i,HorizonteT,longitude_min,longitude_max,latitude_min,latitude_max,dir,output_name,user,password);
            
            end
            
            DeltaT = 1;  % Intervalo temporal en modelo Mercator en superficie
            
            break

        catch

            disp(['No hay pronóstico GLOBAL_ANALYSIS_FORECAST_PHY_001_024-HOURLY-MERGED-U-V de la fecha',date_str_ini])

            status=1; %A eliminar

        end

    end
    
elseif opciones_avanzadas == 3 % Se eligió opción Mercator
    
    for M2 =1:3

            try 

                product_id = 'global-analysis-forecast-phy-001-024-hourly-t-u-v-ssh';

                if MINUTO_i < 30

                    [HORA_mod,DIA_mod,MES_mod,ANO_mod] = FECHAMENOSUNAHORA(HORA_i,DIA_i,MES_i,ANO_i);
                    [U,V,T,lon,lat]=MOTU_MERCATOR_SAR(product_id,DIA_mod,MES_mod,ANO_mod,HORA_mod,HorizonteT+1,longitude_min,longitude_max,latitude_min,latitude_max,dir,output_name,user,password);
    
                    status_30 = 1 ;

                else

                    [U,V,T,lon,lat]=MOTU_MERCATOR_SAR(product_id,DIA_i,MES_i,ANO_i,HORA_i,HorizonteT,longitude_min,longitude_max,latitude_min,latitude_max,dir,output_name,user,password);

                end
                
                DeltaT = 1; % Intervalo temporal en modelo Mercator en superficie
                
                status = 1;
                
                break

            catch

                disp(['No hay pronóstico GLOBAL_ANALYSIS_FORECAST_PHY_001_024-HOURLY-T-U-V-SSH de la fecha ',date_str_ini])

                status=2; %A eliminar

            end

        end
    
elseif opciones_avanzadas == 4    % Se eligió opción HyCOM
    
    for H3 =1:3

            try    

                if HORA_i<12

                    [DIA_mod,MES_mod,ANO_mod,dia_mod,mes_mod,ano_mod] = FECHAMENOSUNO(DIA_i,MES_i,ANO_i);

                    [U,V,T,lon,lat]=GOFS31(dia_mod,mes_mod,ano_mod,HorizonteT+27,longitude_min,longitude_max,latitude_min,latitude_max);

                    status_dia = 1;

                else

                    [U,V,T,lon,lat]=GOFS31(dia,mes,ano,HorizonteT+3,longitude_min,longitude_max,latitude_min,latitude_max);

                end
                DeltaT = 3;  % Intervalo temporal en modelo HyCOM en superficie
                
                status = 2;
                
                break

            catch

                disp(['No hay pronóstico GOFS 3.1 de la fecha ',date_str_ini])

                status=3; %A eliminar

            end

        end   
    
end

if opciones_avanzadas == 5 && que_pronostico == 1  % Se eligió usar modelo descargado, Mercator (+mareas+olas)
    
    DeltaT = 1;% Intervalo temporal en modelo HyCOM en superficie
    
    U=ncread(DIRECCION,'utotal');
    V=ncread(DIRECCION,'vtotal');
    
    lat=ncread(DIRECCION,'latitude');
    lon=ncread(DIRECCION,'longitude');
             
    
elseif opciones_avanzadas == 5 && que_pronostico == 2  % Se eligió usar modelo descargado, Mercator   

    status = 1;
    
    DeltaT = 1;% Intervalo temporal en modelo HyCOM en superficie
    
    U=ncread(DIRECCION,'uo');
    V=ncread(DIRECCION,'vo');
    T=ncread(DIRECCION,'time');
    lat=ncread(DIRECCION,'latitude');
    lon=ncread(DIRECCION,'longitude');
    
elseif opciones_avanzadas == 5 && que_pronostico == 3  % Se eligió usar modelo descargado, HyCOM   

    status = 2;
    
    DeltaT = 3;
    
    U=ncread(DIRECCION,'water_u');
    V=ncread(DIRECCION,'water_v');

    lat=ncread(DIRECCION,'latitude');
    lon=ncread(DIRECCION,'longitude');
    
end

lat = double(lat);
lon = double(lon);

%Defino vector de tiempo del objeto a buscar, y vector de tiempo del modelo

if status == 1 || status == 0
    
    TiempoModelo = datenum(ANO_i,MES_i,DIA_i,HORA_i,30,0):(DeltaT/24):fecha_f+0.01;
    TiempoObjeto = datenum(ANO_i,MES_i,DIA_i,HORA_i,30,00):(DeltaT/24):fecha_f+0.01; %revisar
    
    if datenum(ANO_i,MES_i,DIA_i,HORA_i,MINUTO_i,00) > TiempoObjeto(1)
        
        TiempoObjeto(1)=datenum(ANO_i,MES_i,DIA_i,HORA_i,MINUTO_i,00);
        
    elseif datenum(ANO_i,MES_i,DIA_i,HORA_i,MINUTO_i,00) < TiempoObjeto(1)
        
        TiempoObjeto = [datenum(ANO_i,MES_i,DIA_i,HORA_i,MINUTO_i,00),TiempoObjeto];
        
    end
    
elseif status == 2
    
    TiempoModelo = datenum(ANO_i,MES_i,DIA_i,12,0,0):(DeltaT/24):fecha_f+0.5;
    TiempoObjeto = datenum(ANO_i,MES_i,DIA_i,HORA_i,0,0):(DeltaT/24):fecha_f; 
    
    horas_hycom=[0,3,6,9,12,15,18,21];%horarios del hycom

    quehora = find(abs(horas_hycom-HORA_i)==min(abs(horas_hycom-HORA_i)));
    
    if horas_hycom(quehora) ~= HORA_i
        
        status_tiempo = 1;
        
    end
    
    if horas_hycom(quehora) > HORA_i
        HORA_mod = horas_hycom(quehora - 1);
    else
        HORA_mod = horas_hycom(quehora);
    end

    TiempoObjeto = datenum(ANO_i,MES_i,DIA_i,HORA_mod,0,0):(DeltaT/24):datenum(ANO_i,MES_i,DIA_i,12,0,0)+HorizonteT/24;

    if HORA_mod ~= HORA_i

        TiempoObjeto(1)=datenum(ANO_i,MES_i,DIA_i,HORA_i,00,00);

    end
       
end

if status_30 == 1
    
    TiempoModelo = [datenum(ANO_mod,MES_mod,DIA_mod,HORA_mod,30,0),TiempoModelo]; %, datenum(ANO_i,MES_i,DIA_i,HORA_i,0,0):(DeltaT/24):fecha_f];
    
end

if status_dia == 1
    
    TiempoModelo = [datenum(ANO_mod,MES_mod,DIA_mod,12,0,0):DeltaT/24:datenum(ANO_i,MES_i,DIA_i,9,0,0),TiempoModelo]; %, datenum(ANO_i,MES_i,DIA_i,HORA_i,0,0):(DeltaT/24):fecha_f];

end

%¿Fue necesario alinear temporalmente el objeto con el intervalo temporal del modelo? Si lo fue, es marcado con "status_tiempo=1"

if status == 1 && MINUTO_i ~= 30 || status == 0 && MINUTO_i ~= 30 || status == 2 && MINUTO_i ~= 0
    
    status_tiempo = 1;
    
end

%Creo matrices de posición de boyas ficticias

POSXHC=zeros(1,length(U(1,1,1,:))+1);
POSYHC=zeros(1,length(U(1,1,1,:))+1);

%Defino posición inicial

POSXHC(1)=Longitud; %Hago coincidir ubicación inicial de boya ficticia y boya real.
POSYHC(1)=Latitud;

%Suprimo la dirección extra que tienen los archivos del modelo U(lon,lat,1,Tiempo)
    
U=squeeze(U);
V=squeeze(V);

%% Marea

%Obtengo corriente por marea para Mercator y HyCOM. Resolución 0.08°x0.08° 

if status ~= 0
    
    Model = '/home/lalolanda/TPXO/DATA/Model_atlas_v1';

    %lat_tpxo = latitude_min : (latitude_max - latitude_min) / 100 : latitude_max;
    %lon_tpxo = longitude_min : (longitude_max - longitude_min) / 100 : longitude_max;
    lat_tpxo=lat;
    lon_tpxo=lon;
    [lon_mesh,lat_mesh]=meshgrid(lon_tpxo,lat_tpxo);
   
    u_tpxo = tmd_tide_pred_mapts(Model , TiempoModelo(:) , lat_mesh , lon_mesh , 'u',[]); %en cm/s
    v_tpxo = tmd_tide_pred_mapts(Model , TiempoModelo(:) , lat_mesh , lon_mesh , 'v',[]); %en cm/s
    
    u_tpxo = u_tpxo / 100; %Paso a m/s
    v_tpxo = v_tpxo / 100; %Paso a m/s
    
end

%% Monte Carlo - Definición de parámetros T y sigma a utilizar

[Tu_RF,Tv_RF,desv_u_RF,desv_v_RF] = MonteCarlo_param(direccion,POSXHC(1),POSYHC(1));
dt_RF=1;

%% Cálculo de trayectorias

%Se nuevas matrices de posicion de boya ficticia, para poder utilizar métodos estocásticos.
%Se tiran 500 boyas ficticias que sean afectadas por el Random Flight.

RF_POSXHC=zeros(500,length(POSXHC(1,:)));
RF_POSYHC=zeros(500,length(POSXHC(1,:)));

Conversion_temp = 60 * 60 ; %Conversion temporal de horas a segundos

Conversion_lati = 180 / (pi * 6371000) ; % Conversión espacial de grados a metros, en latitud        

try
    
    for idxRF=1:500
        
        RF_POSXHC(idxRF,1)=POSXHC(1);
        
        RF_POSYHC(idxRF,1)=POSYHC(1);    
    
        for h = 1 : length(TiempoObjeto)

            i=min(find(lon>RF_POSXHC(idxRF,h))); % Busco en la grilla del modelo, la ubicación más cercana a la posición inicial           
            j=max(find(lon<RF_POSXHC(idxRF,h)));

            AA(1)=j; % Ubicación de las longitudes más cercanas en la matriz de Longitud.            
            AA(2)=i;

            l=min(find(lat>RF_POSYHC(idxRF,h)));            
            m=max(find(lat<RF_POSYHC(idxRF,h)));

            BB(1)=m;
            BB(2)=l;
            
            Conversion_long = 180 / ( pi * 6371000 * cosd( RF_POSYHC(idxRF,h) ) ) ; % Conversión espacial de grados a metros, en longitud   
            
        %   Monte Carlo
            for i = 1:DeltaT %Según el intervalo horario, aplico por cada hora un paso de Monte Carlo
                if h==1 && i == 1
                %Solo en el primer paso, hago un Monte Carlo
                %Random Walk
                    u_RF=desv_u_RF*(Tu_RF^(0.5))*randn()*((dt_RF*2)^0.5)/dt_RF;

                    v_RF=desv_v_RF*(Tv_RF^(0.5))*randn()*((dt_RF*2)^0.5)/dt_RF; 

                else
                    %Random Flight

                    du_RF=-(u_RF*1/Tu_RF) + desv_u_RF*(((2*1)^0.5)*randn())/(Tu_RF^0.5);
                    u_RF=u_RF + du_RF;

                    dv_RF=-(v_RF*1/Tv_RF) + desv_v_RF*(((2*1)^0.5)*randn())/(Tv_RF^0.5);
                    v_RF=v_RF + dv_RF;    
                end
            end
                                    
            
            if h == 1  &&  status_tiempo == 1  &&  status ~= 0  %Si estoy en el primer paso temporal, los tiempos de modelo y objeto no coincidían y fue necesario alinearlos, y si el modelo no es Mercator(+mareas+olas)

                s=min(find(TiempoModelo>TiempoObjeto(h)));            
                r=max(find(TiempoModelo<TiempoObjeto(h)));

                CC(1)=r;
                CC(2)=s;

                Vel_u_tpxo = interp3 (lon(AA(1:2)) , lat(BB(1:2)) , TiempoModelo(CC(1:2))' , u_tpxo(BB(1:2), AA(1:2) , CC(1:2)), RF_POSXHC(idxRF,h) , RF_POSYHC(idxRF,h), TiempoObjeto(h) ) ; % Velocidad por marea interpolada, U

                Vel_v_tpxo = interp3 (lon(AA(1:2)) , lat(BB(1:2)) , TiempoModelo(CC(1:2))' , v_tpxo(BB(1:2), AA(1:2) , CC(1:2)), RF_POSXHC(idxRF,h), RF_POSYHC(idxRF,h), TiempoObjeto(h) ) ;  % Velocidad por marea interpolada, V

                Vel_U = interp3 (lon(AA(1:2)) , lat(BB(1:2)) , TiempoModelo(CC(1:2))' , U(AA(1:2) , BB(1:2) , CC(1:2)), RF_POSXHC(idxRF,h), RF_POSYHC(idxRF,h), TiempoObjeto(h) ) ; % Velocidad de pronóstico interpolada, U

                Vel_V = interp3 (lon(AA(1:2)) , lat(BB(1:2)) , TiempoModelo(CC(1:2))' , V(AA(1:2) , BB(1:2) , CC(1:2)), RF_POSXHC(idxRF,h) , RF_POSYHC(idxRF,h), TiempoObjeto(h) ) ; % Velocidad de pronóstico interpolada, V

                U_TOTAL = Vel_U + Vel_u_tpxo + u_RF ; %Velocidad total zonal

                V_TOTAL = Vel_V + Vel_v_tpxo + v_RF ; %Velocidad total meridional

                RF_POSXHC (idxRF,h+1) = RF_POSXHC(idxRF,h) + U_TOTAL .* DeltaT * Conversion_temp * Conversion_long ; % X = Xo + U . T 

                RF_POSYHC (idxRF,h+1) = RF_POSYHC(idxRF,h) + V_TOTAL .* DeltaT * Conversion_temp * Conversion_lati ; % Y = Vo + V . T


                continue
                
            elseif h == 1  && status_tiempo == 1  %Idem, pero para modelo Mercator(+mareas+olas)
                
                s=min(find(TiempoModelo>TiempoObjeto(h)));            
                r=max(find(TiempoModelo<TiempoObjeto(h)));

                CC(1)=r;
                CC(2)=s;

                Vel_U = interp3 (lon(AA(1:2)) , lat(BB(1:2)) , TiempoModelo(CC(1:2))' , U(AA(1:2) , BB(1:2) , CC(1:2)), RF_POSXHC(idxRF,h), RF_POSYHC(idxRF,h), TiempoObjeto(h) ) ; % Velocidad de pronóstico interpolada, U

                Vel_V = interp3 (lon(AA(1:2)) , lat(BB(1:2)) , TiempoModelo(CC(1:2))' , V(AA(1:2) , BB(1:2) , CC(1:2)), RF_POSXHC(idxRF,h) , RF_POSYHC(idxRF,h), TiempoObjeto(h) ) ; % Velocidad de pronóstico interpolada, V

                U_TOTAL = Vel_U + u_RF ; %Velocidad total zonal

                V_TOTAL = Vel_V + v_RF ; %Velocidad total meridional

                RF_POSXHC (idxRF,h+1) = RF_POSXHC(idxRF,h) + U_TOTAL .* DeltaT * Conversion_temp * Conversion_long ; % X = Xo + U . T 

                RF_POSYHC (idxRF,h+1) = RF_POSYHC(idxRF,h) + V_TOTAL .* DeltaT * Conversion_temp * Conversion_lati ; % Y = Vo + V . T
                
                continue
                
            end            
            
            H = find(TiempoModelo==TiempoObjeto(h)); %Exceptuando en el primer paso temporal, en el resto el script avanzará siguiendo H, que indica donde Modelo y objeto tienen el mismo horario.
            
            if status ~= 0 %Si el modelo no es Mercator(+mareas+olas) (es decir, si es necesario calcular marea)

                Vel_u_tpxo = interp2 (lon(AA(1:2)) , lat(BB(1:2)) , u_tpxo(BB(1:2), AA(1:2) , H), RF_POSXHC(idxRF,h) , RF_POSYHC(idxRF,h) ) ; % Velocidad por marea interpolada, U

                Vel_v_tpxo = interp2 (lon(AA(1:2)) , lat(BB(1:2)) , v_tpxo(BB(1:2), AA(1:2) , H), RF_POSXHC(idxRF,h), RF_POSYHC(idxRF,h) ) ;  % Velocidad por marea interpolada, V

                Vel_U = interp2 (lon(AA(1:2)) , lat(BB(1:2)) , U(AA(1:2) , BB(1:2) , H), RF_POSXHC(idxRF,h), RF_POSYHC(idxRF,h) ) ; % Velocidad de pronóstico interpolada, U

                Vel_V = interp2 (lon(AA(1:2)) , lat(BB(1:2)) , V(AA(1:2) , BB(1:2) , H), RF_POSXHC(idxRF,h) , RF_POSYHC(idxRF,h)) ; % Velocidad de pronóstico interpolada, V

                U_TOTAL = Vel_U + Vel_u_tpxo + u_RF ; %Velocidad total zonal

                V_TOTAL = Vel_V + Vel_v_tpxo + v_RF ; %Velocidad total meridional

                % Calculo posiciones interpolando la matriz del modelo alrededor de la posición exacta de la boya ficticia
                
                RF_POSXHC (idxRF,h+1) = RF_POSXHC(idxRF,h) + U_TOTAL .* DeltaT * Conversion_temp * Conversion_long ; % X = Xo + U . T 

                RF_POSYHC (idxRF,h+1) = RF_POSYHC(idxRF,h) + V_TOTAL .* DeltaT * Conversion_temp * Conversion_lati ; % Y = Vo + V . T   
                
            else
            
                Vel_U = interp2 (lon(AA(1:2)) , lat(BB(1:2)) , U(AA(1:2) , BB(1:2) , H), RF_POSXHC(idxRF,h), RF_POSYHC(idxRF,h) ) ; % Velocidad de pronóstico interpolada, U

                Vel_V = interp2 (lon(AA(1:2)) , lat(BB(1:2)) , V(AA(1:2) , BB(1:2) , H), RF_POSXHC(idxRF,h) , RF_POSYHC(idxRF,h)) ; % Velocidad de pronóstico interpolada, V

                U_TOTAL = Vel_U + u_RF ; %Velocidad total zonal

                V_TOTAL = Vel_V + v_RF ; %Velocidad total meridional

                % Calculo posiciones interpolando la matriz del modelo alrededor de la posición exacta de la boya ficticia
                
                RF_POSXHC (idxRF,h+1) = RF_POSXHC(idxRF,h) + U_TOTAL .* DeltaT * Conversion_temp * Conversion_long ; % X = Xo + U . T 

                RF_POSYHC (idxRF,h+1) = RF_POSYHC(idxRF,h) + V_TOTAL .* DeltaT * Conversion_temp * Conversion_lati ; % Y = Vo + V . T
                
            end

           
        end
        
    end
                
catch
        
             disp('Hubo un problema con posxhc/posyhc')
    
end

POSXHC_mean(1)=POSXHC(1);
POSYHC_mean(1)=POSYHC(1);

%Calculo trayectoria siguiendo el centro medio

for ii=2:length(POSXHC(1,:))

    POSXHC_mean(ii)=nanmean(nonzeros(RF_POSXHC(:,ii)));
    POSYHC_mean(ii)=nanmean(nonzeros(RF_POSYHC(:,ii)));

end

%% Calculo histogramas 2D - Áreas de probabilidad (24, 48 y 72 hs)
ii=24/DeltaT;
deltax_edges_24=(max(nonzeros(RF_POSXHC(:,ii)))-min(nonzeros(RF_POSXHC(:,ii))))/15;
deltay_edges_24=(max(nonzeros(RF_POSYHC(:,ii)))-min(nonzeros(RF_POSYHC(:,ii))))/15;

iniciox_edges_24=min(nonzeros(RF_POSXHC(:,ii)));
finx_edges_24=max(nonzeros(RF_POSXHC(:,ii)));

inicioy_edges_24=min(nonzeros(RF_POSYHC(:,ii)));
finy_edges_24=max(nonzeros(RF_POSYHC(:,ii)));

x_edges_24=iniciox_edges_24-deltax_edges_24:deltax_edges_24:finx_edges_24;
y_edges_24=inicioy_edges_24-deltay_edges_24:deltay_edges_24:finy_edges_24;

Histo2d_24=hist2d(nonzeros(RF_POSXHC(:,ii))',nonzeros(RF_POSYHC(:,ii))',x_edges_24,y_edges_24);

map = [1 1 1;0 1 1;0 0.9 0.9;0 0.8 0.8;0 0.7 0.7;0 0.6 0.6;0 0.5 0.5;0 0.4 0.4;0 0.3 0.3;0 0.2 0.2];

[X_EDGES_24,Y_EDGES_24]=meshgrid(x_edges_24(1:end-1)+abs((x_edges_24(1)-x_edges_24(2))/2),y_edges_24(1:end-1)+abs((y_edges_24(1)-y_edges_24(2))/2));

Histo2d_24=Histo2d_24/max(max(Histo2d_24));
Histo2d_24=Histo2d_24*100;

newpoints = 80;
[xq_24,yq_24] = meshgrid(...
            linspace(min(min(X_EDGES_24,[],2)),max(max(X_EDGES_24,[],2)),newpoints ),...
            linspace(min(min(Y_EDGES_24,[],1)),max(max(Y_EDGES_24,[],1)),newpoints )...
          );
Histo2d_24_interp = interp2(X_EDGES_24,Y_EDGES_24,Histo2d_24,xq_24,yq_24,'cubic');



 

ii=48/DeltaT;
deltax_edges_48=(max(nonzeros(RF_POSXHC(:,ii)))-min(nonzeros(RF_POSXHC(:,ii))))/15;
deltay_edges_48=(max(nonzeros(RF_POSYHC(:,ii)))-min(nonzeros(RF_POSYHC(:,ii))))/15;

iniciox_edges_48=min(nonzeros(RF_POSXHC(:,ii)));
finx_edges_48=max(nonzeros(RF_POSXHC(:,ii)));

inicioy_edges_48=min(nonzeros(RF_POSYHC(:,ii)));
finy_edges_48=max(nonzeros(RF_POSYHC(:,ii)));

x_edges_48=iniciox_edges_48-deltax_edges_48:deltax_edges_48:finx_edges_48;
y_edges_48=inicioy_edges_48-deltay_edges_48:deltay_edges_48:finy_edges_48;

Histo2d_48=hist2d(nonzeros(RF_POSXHC(:,ii))',nonzeros(RF_POSYHC(:,ii))',x_edges_48,y_edges_48);

map = [1 1 1;0 1 1;0 0.9 0.9;0 0.8 0.8;0 0.7 0.7;0 0.6 0.6;0 0.5 0.5;0 0.4 0.4;0 0.3 0.3;0 0.2 0.2];

[X_EDGES_48,Y_EDGES_48]=meshgrid(x_edges_48(1:end-1)+abs((x_edges_48(1)-x_edges_48(2))/2),y_edges_48(1:end-1)+abs((y_edges_48(1)-y_edges_48(2))/2));

Histo2d_48=Histo2d_48/max(max(Histo2d_48));
Histo2d_48=Histo2d_48*100;

newpoints = 80;
[xq_48,yq_48] = meshgrid(...
            linspace(min(min(X_EDGES_48,[],2)),max(max(X_EDGES_48,[],2)),newpoints ),...
            linspace(min(min(Y_EDGES_48,[],1)),max(max(Y_EDGES_48,[],1)),newpoints )...
          );
Histo2d_48_interp = interp2(X_EDGES_48,Y_EDGES_48,Histo2d_48,xq_48,yq_48,'cubic');



ii=72/DeltaT;
deltax_edges_72=(max(nonzeros(RF_POSXHC(:,ii)))-min(nonzeros(RF_POSXHC(:,ii))))/15;
deltay_edges_72=(max(nonzeros(RF_POSYHC(:,ii)))-min(nonzeros(RF_POSYHC(:,ii))))/15;

iniciox_edges_72=min(nonzeros(RF_POSXHC(:,ii)));
finx_edges_72=max(nonzeros(RF_POSXHC(:,ii)));

inicioy_edges_72=min(nonzeros(RF_POSYHC(:,ii)));
finy_edges_72=max(nonzeros(RF_POSYHC(:,ii)));

x_edges_72=iniciox_edges_72-deltax_edges_72:deltax_edges_72:finx_edges_72;
y_edges_72=inicioy_edges_72-deltay_edges_72:deltay_edges_72:finy_edges_72;

Histo2d_72=hist2d(nonzeros(RF_POSXHC(:,ii))',nonzeros(RF_POSYHC(:,ii))',x_edges_72,y_edges_72);

map = [1 1 1;0 1 1;0 0.9 0.9;0 0.8 0.8;0 0.7 0.7;0 0.6 0.6;0 0.5 0.5;0 0.4 0.4;0 0.3 0.3;0 0.2 0.2];
jet_2 = [1 1 1;0 0 1; 0 0.5 0.9; 0 1 1; 0 0.9 0.4; 0 1 0; 0.5 0.9 0; 1 1 0; 1 0.9 0; 1 0.5 0];

[X_EDGES_72,Y_EDGES_72]=meshgrid(x_edges_72(1:end-1)+abs((x_edges_72(1)-x_edges_72(2))/2),y_edges_72(1:end-1)+abs((y_edges_72(1)-y_edges_72(2))/2));

Histo2d_72=Histo2d_72/max(max(Histo2d_72));
Histo2d_72=Histo2d_72*100;

newpoints = 80;
[xq_72,yq_72] = meshgrid(...
            linspace(min(min(X_EDGES_72,[],2)),max(max(X_EDGES_72,[],2)),newpoints ),...
            linspace(min(min(Y_EDGES_72,[],1)),max(max(Y_EDGES_72,[],1)),newpoints )...
          );
Histo2d_72_interp = interp2(X_EDGES_72,Y_EDGES_72,Histo2d_72,xq_72,yq_72,'cubic');



%% Ploteo de mapas 

FIGURA=figure('visible','on'); %abro la figura 1, que muestrorá las posiciones de boyas ficticias y reales
x0=30;
y0=30;
width=1200;
height=650;
set(gcf,'position',[x0,y0,width,height])
m_proj('Miller Cylindrical','lon',[min(min(X_EDGES_72))+360-0.1 max(max(X_EDGES_72))+360+0.1],'lat',[min(min(Y_EDGES_72))-0.1 max(max(Y_EDGES_72))+0.1]);
m_usercoast([dir,'gumby.mat'],'patch',[0.784 0.816 0.831],'LineWidth',1,'edgecolor',[96/255 96/255 96/255]);

m_plot(POSXHC(1),POSYHC(1),'go'); % Ubicación inicial

hold on

plot2=m_contourf(xq_24+360,yq_24,Histo2d_24_interp,'LineColor','none');
colormap(jet_2)
h=colorbar();
caxis([0 100])
set(get(h,'label'),'string','Probabilidad de acierto (%)');
plot1.Color(4)=0.2;

[C,h1]=m_contour(xq_24+360,yq_24,Histo2d_24_interp,[20 50 80],'k--');
th=clabel(C,h1)
h1.LineWidth=0.5

p1=m_plot(POSXHC_mean(1:24/DeltaT)+360,POSYHC_mean(1:24/DeltaT),'r','Linewidth',2.5)
p2=m_plot(POSXHC(1)+360,POSYHC(1),'-p','MarkerFaceColor','red','MarkerSize',15,'MarkerEdgeColor','k','DisplayName','Evento') % Ubicación inicial

m_grid('tickdir','out','FontSize',8,'yaxisloc','left');
legend([p1(1),p2(1)],'Trayectoria','Evento')
xlabel('Longitud');
ylabel('Latitud');
title(['Búsqueda SAR -24 horas']);

print([dir,'24 horas.png'],'-dpng') % Guardo el mapa con trayectorias ficticias y reales






FIGURA=figure('visible','on'); %abro la figura 1, que muestrorá las posiciones de boyas ficticias y reales
set(gcf,'position',[x0,y0,width,height])
m_proj('Miller Cylindrical','lon',[min(min(X_EDGES_72))+360-0.1 max(max(X_EDGES_72))+360+0.1],'lat',[min(min(Y_EDGES_72))-0.1 max(max(Y_EDGES_72))+0.1]);m_usercoast([dir,'gumby.mat'],'patch',[0.784 0.816 0.831],'LineWidth',1,'edgecolor',[96/255 96/255 96/255],'HandleVisibility','off');
m_usercoast([dir,'gumby.mat'],'patch',[0.784 0.816 0.831],'LineWidth',1,'edgecolor',[96/255 96/255 96/255],'HandleVisibility','off');
%m_plot(POSXHC(1),POSYHC(1),'go'); % Ubicación inicial

hold on

plot2=m_contourf(xq_48+360,yq_48,Histo2d_48_interp,'LineColor','none','HandleVisibility','off');
colormap(jet_2)
h=colorbar();
caxis([0 100])
set(h,'YLim',[0 100]);
set(get(h,'label'),'string','Probabilidad de acierto (%)');
plot1.Color(4)=0.2;

[C,h1]=m_contour(X_EDGES_48+360,Y_EDGES_48,Histo2d_48,[20 50 80],'k--','HandleVisibility','off');
th=clabel(C,h1)
h1.LineWidth=0.5

p1=m_plot(POSXHC_mean(1:48/DeltaT)+360,POSYHC_mean(1:48/DeltaT),'r','Linewidth',2.5,'DisplayName','Trayectoria')
p2=m_plot(POSXHC(1)+360,POSYHC(1),'-p','MarkerFaceColor','red','MarkerSize',15,'MarkerEdgeColor','k','DisplayName','Evento') % Ubicación inicial

m_grid('tickdir','out','FontSize',8,'yaxisloc','left');
xlabel('Longitud');
ylabel('Latitud');
legend([p1(1),p2(1)],'Trayectoria','Evento')
title(['Búsqueda SAR - 48 horas']);

print([dir,'48 horas.png'],'-dpng') % Guardo el mapa con trayectorias ficticias y reales





FIGURA=figure('visible','on'); %abro la figura 1, que muestrorá las posiciones de boyas ficticias y reales
set(gcf,'position',[x0,y0,width,height])
m_proj('Miller Cylindrical','lon',[min(min(X_EDGES_72))+360-0.1 max(max(X_EDGES_72))+360+0.1],'lat',[min(min(Y_EDGES_72))-0.1 max(max(Y_EDGES_72))+0.1]);
m_usercoast([dir,'gumby.mat'],'patch',[0.784 0.816 0.831],'LineWidth',1,'edgecolor',[96/255 96/255 96/255]);

m_plot(POSXHC(1),POSYHC(1),'ko'); % Ubicación inicial

%Histo2d<10

hold on

plot2=m_contourf(xq_72+360,yq_72,Histo2d_72_interp,'LineColor','none');
colormap(jet_2)
h=colorbar();
caxis([0 100])
set(h,'YLim',[0 100]);
set(get(h,'label'),'string','Probabilidad de acierto (%)');
plot1.Color(4)=0.2;

[C,h1]=m_contour(X_EDGES_72+360,Y_EDGES_72,Histo2d_72,[20 50 80],'k--');
th=clabel(C,h1)
h1.LineWidth=0.5

p1=m_plot(POSXHC_mean(1:ii)+360,POSYHC_mean(1:ii),'r','Linewidth',2)
p2=m_plot(POSXHC(1)+360,POSYHC(1),'-p','MarkerFaceColor','red','MarkerSize',15,'MarkerEdgeColor','k','DisplayName','Evento') % Ubicación inicial


m_grid('tickdir','out','FontSize',8,'yaxisloc','left');
xlabel('Longitud');
ylabel('Latitud');
legend([p1(1),p2(1)],'Trayectoria','Evento')
title(['Búsqueda SAR - 72 horas']);

print([dir,'72 horas.png'],'-dpng') % Guardo el mapa con trayectorias ficticias y reales


%% Guardado de archivos .shp, .txt y .kml. 

Trayectoria=POSXHC_mean(1:length(TiempoObjeto));
Trayectoria(2,:)=POSYHC_mean(1:length(TiempoObjeto));
Trayectoria(3,:)=TiempoObjeto;

fechas=datestr(TiempoObjeto);

kmlwrite('/home/lalolanda/Trayectoria.kml',POSYHC_mean,POSXHC_mean)
s = geopoint(Trayectoria(2,:),Trayectoria(1,:),'Name',cellstr(fechas),'Geometry','point');
shapewrite(s,'/home/lalolanda/Trayectoria.shp')

dire=[dir,'Trayectoria.txt'];

dlmwrite(dire,Trayectoria,'precision',15)









kmlStr = ge_contourf(xq_24,flipud(yq_24),flipud(Histo2d_24_interp),...
                'colorMap',jet_2,...
               'polyAlpha','85',...
               'lineColor','404040',...
               'lineWidth',0,...
               'lineValues',[10 20 30 40 50 60 70 80 90 100],...
                'altitude',1e4,...
               'altitudeMode','clampToGround',...
               'cLimHigh',100,...
               'cLimLow',0);
           
kmlStr = [kmlStr,ge_colorbar(max(max(xq_24)),min(min(yq_24)),0,...
                    'cBarBorderWidth',1,...
                      'cBarFormatStr','%5d',...
                         'numClasses',10,...
                           'cLimLow',0,...
                           'cLimHigh',100,...
                               'name','Click aquí para ver barra de colores',...
                           'colorMap',jet_2)];
           

kmlStr2 = ge_contour(xq_24,flipud(yq_24),flipud(Histo2d_24_interp),...
               'colorMap','jet',...
             'lineValues',[20 50 80],...
                'cLimLow',0,...
               'cLimHigh',100,...
              'lineWidth',3);
ge_output([direccion,'Área de probabilidad 24hs.kml'],[kmlStr,kmlStr2]);










kmlStr = ge_contourf(xq_48,flipud(yq_48),flipud(Histo2d_48_interp),...
                'colorMap',jet_2,...
               'polyAlpha','85',...
               'lineColor','404040',...
               'lineWidth',0,...
               'lineValues',[10 20 30 40 50 60 70 80 90 100],...
                'altitude',1e4,...
               'altitudeMode','clampToGround',...
               'cLimHigh',100,...
               'cLimLow',0);
           
kmlStr = [kmlStr,ge_colorbar(max(max(xq_48)),min(min(yq_48)),0,...
                    'cBarBorderWidth',1,...
                      'cBarFormatStr','%5d',...
                         'numClasses',10,...
                           'cLimLow',0,...
                           'cLimHigh',100,...
                               'name','Click aquí para ver barra de colores',...
                           'colorMap',jet_2)];
           

kmlStr2 = ge_contour(xq_48,flipud(yq_48),flipud(Histo2d_48_interp),...
               'colorMap','jet',...
             'lineValues',[20 50 80],...
                'cLimLow',0,...
               'cLimHigh',100,...
              'lineWidth',3);
ge_output([direccion,'Área de probabilidad 48hs.kml'],[kmlStr,kmlStr2]);





kmlStr = ge_contourf(xq_72,flipud(yq_72),flipud(Histo2d_72_interp),...
                'colorMap',jet_2,...
               'polyAlpha','85',...
               'lineColor','404040',...
               'lineWidth',0,...
               'lineValues',[10 20 30 40 50 60 70 80 90 100],...
                'altitude',1e4,...
               'altitudeMode','clampToGround',...
               'cLimHigh',100,...
               'cLimLow',0);
           
kmlStr = [kmlStr,ge_colorbar(max(max(xq_72)),min(min(yq_72)),0,...
                    'cBarBorderWidth',1,...
                      'cBarFormatStr','%5d',...
                         'numClasses',10,...
                           'cLimLow',0,...
                           'cLimHigh',100,...
                               'name','Click aquí para ver barra de colores',...
                           'colorMap',jet_2)];
           
       
           

kmlStr2 = ge_contour(xq_72,flipud(yq_72),flipud(Histo2d_72_interp),...
               'colorMap','jet',...
             'lineValues',[20 50 80],...
                'cLimLow',0,...
               'cLimHigh',100,...
              'lineWidth',3);
ge_output([direccion,'Área de probabilidad 72hs.kml'],[kmlStr,kmlStr2]);


% name=blanks(72);
% icon='http://maps.google.com/mapfiles/kml/shapes/shaded_dot.png';
% iconscale=1.4;
% kmlwrite('/home/lalolanda/trayectoriacnombre.kml',POSYHC_mean,POSXHC_mean,'Name',name,'Description',cellstr(fechas(1:length(fechas(:,1)),:)),'Icon','point','IconScale',iconscale)                                       
% 
% kmlwrite('/home/lalolanda/trayectoriacnombre.kml',POSYHC_mean(1:72),POSXHC_mean(1:72),'Name',name,'Description',cellstr(num2str(datevec(TiempoObjeto(1:72)))),'Icon',icon,'IconScale',iconscale)                                       
% 

