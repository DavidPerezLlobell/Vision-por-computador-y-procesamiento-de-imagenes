% =========================================================================
% REPOSITORIO DE VISION POR COMPUTADOR
% Archivo: 01_fundamentos_procesamiento_imagenes_matlab.m
% Descripcion: Modulo fundamental para la manipulacion y analisis de imagenes 
%              digitales en MATLAB. Cubre adquisicion, representacion 2D/3D, 
%              perfiles de intensidad, submuestreo espacial, conversion de 
%              espacios de color (RGB/HSV) e interaccion para extraccion de ROI.
% Valor practico: Base tecnica para pipelines de inspeccion industrial, 
%                 segmentacion por color y preprocesamiento de vision artificial.
% =========================================================================

%% Limpieza inicial del entorno de trabajo
clearvars;      % Elimina todas las variables guardadas en el espacio de trabajo (Workspace)
close all;      % Cierra todas las ventanas de figuras que esten abiertas
clc;            % Limpia el texto visible en la ventana de comandos (Command Window)

%% =========================================================================
% MODULO 1: Carga y visualizacion de imagenes simples y compuestas
% =========================================================================
% Proposito: Adquisicion de archivos de imagen a matrices de memoria
% y despliegue en interfaces graficas independientes y compuestas.

% imread: Lee una imagen desde disco y la convierte en una matriz de datos.
% Devuelve una matriz 2D (escala de grises) o 3D (3 canales de color RGB).
im1 = imread('Connector 01.jpg'); % Carga la imagen del conector en escala de grises
im2 = imread('Cables14.jpg');     % Carga la imagen de cables en formato RGB

% Visualizacion en ventanas independientes
figure;                           % Inicializa una nueva ventana grafica
imshow(im1);                      % Muestra la matriz 'im1' como una imagen
title('Imagen Conector (im1)');   % Asigna titulo a la figura

figure;                           % Inicializa una segunda ventana independiente
imshow(im2);                      % Muestra la matriz de color 'im2'
title('Imagen Cables (im2)');     % Asigna titulo a la figura

% Visualizacion multiple en ventana dividida
f1 = figure;                      % Inicializa figura y almacena su manejador en 'f1'
set(f1, 'Name', 'Modulo 1: Visualizacion Compuesta'); % Define el nombre de la ventana

% subplot(m, n, p): Divide la figura en una rejilla de m filas por n columnas.
% El parametro p define el cuadrante activo para la renderizacion.
subplot(1, 2, 1);                 % Selecciona la celda 1 (1 fila, 2 columnas, posicion 1)
imshow(im1);                      % Renderiza la imagen del conector en el cuadrante izquierdo
title('Componente: Conector');    % Titulo del cuadrante izquierdo

subplot(1, 2, 2);                 % Selecciona la celda 2 (1 fila, 2 columnas, posicion 2)
imshow(im2);                      % Renderiza la imagen de cables en el cuadrante derecho
title('Componente: Cables');      % Titulo del cuadrante derecho

%% =========================================================================
% MODULO 2: Representacion 3D de intensidad como mapa topografico
% =========================================================================
% Proposito: Interpretar la matriz de niveles de gris como una superficie tridimensional
% donde la altura (Z) representa la intensidad luminosa de cada pixel.

f3 = figure;                      % Inicializa nueva ventana grafica
set(f3, 'Name', 'Modulo 2: Topografia de Intensidades 3D'); % Asigna nombre a la ventana

% double(): Convierte los valores de la matriz de enteros sin signo (uint8, 0-255) 
% a formato de coma flotante de doble precision (double), requerido para operaciones 3D.
im1_double = double(im1);          % Conversion de tipo de datos para modelado tridimensional

% surf(Z): Genera una malla de superficie 3D utilizando los valores matriciales como cotas de altura.
surf(im1_double);                 % Renderiza la topografia 3D de la imagen

% colormap: Aplica la paleta de color para el mapeo de alturas. 'gray' asigna 0 a negro y 255 a blanco.
colormap gray;                    % Define escala de grises para la superficie

% shading interp: Modela el color mediante interpolacion entre vertices, 
% eliminando la rejilla ortogonal para obtener una superficie continua.
shading interp;                   % Suaviza el renderizado de la superficie

title('Modelado 3D de la Intensidad Luminosa'); % Titulo descriptivo de la representacion
xlabel('Coordenada X (Columnas)'); % Etiqueta del eje X
ylabel('Coordenada Y (Filas)');    % Etiqueta del eje Y
zlabel('Nivel de Gris (0-255)');  % Etiqueta del eje Z

