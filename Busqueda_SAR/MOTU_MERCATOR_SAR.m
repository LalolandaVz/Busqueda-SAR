%%%%%%%%%%%%%MOTU_MERCATOR_SAR%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Esta funcion descarga y abre pronósticos Mercator de Copernicus. Hecho
%para Busqueda_SAR.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [U,V,T,lon,lat] = MOTU_MERCATOR_SAR(product_id,DIA,MES,ANO,HORA,HorizonteT,longitude_min,longitude_max,latitude_min,latitude_max,output_dir,output_name,user,password)

    if mean(product_id)==mean('global-analysis-forecast-phy-001-024-hourly-merged-uv')
    
        variables={'utotal';'vtotal'};
        
    elseif mean(product_id)==mean('global-analysis-forecast-phy-001-024-hourly-t-u-v-ssh')
        
        variables={'uo';'vo'};
        
    end

    [status , cmdout] = MOTU_MERCATOR(product_id,DIA,MES,ANO,HORA,HorizonteT,longitude_min,longitude_max,latitude_min,latitude_max,output_dir,output_name,user,password,variables)

    DeltaT=1; %intervalo temporal del pronóstico Mercator
    
    if mean(product_id)==mean('global-analysis-forecast-phy-001-024-hourly-merged-uv')
    
        U = ncread([output_dir,output_name,'.nc'],'utotal');
        V = ncread([output_dir,output_name,'.nc'],'vtotal');
        
    elseif mean(product_id)==mean('global-analysis-forecast-phy-001-024-hourly-t-u-v-ssh')
        
        U = ncread([output_dir,output_name,'.nc'],'uo');
        V = ncread([output_dir,output_name,'.nc'],'vo');
    
    end

    TiempoTotal = DeltaT*length(U(1,1,1,:))/24+datenum(ANO,MES,DIA,HORA,30,0);
    T = datenum(ANO,MES,DIA,HORA,30,0):DeltaT/24:TiempoTotal;  
    
    lat = ncread([output_dir,output_name,'.nc'],'latitude');
    lon = ncread([output_dir,output_name,'.nc'],'longitude');
    
end