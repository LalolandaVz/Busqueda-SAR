%% Monte Carlo - Definición de parámetros T y sigma a utilizar


function [Tu_RF,Tv_RF,desv_u_RF,desv_v_RF] = MonteCarlo_param(dir,POSXHC,POSYHC) 


    %Parametros Monte Carlo

    dt_RF=1; %delta de tiempo para random flight. Elegi el mismo que el del pronostico. 
    dire_VAR_U=[dir,'VAR_U_TODO.txt'];
    dire_VAR_V=[dir,'VAR_V_TODO.txt'];

    %Abro valores de varianza y decaimiento temporal para cada zona

    VAR_U=load(dire_VAR_U);
    VAR_V=load(dire_VAR_V); 

    dire_DECAY_U=[dir,'DECAY_U_TODO.txt'];
    dire_DECAY_V=[dir,'DECAY_V_TODO.txt'];

    DECAY_U=load(dire_DECAY_U);
    DECAY_U=1./DECAY_U;

    DECAY_V=load(dire_DECAY_V);
    DECAY_V=1./DECAY_V;

    %delimito las zonas no rectangulares

    SBB_lat=[-35.5,-30.5,-31,-36.5];
    SBB_lon=[360-53,360-50,360-49,360-52];

    BCO_lat=[-42,-38,-39.5,-46.5];
    BCO_lon=[360-56,360-48,360-42.5,360-56];

    MC_lat=[-43.5,-38.5,-39.5,-44.5];
    MC_lon=[360-60.5,360-56.5,360-55,360-59.5];

    RMC_lat=[-44.5,-39.5,-40.5,-45.5];
    RMC_lon=[360-59.5,360-55,360-54.5,360-58];


    %% Monte Carlo - Selección de parámetros
    %Hago interpolacion de la posicion de la boya sintetica para cada
    %zona. Cuando las interpolaciones no funcionan entregan valor
    %'NaN'. Para que la boya se encuentre dentro de la zona correspondiente, se debe obtener al menos dos interpolaciones en x e y distintas a 'NaN'.
    %Eso lo veo con los if. Segun cada zona, tomo los valores de
    %varianza y decaimiento correspondientes.

    %disp('pre-if de zonas')
    SBB_NS_1_2=interp1(SBB_lon(1:2),SBB_lat(1:2),POSXHC);

    ISNAN_SBB_NS(1)=isnan(SBB_NS_1_2);


    SBB_NS_2_3=interp1([SBB_lon(2),SBB_lon(3)],[SBB_lat(2),SBB_lat(3)],POSXHC);

    ISNAN_SBB_NS(2)=isnan(SBB_NS_2_3);


    SBB_NS_3_4=interp1([SBB_lon(4),SBB_lon(3)],[SBB_lat(4),SBB_lat(3)],POSXHC);

    ISNAN_SBB_NS(3)=isnan(SBB_NS_3_4); 

    SBB_NS_4_1=interp1([SBB_lon(4),SBB_lon(1)],[SBB_lat(4),SBB_lat(1)],POSXHC);

    ISNAN_SBB_NS(4)=isnan(SBB_NS_4_1);



    SBB_OE_1_2=interp1([SBB_lat(1),SBB_lat(2)],[SBB_lon(1),SBB_lon(2)],POSYHC);

    ISNAN_SBB_OE(1)=isnan(SBB_OE_1_2);


    SBB_OE_2_3=interp1([SBB_lat(2),SBB_lat(3)],[SBB_lon(2),SBB_lon(3)],POSYHC);

    ISNAN_SBB_OE(2)=isnan(SBB_OE_2_3);


    SBB_OE_3_4=interp1([SBB_lat(4),SBB_lat(3)],[SBB_lon(4),SBB_lon(3)],POSYHC);

    ISNAN_SBB_OE(3)=isnan(SBB_OE_3_4);


    SBB_OE_4_1=interp1([SBB_lat(4),SBB_lat(1)],[SBB_lon(4),SBB_lon(1)],POSYHC);

    ISNAN_SBB_OE(4)=isnan(SBB_OE_4_1);

    %%%%%

    BCO_NS_1_2=interp1(BCO_lon(1:2),BCO_lat(1:2),POSXHC);

    ISNAN_BCO_NS(1)=isnan(BCO_NS_1_2);


    BCO_NS_2_3=interp1([BCO_lon(2),BCO_lon(3)],[BCO_lat(2),BCO_lat(3)],POSXHC);

    ISNAN_BCO_NS(2)=isnan(BCO_NS_2_3);


    BCO_NS_3_4=interp1([BCO_lon(4),BCO_lon(3)],[BCO_lat(4),BCO_lat(3)],POSXHC);

    ISNAN_BCO_NS(3)=isnan(BCO_NS_3_4);        

    ISNANBCO_NS_prueba(:)=ISNAN_BCO_NS(:);

    BCO_OE_1_2=interp1([BCO_lat(1),BCO_lat(2)],[BCO_lon(1),BCO_lon(2)],POSYHC);

    ISNAN_BCO_OE(1)=isnan(BCO_OE_1_2);


    BCO_OE_2_3=interp1([BCO_lat(2),BCO_lat(3)],[BCO_lon(2),BCO_lon(3)],POSYHC);

    ISNAN_BCO_OE(2)=isnan(BCO_OE_2_3);


    BCO_OE_3_4=interp1([BCO_lat(4),BCO_lat(3)],[BCO_lon(4),BCO_lon(3)],POSYHC);

    ISNAN_BCO_OE(3)=isnan(BCO_OE_3_4);


    BCO_OE_4_1=interp1([BCO_lat(4),BCO_lat(1)],[BCO_lon(4),BCO_lon(1)],POSYHC);

    ISNAN_BCO_OE(4)=isnan(BCO_OE_4_1);

    ISNANBCO_OE_prueba(:)=ISNAN_BCO_OE(:);
    %%%%

    MC_NS_1_2=interp1(MC_lon(1:2),MC_lat(1:2),POSXHC);

    ISNAN_MC_NS(1)=isnan(MC_NS_1_2);


    MC_NS_2_3=interp1([MC_lon(2),MC_lon(3)],[MC_lat(2),MC_lat(3)],POSXHC);

    ISNAN_MC_NS(2)=isnan(MC_NS_2_3);


    MC_NS_3_4=interp1([MC_lon(4),MC_lon(3)],[MC_lat(4),MC_lat(3)],POSXHC);

    ISNAN_MC_NS(3)=isnan(MC_NS_3_4); 

    MC_NS_4_1=interp1([MC_lon(4),MC_lon(1)],[MC_lat(4),MC_lat(1)],POSXHC);

    ISNAN_MC_NS(4)=isnan(MC_NS_4_1);



    MC_OE_1_2=interp1([MC_lat(1),MC_lat(2)],[MC_lon(1),MC_lon(2)],POSYHC);

    ISNAN_MC_OE(1)=isnan(MC_OE_1_2);


    MC_OE_2_3=interp1([MC_lat(2),MC_lat(3)],[MC_lon(2),MC_lon(3)],POSYHC);

    ISNAN_MC_OE(2)=isnan(MC_OE_2_3);


    MC_OE_3_4=interp1([MC_lat(4),MC_lat(3)],[MC_lon(4),MC_lon(3)],POSYHC);

    ISNAN_MC_OE(3)=isnan(MC_OE_3_4);


    MC_OE_4_1=interp1([MC_lat(4),MC_lat(1)],[MC_lon(4),MC_lon(1)],POSYHC);

    ISNAN_MC_OE(4)=isnan(MC_OE_4_1);


    %%%%%%%%%

    RMC_NS_1_2=interp1(RMC_lon(1:2),RMC_lat(1:2),POSXHC);

    ISNAN_RMC_NS(1)=isnan(RMC_NS_1_2);


    RMC_NS_2_3=interp1([RMC_lon(2),RMC_lon(3)],[RMC_lat(2),RMC_lat(3)],POSXHC);

    ISNAN_RMC_NS(2)=isnan(RMC_NS_2_3);


    RMC_NS_3_4=interp1([RMC_lon(4),RMC_lon(3)],[RMC_lat(4),RMC_lat(3)],POSXHC);

    ISNAN_RMC_NS(3)=isnan(RMC_NS_3_4); 

    RMC_NS_4_1=interp1([RMC_lon(4),RMC_lon(1)],[RMC_lat(4),RMC_lat(1)],POSXHC);

    ISNAN_RMC_NS(4)=isnan(RMC_NS_4_1);



    RMC_OE_1_2=interp1([RMC_lat(1),RMC_lat(2)],[RMC_lon(1),RMC_lon(2)],POSYHC);

    ISNAN_RMC_OE(1)=isnan(RMC_OE_1_2);


    RMC_OE_2_3=interp1([RMC_lat(2),RMC_lat(3)],[RMC_lon(2),RMC_lon(3)],POSYHC);

    ISNAN_RMC_OE(2)=isnan(RMC_OE_2_3);


    RMC_OE_3_4=interp1([RMC_lat(4),RMC_lat(3)],[RMC_lon(4),RMC_lon(3)],POSYHC);

    ISNAN_RMC_OE(3)=isnan(RMC_OE_3_4);


    RMC_OE_4_1=interp1([RMC_lat(4),RMC_lat(1)],[RMC_lon(4),RMC_lon(1)],POSYHC);

    ISNAN_RMC_OE(4)=isnan(RMC_OE_4_1);

    %%%



    if sum(ISNAN_SBB_OE(:))==2 && sum(ISNAN_SBB_NS(:))==2 && sum(ISNAN_SBB_OE(2:3))~=2  && sum(ISNAN_SBB_OE([1,4]))~=2 && sum(ISNAN_SBB_NS(1:2))~=2   && sum(ISNAN_SBB_NS([3,4]))~=2

        Tu_RF=abs(DECAY_U(1));
        Tv_RF=abs(DECAY_V(1));

        desv_u_RF=VAR_U(1);
        desv_v_RF=VAR_V(1);

    elseif POSXHC>360-55.5 && POSXHC<360-53 && POSYHC>-41 && POSYHC<-37 

        Tu_RF=abs(DECAY_U(2));
        Tv_RF=abs(DECAY_V(2));

        desv_u_RF=VAR_U(2);
        desv_v_RF=VAR_V(2);            


    elseif sum(ISNAN_BCO_OE(:))==2 && sum(ISNAN_BCO_NS(:))==1% && sum(ISNAN_BCO_OE(2:3))~=2  && sum(ISNAN_BCO_OE([1,4]))~=2 && sum(ISNAN_BCO_NS(1:2))~=2 

        Tu_RF=abs(DECAY_U(3));
        Tv_RF=abs(DECAY_V(3));

        desv_u_RF=VAR_U(3);
        desv_v_RF=VAR_V(3);

    elseif sum(ISNAN_MC_OE(:))==2 && sum(ISNAN_MC_NS(:))==2 && sum(ISNAN_MC_OE(2:3))~=2  && sum(ISNAN_MC_OE([1,4]))~=2 && sum(ISNAN_MC_NS(1:2))~=2  && sum(ISNAN_MC_NS([3,4]))~=2

        Tu_RF=abs(DECAY_U(4));
        Tv_RF=abs(DECAY_V(4));

        desv_u_RF=VAR_U(4);
        desv_v_RF=VAR_V(4);          

    elseif sum(ISNAN_RMC_OE(:))==2 && sum(ISNAN_RMC_NS(:))==2 && sum(ISNAN_RMC_OE(2:3))~=2  && sum(ISNAN_RMC_OE([1,4]))~=2 && sum(ISNAN_RMC_NS(1:2))~=2  && sum(ISNAN_RMC_NS([3,4]))~=2

        Tu_RF=abs(DECAY_U(5));
        Tv_RF=abs(DECAY_V(5));

        desv_u_RF=VAR_U(5);
        desv_v_RF=VAR_V(5);

    elseif POSXHC>360-53 && POSXHC<360-39 && POSYHC>-50 && POSYHC<-46.5 

        Tu_RF=abs(DECAY_U(6));
        Tv_RF=abs(DECAY_V(6));

        desv_u_RF=VAR_U(6);
        desv_v_RF=VAR_V(6);

    elseif POSYHC<-46.5


        Tu_RF=abs(DECAY_U(7));
        Tv_RF=abs(DECAY_V(7));

        desv_u_RF=VAR_U(7);
        desv_v_RF=VAR_V(7);    

    else

        Tu_RF=abs(DECAY_U(8));
        Tv_RF=abs(DECAY_V(8));

        desv_u_RF=VAR_U(8);
        desv_v_RF=VAR_V(8);

    end

end