%% =========================================================================
% MODULO 3: Extraccion de perfil de intensidad en linea transversal
% =========================================================================
% Proposito: Extraer y graficar el vector unidimensional de niveles de gris 
% a lo largo de una fila especifica de la imagen.

f4 = figure;                      % Inicializa nueva ventana grafica
set(f4, 'Name', 'Modulo 3: Perfil de Intensidad Transversal'); % Nombre de la figura

% Cuadrante superior: Inspeccion visual de la linea de muestreo
subplot(2, 1, 1);                 % Configura rejilla 2x1 (activa posicion 1)
imshow(im1);                      % Muestra la imagen original

hold on;                          % Activa la superposicion de elementos graficos sobre la imagen
axis on;                          % Habilita los ejes de coordenadas en pixeles

% size(matriz, dimension): Retorna las dimensiones de la matriz. La dimension 2 es el ancho.
num_columnas = size(im1, 2);      % Obtiene la cantidad total de columnas

fila_analizar = 185;              % Fila seleccionada para el muestreo del perfil

% plot(X, Y, 'color'): Dibuja un segmento de recta entre los puntos especificados.
plot([1, num_columnas], [fila_analizar, fila_analizar], 'g', 'LineWidth', 1.5); % Traza la linea de inspeccion en verde
title(['Linea de inspeccion transversal (Fila ', num2str(fila_analizar), ')']); % Titulo con la fila evaluada

% Cuadrante inferior: Senal unidimensional del perfil
subplot(2, 1, 2);                 % Activa la posicion inferior (posicion 2)

% im1(185, :): Indexacion matricial. Extrae la fila 185 completa (vector horizontal de intensidades).
plot(im1(fila_analizar, :));      % Grafica la senal de intensidad luminosa

% axis([xmin xmax ymin ymax]): Establece los limites de los ejes del sistema cartesiano.
axis([0, num_columnas, 0, 255]);  % Escala X al ancho de la imagen e Y al rango dinamico (0-255)
grid on;                          % Habilita la rejilla para lectura analitica
title('Senal de Intensidad a lo largo del eje transversal'); % Titulo de la grafica
xlabel('Posicion del Pixel (Columna)'); % Etiqueta del eje X
ylabel('Nivel de Gris');          % Etiqueta del eje Y

%% =========================================================================
% MODULO 4: Submuestreo espacial y analisis de resolucion
% =========================================================================
% Proposito: Evaluar el impacto de la reduccion de resolucion espacial (downsampling)
% mediante la seleccion discreta de pixeles con paso constante.

f5 = figure;                      % Inicializa nueva ventana grafica
set(f5, 'Name', 'Modulo 4: Evaluacion de Resolucion Espacial'); % Nombre de la figura

% Resolucion nativa
subplot(2, 2, 1);                 % Posicion 1 (superior izquierda)
imshow(im1);                      % Renderiza la imagen sin modificaciones
axis on;                          % Habilita la escala espacial de los ejes
title('Resolucion nativa (100%)'); % Titulo del cuadrante

% Submuestreo al 50% (paso de 2 pixeles)
% im1(inicio:paso:fin, inicio:paso:fin): Indexacion con salto discreto en ambas dimensiones.
im_res_2 = im1(1:2:end, 1:2:end); % Reduce la dimension matricial a la mitad
subplot(2, 2, 2);                 % Posicion 2 (superior derecha)
imshow(im_res_2);                 % Muestra la imagen submuestreada
axis on;                          % Muestra la reduccion en los ejes
title('Submuestreo 1:2 (50%)');   % Titulo del cuadrante

% Submuestreo al 25% (paso de 4 pixeles)
im_res_4 = im1(1:4:end, 1:4:end); % Muestra 1 de cada 4 pixeles en X e Y
subplot(2, 2, 3);                 % Posicion 3 (inferior izquierda)
imshow(im_res_4);                 % Renderiza la perdida de detalle
axis on;                          % Muestra la escala reducida
title('Submuestreo 1:4 (25%)');   % Titulo del cuadrante

% Submuestreo al 12.5% (paso de 8 pixeles)
im_res_8 = im1(1:8:end, 1:8:end); % Muestra 1 de cada 8 pixeles en X e Y
subplot(2, 2, 4);                 % Posicion 4 (inferior derecha)
imshow(im_res_8);                 % Muestra el efecto de aliasing / pixelado
axis on;                          % Muestra la escala reducida
title('Submuestreo 1:8 (12.5%)'); % Titulo del cuadrante

