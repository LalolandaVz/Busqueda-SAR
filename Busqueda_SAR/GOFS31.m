%%%%%%%%%%%%%%%%%%%%%%%%GOFS3.1(U,V)%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Esta función descarga las variables U y V del pronóstico GOFS 3.1  del
%HyCOM. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [U,V,T,lon,lat] = GOFS31(dia,mes,ano,HorizonteT,longitude_min,longitude_max,latitude_min,latitude_max)
    
    DIA=str2num(dia);
    MES=str2num(mes);
    ANO=str2num(ano);

    corrientes=['https://tds.hycom.org/thredds/dodsC/GLBy0.08/expt_93.0/FMRC/runs/GLBy0.08_930_FMRC_RUN_',ano,'-',mes,'-',dia,'T12:00:00Z'];

    latitudes_hycom=-80:(90+80)/4250:90;
    longitudes_hycom=0:360/4499:360;
    longitudes_hycom=longitudes_hycom-180;

    idx_longitude_min=max(find(longitudes_hycom<longitude_min)); % Busco en la grilla del modelo, la ubicación más cercana a la posición inicial           
    idx_longitude_max=min(find(longitudes_hycom>longitude_max));
    delta_idx_longitude = idx_longitude_max - idx_longitude_min ;

    idx_latitude_min=max(find(latitudes_hycom<latitude_min));
    idx_latitude_max=min(find(latitudes_hycom>latitude_max));
    delta_idx_latitude = idx_latitude_max - idx_latitude_min ;
    
    DeltaT=3;
    idx_Horizonte_pronostico=HorizonteT/DeltaT;
    
    U = ncread(corrientes,'water_u',[idx_longitude_min idx_latitude_min 1 1],[delta_idx_longitude delta_idx_latitude 1 idx_Horizonte_pronostico]) ;
    V = ncread(corrientes,'water_v',[idx_longitude_min idx_latitude_min 1 1],[delta_idx_longitude delta_idx_latitude 1 idx_Horizonte_pronostico]) ;

    TiempoTotal=DeltaT*length(U(1,1,1,:))/24+datenum(ANO,MES,DIA,12,0,0);
    T=datenum(ANO,MES,DIA,12,0,0):DeltaT/24:TiempoTotal;
    
    lon=longitudes_hycom(idx_longitude_min:idx_longitude_max);
    lat=latitudes_hycom(idx_latitude_min:idx_latitude_max);    
    
end
    