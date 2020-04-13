%%%%%%%%%%%%% FECHAMENOSUNAHORA %%%%%%%%%%%%%%%%%%%
%Este script retrocede una hora ante una fecha predeterminada%
%Para ser usado en Busqueda_SAR, en modelo Mercator
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%[DIA_1,MES_i,ANO_i,dia_1,mes_i,ano_i] = FECHAMENOSUNO(DIA,MES,ANO)


function [HORA_1,DIA_1,MES_i,ANO_i,dia_1,mes_i,ano_i] = FECHAMENOSUNAHORA(HORA,DIA,MES,ANO)


    HORA_1 = HORA -1;
    hora_1 = num2str(HORA_1);
    
    DIA_1 = DIA ;
    dia_1 = num2str(DIA_1) ;
    
    MES_i = MES;
    mes_i=num2str(MES);
    
    ANO_i = ANO;
    ano_i = num2str(ANO);

    ENERO=31;
    FEBRERO=28;
    MARZO=31;
    ABRIL=30;
    MAYO=31;
    JUNIO=30;
    JULIO=31;
    AGOSTO=31;
    SEPTIEMBRE=30;
    OCTUBRE=31;
    NOVIEMBRE=30;
    DICIEMBRE=31;

    MESES=[ENERO FEBRERO MARZO ABRIL MAYO JUNIO JULIO AGOSTO SEPTIEMBRE OCTUBRE NOVIEMBRE DICIEMBRE];

    if HORA_1 == -1
        
        HORA_1 = 23;
        hora_1 = num2str(HORA_1);
        DIA_1 = DIA_1 - 1 ;
        dia_1 = num2str(DIA_1) ; 
        
    end    
    
    if HORA_1 < 10
        
        hora_1 = ['0',num2str(HORA_1)]
    
    end
    
    if DIA_1<10

        dia_1=['0',num2str(DIA_1)];

    end        
    
    if DIA_1 <= 0 && MES_i>=11
        MES_i=MES_i-1;
        DIA_1=MESES(MES_i);
        dia_1=num2str(DIA_1);
        mes_i=num2str(MES_i);
    elseif DIA_1 <= 0 && MES_i<=10 && MES_i>1
        MES_i=MES_i-1;
        DIA_1=MESES(MES_i);
        dia_1=num2str(DIA_1);
        mes=['0',num2str(MES_i)];
    end
    if MES_i<10
        mes_i=['0',num2str(MES_i)];
    end
    if MES_i > 12
        MES_i=1;
        ANO_i=ANO_i+1;
        ano_i=num2str(ANO_i);
    end
    if MES_i == 0
        MES_i=12;
        ANO_i=ANO_i-1;
        ano_i=num2str(ANO_i);
    end
    if MES_i == 1 && DIA_1 == 0
        MES_i=12;
        mes_i='12'
        ANO_i=ANO_i-1;
        ano_i=num2str(ANO_i);
        DIA_1 = MESES(12);
        dia_1 = num2str(MESES(12));
    end
    
end