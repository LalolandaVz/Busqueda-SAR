# Busqueda-SAR
*****Busqueda_SAR****

Aplicación de asistencia a la búsqueda en casos SAR.

*Descripción*

En base a un datum inicial (la posición y fecha del evento SAR), se estima la trayectoria del objeto a buscar y se delimita su área de búsqueda (con una probabilidad asociada) a 24, 48 y 72 horas de ocurrido el evento. 
Esta aplicación se nutre de pronósticos de corrientes en el mar (Mercator y/o HyCOM), del modelo TPXO8-Atlas para determinar corrientes por marea, y del uso de métodos estocásticos para la estimación de áreas de búsqueda. 

*Paquetes externos*

Fueron utilizados los siguientes paquetes, modelos y funciones que NO son de mi autoría:

Google earth Matlab Toolbox:
Scott lee davis (2020). Google Earth Toolbox (https://www.mathworks.com/matlabcentral/fileexchange/12954-google-earth-toolbox), MATLAB Central File Exchange. Retrieved April 23, 2020.

hist2d.m:
François Beauducel (2020). 2-D histogram plot (https://www.mathworks.com/matlabcentral/fileexchange/66629-2-d-histogram-plot), MATLAB Central File Exchange. Retrieved April 23, 2020.

M_MAP (mapping package for MATLAB):
Pawlowicz, R., 2020. "M_Map: A mapping package for MATLAB", version 1.4m, [Computer software], available online at www.eoas.ubc.ca/~rich/map.html.

TPXO8_Atlas:
Egbert, Gary D., and Svetlana Y. Erofeeva. "Efficient inverse modeling of barotropic ocean tides." Journal of Atmospheric and Oceanic Technology 19.2 (2002): 183-204.


*Indicaciones de uso*

El script "Busqueda_SAR-12042020.m" (a ser utilizado en MATLAB R2017 o en alguna actualización posterior) debería buscar los paquetes, funciones y archivos necesarios para su funcionamiento dentro de esta carpeta (excepto el TPXO8_Atlas). Por lo tanto, debe completarse en la ventana de inicio (una vez ejecutado el script) la dirección de la misma.
El modelo TPXO8_Atlas debe descargarse del repositorio https://github.com/EarthAndSpaceResearch/TMD_Matlab_Toolbox_v2.5.git, y su contenido debe ubicarse dentro del directorio Busqueda-SAR, en una carpeta llamada "TPXO". 

*Indicaciones para realizar una aplicación con MATLAB compiler*

En caso de compilar en una aplicación con MATLAB, debe ubicarse la carpeta "private" del paquete "m_map" dentro de las direcciones /v92/gnlxa64, /v92/sys/os/gnlxa64 y /v92/sys/opengl/lib/gnlxa64.

*Descripción de opciones avanzadas*

Las opciones avanzadas están referidas a que tipo de pronóstico de corrientes utilizar. Hay 4 opciones:

- Modo predeterminado: en base a la jerarquía "Mercator(+mareas+olas)"-Mercator-HyCOM, se intenta descargar el modelo. De no ser posible la descarga de "Mercator(+mareas+olas)", se procede a descargar el "Mercator", y si tampoco es posible, descarga el "HyCOM".

- Mercator(+mareas+olas) : intenta descargar solo este modelo

- Mercator: intenta descargar solo este modelo

- GOFS 3.1: intenta descargar solo el HyCOM

- Utilizar pronóstico ya descargado: utiliza un pronóstico ya disponible. Debe ser alguna de las anteriores variantes de modelos. El pronóstico debe coincidir con la fecha ingresada en el inicio.