%% =========================================================================
% MODULO 5: Descomposicion de canales en espacio de color RGB
% =========================================================================
% Proposito: Aislar las matrices de intensidad correspondientes a las
% componentes primarias de color: Rojo (R), Verde (G) y Azul (B).

f6 = figure;                      % Inicializa nueva ventana grafica
set(f6, 'Name', 'Modulo 5: Descomposicion Tricromatica RGB'); % Nombre de la figura

% Imagen RGB integrada
subplot(2, 2, 1);                 % Posicion 1
imshow(im2);                      % Muestra la composicion cromatica completa
title('Composicion RGB Original'); % Titulo identificador

% Extraccion del canal Rojo (Plano 1)
% im2(:,:,1) selecciona la totalidad de filas y columnas del primer plano 3D.
canal_R = im2(:, :, 1);           % Matriz 2D de intensidad de la componente Roja
subplot(2, 2, 2);                 % Posicion 2
imshow(canal_R);                  % Muestra la respuesta en escala de grises del canal R
title('Canal R (Rojo)');          % Titulo identificador

% Extraccion del canal Verde (Plano 2)
canal_G = im2(:, :, 2);           % Matriz 2D de intensidad de la componente Verde
subplot(2, 2, 3);                 % Posicion 3
imshow(canal_G);                  % Muestra la respuesta en escala de grises del canal G
title('Canal G (Verde)');         % Titulo identificador

% Extraccion del canal Azul (Plano 3)
canal_B = im2(:, :, 3);           % Matriz 2D de intensidad de la componente Azul
subplot(2, 2, 4);                 % Posicion 4
imshow(canal_B);                  % Muestra la respuesta en escala de grises del canal B
title('Canal B (Azul)');          % Titulo identificador

%% =========================================================================
% MODULO 6: Transformacion y analisis en espacio de color HSV
% =========================================================================
% Proposito: Convertir el espacio RGB al espacio perceptual HSV para desacoplar
% la informacion croma (Matiz y Saturacion) de la informacion luma (Brillo).

f7 = figure;                      % Inicializa nueva ventana grafica
set(f7, 'Name', 'Modulo 6: Espacio Perceptual HSV'); % Nombre de la figura

% rgb2hsv(): Transforma la matriz RGB a espacio HSV normalizando los valores
% de las tres componentes en el rango de punto flotante [0.0, 1.0].
im3_hsv = rgb2hsv(im2);           % Matriz 3D normalizada en espacio HSV

% Representacion compuesta HSV
subplot(2, 2, 1);                 % Posicion 1
imshow(im3_hsv);                  % Renderiza el espacio de color HSV
title('Representacion HSV');       % Titulo identificador

% Componente H: Tono / Matiz (Hue) -> Posicion angular en el circulo cromatico.
canal_H = im3_hsv(:, :, 1);       % Plano 1 (Tono)
subplot(2, 2, 2);                 % Posicion 2
imshow(canal_H);                  % Muestra la distribucion de matices
title('Componente H (Matiz / Hue)'); % Titulo identificador

% Componente S: Saturacion (Saturation) -> Grado de pureza del color (0=Gris, 1=Puro).
canal_S = im3_hsv(:, :, 2);       % Plano 2 (Saturacion)
subplot(2, 2, 3);                 % Posicion 3
imshow(canal_S);                  % Destaca zonas con alta pureza cromatica
title('Componente S (Saturacion)'); % Titulo identificador

% Componente V: Valor / Brillo (Value) -> Intensidad de iluminacion.
canal_V = im3_hsv(:, :, 3);       % Plano 3 (Brillo)
subplot(2, 2, 4);                 % Posicion 4
imshow(canal_V);                  % Representacion de la luminancia
title('Componente V (Brillo / Value)'); % Titulo identificador

%% =========================================================================
% MODULO 7: Segmentacion cromatica por combinacion puntual H x S
% =========================================================================
% Proposito: Resaltar objetos de color de alta pureza mediante el producto
% matricial elemento a elemento entre los planos de Matiz y Saturacion.

f8 = figure;                      % Inicializa nueva ventana grafica
set(f8, 'Name', 'Modulo 7: Filtrado Cromatico Compuesto'); % Nombre de la figura

% El operador .* realiza la multiplicacion elemento a elemento.
% Al multiplicar Matiz por Saturacion, los pixeles acromaticos (Saturacion ~ 0) son eliminados.
% Se aplica un factor de escala (2) para mejorar el contraste de la mascara resultante.
im_multiplicada = 2 * (im3_hsv(:, :, 1) .* im3_hsv(:, :, 2)); % Operacion punto a punto amplificada

