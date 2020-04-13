%%%%%%%%%%%%%MOTU_MERCATOR %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Este script descarga pronósticos Mercator de Copernicus.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%[status,cmdout] = MOTU_MERCATOR(product_id,DIA,MES,ANO,HORA,HorizonteT,longi
%tude_min,longitude_max,latitude_min,latitude_max,output_dir,output_name,
%user,password)

%Si produce un Error en depth, es que no descargo el pronóstico


function [status,cmdout] = MOTU_MERCATOR(product_id,DIA,MES,ANO,HORA,HorizonteT,longitude_min,longitude_max,latitude_min,latitude_max,output_dir,output_name,user,password,variables)


    fecha_i = datenum(ANO,MES,DIA,HORA,30,0);     
    date_vec_ini = datevec(fecha_i);
    fecha_f = fecha_i + HorizonteT/24 ;
    date_vec_end = datevec(fecha_f);

    date_str_ini = datestr(date_vec_ini,'yyyy-mm-dd HH:MM:SS');
    date_str_end = datestr(date_vec_end,'yyyy-mm-dd HH:MM:SS');
    
    variable_line=[' '];

    for i= 1 : length (variables)
        
        variable_newline = ['--variable',' ',variables{i,1},' '];
        variable_line = [variable_line,variable_newline];
        
    end
    
    comando1=['python -m motuclient --motu http://nrt.cmems-du.eu/motu-web/Motu --service-id GLOBAL_ANALYSIS_FORECAST_PHY_001_024-TDS --product-id',' ',product_id,' ','--longitude-min'...
    ,' ',num2str(longitude_min),' ','--longitude-max',' ',num2str(longitude_max),' '...
    ,'--latitude-min',' ',num2str(latitude_min),' ','--latitude-max',' ',num2str(latitude_max)...
    ,' ','--date-min "',date_str_ini,'" --date-max "',date_str_end,...
    '" --depth-min 0 --depth-max 1',...
    variable_line,'--out-dir',' ',output_dir,' ','--out-name',' ',output_name,...
    '.nc --user',' ',user,' ','--pwd',' ',password];

    [status,cmdout] = dos(comando1); 
    

end