imshow(im_multiplicada);          % Muestra la mascara de resalte cromatico
title('Mascara de Aislamiento: 2 * (Matiz .* Saturacion)'); % Titulo explicativo de la operacion

%% =========================================================================
% MODULO 8: Muestreo interactivo de coordenadas y niveles de intensidad
% =========================================================================
% Proposito: Capturar puntos sobre la imagen mediante eventos de raton,
% marcar graficamente su posicion e inspeccionar sus valores numericos.

f10 = figure;                     % Inicializa nueva ventana grafica
set(f10, 'Name', 'Modulo 8: Adquisicion Manual de Puntos'); % Nombre de la figura
imshow(im1);                      % Muestra la imagen base para el muestreo
title('Seleccione 9 puntos sobre la superficie con el raton'); % Instruccion operativa
hold on;                          % Mantiene la imagen estatica para la superposicion de datos

% Matriz de almacenamiento: [Fila (Y), Columna (X), ValorIntensidad]
puntos_guardados = zeros(9, 3);   % Pre-asignacion de memoria para 9 registros

for ind = 1:9                     % Bucle de adquisicion para 9 muestras
    
    % ginput(n): Interrumpe la ejecucion hasta recibir 'n' eventos de clic sobre la figura.
    % Devuelve las coordenadas espaciales continuas (X=Columna, Y=Fila).
    [x, y] = ginput(1);           % Captura las coordenadas de 1 clic
    
    % round(): Convierte las coordenadas continuas en enteros discretos para indexacion matricial.
    x = round(x);                 % Columna discreta
    y = round(y);                 % Fila discreta
    
    % Extraccion de la intensidad del pixel en la matriz (indices: fila y, columna x)
    nivel_gris = double(im1(y, x)); % Lectura del valor numerico de intensidad
    
    % Registro del punto en la estructura de datos
    puntos_guardados(ind, :) = [y, x, nivel_gris]; % Almacena: [Fila, Columna, Intensidad]
    
    % Marcado grafico de la muestra sobre la imagen
    plot(x, y, 'g*', 'MarkerSize', 8); % Renderiza un marcador con forma de estrella verde
    
    % text(x, y, texto): Inserta una etiqueta de texto en la ubicacion indicada.
    text(x + 10, y + 10, num2str(ind), 'Color', 'g', 'FontSize', 12, 'FontWeight', 'bold'); % Etiqueta numerica
    
end % Fin del bucle de muestreo

% Presentacion de la matriz de datos en la consola de comandos
disp('Registros de muestras adquiridas [Fila, Columna, Intensidad]:'); % Encabezado de salida
disp(puntos_guardados);           % Muestra la estructura matricial resultante

%% =========================================================================
% MODULO 9: Extraccion de Region de Interes (ROI) por seleccion diagonal
% =========================================================================
% Proposito: Recortar una sub-matriz rectangular definiendo dos puntos limite 
% opuestos seleccionados interactivamente por el usuario.

f11 = figure;                     % Inicializa nueva ventana grafica
set(f11, 'Name', 'Modulo 9: Extraccion de ROI'); % Nombre de la figura
imshow(im1);                      % Muestra la imagen para la delimitacion
title('Seleccione los dos vertices opuestos de la ROI (Superior-Izquierdo e Inferior-Derecho)'); % Guia de uso

% Captura de los vertices limite de la region
[x_pts, y_pts] = ginput(2);       % Captura 2 puntos de referencia

% Discretizacion de coordenadas a enteros
x_pts = round(x_pts);             % Limites de columna
y_pts = round(y_pts);             % Limites de fila

% Calculo de rangos limite del rectangulo
col_min = min(x_pts);             % Columna inicial (limite izquierdo)
col_max = max(x_pts);             % Columna final (limite derecho)
row_min = min(y_pts);             % Fila inicial (limite superior)
row_max = max(y_pts);             % Fila final (limite inferior)

% Extraccion de la sub-matriz mediante acotacion de rangos (Filas, Columnas)
sub_imagen = im1(row_min:row_max, col_min:col_max); % Sub-matriz de la ROI

% Presentacion de la ROI extraida en interfaz dedicada
figure;                           % Ventana grafica independiente para la ROI
imshow(sub_imagen);               % Renderiza unicamente la sub-imagen
title('Region de Interes (ROI) Extraida'); % Titulo de la figura

% Fin del script
% =========================================================================
% REPOSITORIO DE VISION POR COMPUTADOR
% Archivo: 01_fundamentos_procesamiento_imagenes_matlab.m
% Descripcion: Modulo fundamental para la manipulacion y analisis de imagenes 
%              digitales en MATLAB. Cubre adquisicion, representacion 2D/3D, 
%              perfiles de intensidad, submuestreo espacial, conversion de 
%              espacios de color (RGB/HSV) e interaccion para extraccion de ROI.
% Valor practico: Base tecnica para pipelines de inspeccion industrial, 
%                 segmentacion por color y preprocesamiento de vision artificial.
% =========================================================================

%% Limpieza inicial del entorno de trabajo
clearvars;      % Elimina todas las variables guardadas en el espacio de trabajo (Workspace)
close all;      % Cierra todas las ventanas de figuras que esten abiertas
clc;            % Limpia el texto visible en la ventana de comandos (Command Window)

%% =========================================================================
% MODULO 1: Carga y visualizacion de imagenes simples y compuestas
% =========================================================================
% Proposito: Adquisicion de archivos de imagen a matrices de memoria
% y despliegue en interfaces graficas independientes y compuestas.

% imread: Lee una imagen desde disco y la convierte en una matriz de datos.
% Devuelve una matriz 2D (escala de grises) o 3D (3 canales de color RGB).
im1 = imread('Connector 01.jpg'); % Carga la imagen del conector en escala de grises
im2 = imread('Cables14.jpg');     % Carga la imagen de cables en formato RGB

% Visualizacion en ventanas independientes
figure;                           % Inicializa una nueva ventana grafica
imshow(im1);                      % Muestra la matriz 'im1' como una imagen
title('Imagen Conector (im1)');   % Asigna titulo a la figura

figure;                           % Inicializa una segunda ventana independiente
imshow(im2);                      % Muestra la matriz de color 'im2'
title('Imagen Cables (im2)');     % Asigna titulo a la figura

% Visualizacion multiple en ventana dividida
f1 = figure;                      % Inicializa figura y almacena su manejador en 'f1'
set(f1, 'Name', 'Modulo 1: Visualizacion Compuesta'); % Define el nombre de la ventana

% subplot(m, n, p): Divide la figura en una rejilla de m filas por n columnas.
% El parametro p define el cuadrante activo para la renderizacion.
subplot(1, 2, 1);                 % Selecciona la celda 1 (1 fila, 2 columnas, posicion 1)
imshow(im1);                      % Renderiza la imagen del conector en el cuadrante izquierdo
title('Componente: Conector');    % Titulo del cuadrante izquierdo

subplot(1, 2, 2);                 % Selecciona la celda 2 (1 fila, 2 columnas, posicion 2)
imshow(im2);                      % Renderiza la imagen de cables en el cuadrante derecho
title('Componente: Cables');      % Titulo del cuadrante derecho

%% =========================================================================
% MODULO 2: Representacion 3D de intensidad como mapa topografico
% =========================================================================
% Proposito: Interpretar la matriz de niveles de gris como una superficie tridimensional
% donde la altura (Z) representa la intensidad luminosa de cada pixel.

f3 = figure;                      % Inicializa nueva ventana grafica
set(f3, 'Name', 'Modulo 2: Topografia de Intensidades 3D'); % Asigna nombre a la ventana

% double(): Convierte los valores de la matriz de enteros sin signo (uint8, 0-255) 
% a formato de coma flotante de doble precision (double), requerido para operaciones 3D.
im1_double = double(im1);          % Conversion de tipo de datos para modelado tridimensional

% surf(Z): Genera una malla de superficie 3D utilizando los valores matriciales como cotas de altura.
surf(im1_double);                 % Renderiza la topografia 3D de la imagen

% colormap: Aplica la paleta de color para el mapeo de alturas. 'gray' asigna 0 a negro y 255 a blanco.
colormap gray;                    % Define escala de grises para la superficie

% shading interp: Modela el color mediante interpolacion entre vertices, 
% eliminando la rejilla ortogonal para obtener una superficie continua.
shading interp;                   % Suaviza el renderizado de la superficie

title('Modelado 3D de la Intensidad Luminosa'); % Titulo descriptivo de la representacion
xlabel('Coordenada X (Columnas)'); % Etiqueta del eje X
ylabel('Coordenada Y (Filas)');    % Etiqueta del eje Y
zlabel('Nivel de Gris (0-255)');  % Etiqueta del eje Z

%% =========================================================================
% MODULO 3: Extraccion de perfil de intensidad en linea transversal
% =========================================================================
% Proposito: Extraer y graficar el vector unidimensional de niveles de gris 
% a lo largo de una fila especifica de la imagen.

f4 = figure;                      % Inicializa nueva ventana grafica
set(f4, 'Name', 'Modulo 3: Perfil de Intensidad Transversal'); % Nombre de la figura

% Cuadrante superior: Inspeccion visual de la linea de muestreo
subplot(2, 1, 1);                 % Configura rejilla 2x1 (activa posicion 1)
imshow(im1);                      % Muestra la imagen original

hold on;                          % Activa la superposicion de elementos graficos sobre la imagen
axis on;                          % Habilita los ejes de coordenadas en pixeles

% size(matriz, dimension): Retorna las dimensiones de la matriz. La dimension 2 es el ancho.
num_columnas = size(im1, 2);      % Obtiene la cantidad total de columnas

fila_analizar = 185;              % Fila seleccionada para el muestreo del perfil

% plot(X, Y, 'color'): Dibuja un segmento de recta entre los puntos especificados.
plot([1, num_columnas], [fila_analizar, fila_analizar], 'g', 'LineWidth', 1.5); % Traza la linea de inspeccion en verde
title(['Linea de inspeccion transversal (Fila ', num2str(fila_analizar), ')']); % Titulo con la fila evaluada

% Cuadrante inferior: Senal unidimensional del perfil
subplot(2, 1, 2);                 % Activa la posicion inferior (posicion 2)

% im1(185, :): Indexacion matricial. Extrae la fila 185 completa (vector horizontal de intensidades).
plot(im1(fila_analizar, :));      % Grafica la senal de intensidad luminosa

% axis([xmin xmax ymin ymax]): Establece los limites de los ejes del sistema cartesiano.
axis([0, num_columnas, 0, 255]);  % Escala X al ancho de la imagen e Y al rango dinamico (0-255)
grid on;                          % Habilita la rejilla para lectura analitica
title('Senal de Intensidad a lo largo del eje transversal'); % Titulo de la grafica
xlabel('Posicion del Pixel (Columna)'); % Etiqueta del eje X
ylabel('Nivel de Gris');          % Etiqueta del eje Y

%% =========================================================================
% MODULO 4: Submuestreo espacial y analisis de resolucion
% =========================================================================
% Proposito: Evaluar el impacto de la reduccion de resolucion espacial (downsampling)
% mediante la seleccion discreta de pixeles con paso constante.

f5 = figure;                      % Inicializa nueva ventana grafica
set(f5, 'Name', 'Modulo 4: Evaluacion de Resolucion Espacial'); % Nombre de la figura

% Resolucion nativa
subplot(2, 2, 1);                 % Posicion 1 (superior izquierda)
imshow(im1);                      % Renderiza la imagen sin modificaciones
axis on;                          % Habilita la escala espacial de los ejes
title('Resolucion nativa (100%)'); % Titulo del cuadrante

% Submuestreo al 50% (paso de 2 pixeles)
% im1(inicio:paso:fin, inicio:paso:fin): Indexacion con salto discreto en ambas dimensiones.
im_res_2 = im1(1:2:end, 1:2:end); % Reduce la dimension matricial a la mitad
subplot(2, 2, 2);                 % Posicion 2 (superior derecha)
imshow(im_res_2);                 % Muestra la imagen submuestreada
axis on;                          % Muestra la reduccion en los ejes
title('Submuestreo 1:2 (50%)');   % Titulo del cuadrante

% Submuestreo al 25% (paso de 4 pixeles)
im_res_4 = im1(1:4:end, 1:4:end); % Muestra 1 de cada 4 pixeles en X e Y
subplot(2, 2, 3);                 % Posicion 3 (inferior izquierda)
imshow(im_res_4);                 % Renderiza la perdida de detalle
axis on;                          % Muestra la escala reducida
title('Submuestreo 1:4 (25%)');   % Titulo del cuadrante

% Submuestreo al 12.5% (paso de 8 pixeles)
im_res_8 = im1(1:8:end, 1:8:end); % Muestra 1 de cada 8 pixeles en X e Y
subplot(2, 2, 4);                 % Posicion 4 (inferior derecha)
imshow(im_res_8);                 % Muestra el efecto de aliasing / pixelado
axis on;                          % Muestra la escala reducida
title('Submuestreo 1:8 (12.5%)'); % Titulo del cuadrante

%% =========================================================================
% MODULO 5: Descomposicion de canales en espacio de color RGB
% =========================================================================
% Proposito: Aislar las matrices de intensidad correspondientes a las
% componentes primarias de color: Rojo (R), Verde (G) y Azul (B).

f6 = figure;                      % Inicializa nueva ventana grafica
set(f6, 'Name', 'Modulo 5: Descomposicion Tricromatica RGB'); % Nombre de la figura

% Imagen RGB integrada
subplot(2, 2, 1);                 % Posicion 1
imshow(im2);                      % Muestra la composicion cromatica completa
title('Composicion RGB Original'); % Titulo identificador

% Extraccion del canal Rojo (Plano 1)
% im2(:,:,1) selecciona la totalidad de filas y columnas del primer plano 3D.
canal_R = im2(:, :, 1);           % Matriz 2D de intensidad de la componente Roja
subplot(2, 2, 2);                 % Posicion 2
imshow(canal_R);                  % Muestra la respuesta en escala de grises del canal R
title('Canal R (Rojo)');          % Titulo identificador

% Extraccion del canal Verde (Plano 2)
canal_G = im2(:, :, 2);           % Matriz 2D de intensidad de la componente Verde
subplot(2, 2, 3);                 % Posicion 3
imshow(canal_G);                  % Muestra la respuesta en escala de grises del canal G
title('Canal G (Verde)');         % Titulo identificador

% Extraccion del canal Azul (Plano 3)
canal_B = im2(:, :, 3);           % Matriz 2D de intensidad de la componente Azul
subplot(2, 2, 4);                 % Posicion 4
imshow(canal_B);                  % Muestra la respuesta en escala de grises del canal B
title('Canal B (Azul)');          % Titulo identificador

%% =========================================================================
% MODULO 6: Transformacion y analisis en espacio de color HSV
% =========================================================================
% Proposito: Convertir el espacio RGB al espacio perceptual HSV para desacoplar
% la informacion croma (Matiz y Saturacion) de la informacion luma (Brillo).

f7 = figure;                      % Inicializa nueva ventana grafica
set(f7, 'Name', 'Modulo 6: Espacio Perceptual HSV'); % Nombre de la figura

% rgb2hsv(): Transforma la matriz RGB a espacio HSV normalizando los valores
% de las tres componentes en el rango de punto flotante [0.0, 1.0].
im3_hsv = rgb2hsv(im2);           % Matriz 3D normalizada en espacio HSV

% Representacion compuesta HSV
subplot(2, 2, 1);                 % Posicion 1
imshow(im3_hsv);                  % Renderiza el espacio de color HSV
title('Representacion HSV');       % Titulo identificador

% Componente H: Tono / Matiz (Hue) -> Posicion angular en el circulo cromatico.
canal_H = im3_hsv(:, :, 1);       % Plano 1 (Tono)
subplot(2, 2, 2);                 % Posicion 2
imshow(canal_H);                  % Muestra la distribucion de matices
title('Componente H (Matiz / Hue)'); % Titulo identificador

% Componente S: Saturacion (Saturation) -> Grado de pureza del color (0=Gris, 1=Puro).
canal_S = im3_hsv(:, :, 2);       % Plano 2 (Saturacion)
subplot(2, 2, 3);                 % Posicion 3
imshow(canal_S);                  % Destaca zonas con alta pureza cromatica
title('Componente S (Saturacion)'); % Titulo identificador

% Componente V: Valor / Brillo (Value) -> Intensidad de iluminacion.
canal_V = im3_hsv(:, :, 3);       % Plano 3 (Brillo)
subplot(2, 2, 4);                 % Posicion 4
imshow(canal_V);                  % Representacion de la luminancia
title('Componente V (Brillo / Value)'); % Titulo identificador

%% =========================================================================
% MODULO 7: Segmentacion cromatica por combinacion puntual H x S
% =========================================================================
% Proposito: Resaltar objetos de color de alta pureza mediante el producto
% matricial elemento a elemento entre los planos de Matiz y Saturacion.

f8 = figure;                      % Inicializa nueva ventana grafica
set(f8, 'Name', 'Modulo 7: Filtrado Cromatico Compuesto'); % Nombre de la figura

% El operador .* realiza la multiplicacion elemento a elemento.
% Al multiplicar Matiz por Saturacion, los pixeles acromaticos (Saturacion ~ 0) son eliminados.
% Se aplica un factor de escala (2) para mejorar el contraste de la mascara resultante.
im_multiplicada = 2 * (im3_hsv(:, :, 1) .* im3_hsv(:, :, 2)); % Operacion punto a punto amplificada

imshow(im_multiplicada);          % Muestra la mascara de resalte cromatico
title('Mascara de Aislamiento: 2 * (Matiz .* Saturacion)'); % Titulo explicativo de la operacion

%% =========================================================================
% MODULO 8: Muestreo interactivo de coordenadas y niveles de intensidad
% =========================================================================
% Proposito: Capturar puntos sobre la imagen mediante eventos de raton,
% marcar graficamente su posicion e inspeccionar sus valores numericos.

f10 = figure;                     % Inicializa nueva ventana grafica
set(f10, 'Name', 'Modulo 8: Adquisicion Manual de Puntos'); % Nombre de la figura
imshow(im1);                      % Muestra la imagen base para el muestreo
title('Seleccione 9 puntos sobre la superficie con el raton'); % Instruccion operativa
hold on;                          % Mantiene la imagen estatica para la superposicion de datos

% Matriz de almacenamiento: [Fila (Y), Columna (X), ValorIntensidad]
puntos_guardados = zeros(9, 3);   % Pre-asignacion de memoria para 9 registros

for ind = 1:9                     % Bucle de adquisicion para 9 muestras
    
    % ginput(n): Interrumpe la ejecucion hasta recibir 'n' eventos de clic sobre la figura.
    % Devuelve las coordenadas espaciales continuas (X=Columna, Y=Fila).
    [x, y] = ginput(1);           % Captura las coordenadas de 1 clic
    
    % round(): Convierte las coordenadas continuas en enteros discretos para indexacion matricial.
    x = round(x);                 % Columna discreta
    y = round(y);                 % Fila discreta
    
    % Extraccion de la intensidad del pixel en la matriz (indices: fila y, columna x)
    nivel_gris = double(im1(y, x)); % Lectura del valor numerico de intensidad
    
    % Registro del punto en la estructura de datos
    puntos_guardados(ind, :) = [y, x, nivel_gris]; % Almacena: [Fila, Columna, Intensidad]
    
    % Marcado grafico de la muestra sobre la imagen
    plot(x, y, 'g*', 'MarkerSize', 8); % Renderiza un marcador con forma de estrella verde
    
    % text(x, y, texto): Inserta una etiqueta de texto en la ubicacion indicada.
    text(x + 10, y + 10, num2str(ind), 'Color', 'g', 'FontSize', 12, 'FontWeight', 'bold'); % Etiqueta numerica
    
end % Fin del bucle de muestreo

% Presentacion de la matriz de datos en la consola de comandos
disp('Registros de muestras adquiridas [Fila, Columna, Intensidad]:'); % Encabezado de salida
disp(puntos_guardados);           % Muestra la estructura matricial resultante

%% =========================================================================
% MODULO 9: Extraccion de Region de Interes (ROI) por seleccion diagonal
% =========================================================================
% Proposito: Recortar una sub-matriz rectangular definiendo dos puntos limite 
% opuestos seleccionados interactivamente por el usuario.

f11 = figure;                     % Inicializa nueva ventana grafica
set(f11, 'Name', 'Modulo 9: Extraccion de ROI'); % Nombre de la figura
imshow(im1);                      % Muestra la imagen para la delimitacion
title('Seleccione los dos vertices opuestos de la ROI (Superior-Izquierdo e Inferior-Derecho)'); % Guia de uso

% Captura de los vertices limite de la region
[x_pts, y_pts] = ginput(2);       % Captura 2 puntos de referencia

% Discretizacion de coordenadas a enteros
x_pts = round(x_pts);             % Limites de columna
y_pts = round(y_pts);             % Limites de fila

% Calculo de rangos limite del rectangulo
col_min = min(x_pts);             % Columna inicial (limite izquierdo)
col_max = max(x_pts);             % Columna final (limite derecho)
row_min = min(y_pts);             % Fila inicial (limite superior)
row_max = max(y_pts);             % Fila final (limite inferior)

% Extraccion de la sub-matriz mediante acotacion de rangos (Filas, Columnas)
sub_imagen = im1(row_min:row_max, col_min:col_max); % Sub-matriz de la ROI

% Presentacion de la ROI extraida en interfaz dedicada
figure;                           % Ventana grafica independiente para la ROI
imshow(sub_imagen);               % Renderiza unicamente la sub-imagen
title('Region de Interes (ROI) Extraida'); % Titulo de la figura

% Fin del script
