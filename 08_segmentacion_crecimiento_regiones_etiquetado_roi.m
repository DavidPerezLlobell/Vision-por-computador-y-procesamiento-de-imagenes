% =========================================================================
% REPOSITORIO DE VISION POR COMPUTADOR
% Archivo: 08_segmentacion_crecimiento_regiones_etiquetado_roi.m
% Descripcion: Modulo para la segmentacion basada en regiones mediante
%              crecimiento de regiones (vercre_isa, cre_isa), etiquetado de 
%              componentes conectadas (bwlabel), agrupamiento por area y 
%              extraccion automatica de objetos (imcrop), y seleccion manual 
%              de regiones de interes (ROI con imrect, createMask).
% Valor practico: Inspeccion automatizada de componentes defectuosos (fusibles),
%                 conteo y marcado de centroides en piezas dispersas, aislamiento
%                 de conectores y filtrado de ruido ambiental por ROI.
% =========================================================================

%% Limpieza inicial del entorno de trabajo
clearvars;      % Elimina todas las variables guardadas en el espacio de trabajo (Workspace)
close all;      % Cierra todas las ventanas de figuras que esten abiertas
clc;            % Limpia el texto visible en la ventana de comandos (Command Window)

%% =========================================================================
% MODULO 1: Carga y despliegue de imagenes base para segmentacion
% =========================================================================

% Carga de imagenes de prueba: filtro de aceite, piezas y fusibles
im1 = imread('oilfilt0.jpg');   % Filtro de aceite
im2 = imread('Parts 01.jpg');   % Componentes mecanicos
im3 = imread('Fuse 00.tif');    % Fusible en buen estado
im4 = imread('Fuse 13.tif');    % Fusible defectuoso

figure;                         % Inicializa nueva ventana grafica
subplot(2, 2, 1), imshow(im1);  % Muestra filtro de aceite
subplot(2, 2, 2), imshow(im2);  % Muestra piezas mecanicas
subplot(2, 2, 3), imshow(im3);  % Muestra fusible 1
subplot(2, 2, 4), imshow(im4);  % Muestra fusible 2

%% =========================================================================
% MODULO 2: Crecimiento de regiones interactivo (vercre_isa)
% =========================================================================

% vercre_isa(imagen, umbral): Permite seleccionar una semilla con el raton
% y agrupa pixeles vecinos cuya diferencia de gris sea menor al umbral
ob1 = vercre_isa(im1, 20);      % Segmentacion interactiva sobre filtro (umbral 20)
ob2 = vercre_isa(im2, 30);      % Segmentacion interactiva sobre piezas (umbral 30)

%% =========================================================================
% MODULO 3: Inspeccion de calidad de fusibles por area de region
% =========================================================================

% Segmentacion de la region central del fusible mediante crecimiento de regiones
centro1 = vercre_isa(im3, 60);  % Crecimiento en fusible 00 (umbral 60)
title(num2str(bwarea(centro1))); % Muestra el area bwarea en el titulo de la figura

centro2 = vercre_isa(im4, 60);  % Crecimiento en fusible 13 (umbral 60)
title(num2str(bwarea(centro2))); % Muestra el area bwarea del fusible defectuoso

%% =========================================================================
% MODULO 4: Crecimiento de regiones con semilla fija (cre_isa)
% =========================================================================

% cre_isa(imagen, umbral, fila, columna): Segmenta la region partiendo de la posicion (1,1)
fondo = cre_isa(im2, 50, 1, 1); % Segmentacion del fondo a partir de la esquina superior izquierda
im2obs = not(fondo);            % Inversion para obtener los objetos en blanco sobre fondo negro
figure, imshow(im2obs);         % Muestra los objetos segmentados

%% =========================================================================
% MODULO 5: Etiquetado de componentes conectadas y paletas de color
% =========================================================================

im5 = imread('Parts00.png');     % Carga imagen de clasificacion de piezas
im5b = not(imbinarize(im5));    % Binarizacion e inversion (objetos en blanco)

% bwlabel(imagen_binaria): Asigna un numero entero unico (etiqueta) a cada componente conectada
im5L = bwlabel(im5b);           % Matriz de etiquetas de regiones conectadas

% Visualizacion con mapas de color para diferenciar cada objeto
figure;
imshow(label2rgb(im5L));        % Convierte matriz de etiquetas a imagen RGB con colores distintos
figure;
imshow(im5L, [0 0 0; colorcube]); % Visualizacion mediante paleta colorcube

%% =========================================================================
% MODULO 6: Filtrado por area y marcado de centroides en objetos
% =========================================================================

figure, imshow(im5), hold on;

% Recorre todas las componentes conectadas detectadas por bwlabel
for k = 1:max(max(im5L))
    ob = (im5L == k);           % Selecciona la componente k-esima como mascara binaria
    
    % bwarea(ob): Calcula el area total del objeto en pixeles
    if (bwarea(ob) > 100)       % Descarta regiones de ruido de area menor a 100
        [x, y] = find(ob);      % Encuentra las coordenadas de los pixeles del objeto
        cx = mean(x);           % Coordenada X del centroide (media de filas)
        cy = mean(y);           % Coordenada Y del centroide (media de columnas)
        plot(cy, cx, '*r', 'MarkerSize', 15); % Marca el centroide con un asterisco rojo
    end
end
hold off;

%% =========================================================================
% MODULO 7: Extraccion individual de objetos en subimagenes (imcrop)
% =========================================================================

figure, imshow(im2);
im_ob = struct([]);             % Estructura para almacenar subimagenes
im2L = bwlabel(im2obs);         % Etiquetado de regiones conectadas en im2obs
numob = 0;

for k = 1:max(max(im2L))
    ob = (im2L == k);           % Selecciona el objeto k-esimo
    
    if (bwarea(ob) > 100)       % Filtrado por area minima
        numob = numob + 1;
        [x, y] = find(ob);      % Coordenadas del objeto
        
        % Definicion de la caja delimitadora (Bounding Box): [min(Y), min(X), Ancho, Alto]
        p = [min(y), min(x), max(y)-min(y), max(x)-min(x)];
        
        % imcrop(imagen, rectangulo): Recorta la subimagen con el objeto aislado
        im_ob = imcrop(im2, p);
        figure, imshow(im_ob, []); % Muestra la subimagen extraida
    end
end

%% =========================================================================
% MODULO 8: Definicion de Regiones de Interes (ROI) interactivas (imrect)
% =========================================================================

im6 = imread('Connector 01.jpg'); % Carga imagen del conector DB15
figure, imshow(im6);

% imrect: Crea un objeto interactivo de region de interes rectangular sobre la figura
R1 = imrect;                    % ROI para los pines del 1 al 5
R2 = imrect;                    % ROI para los pines del 6 al 9

%% =========================================================================
% MODULO 9: Obtencion de coordenadas y recorte de ROI
% =========================================================================

% getPosition(ROI): Retorna el vector de posicion [X_min, Y_min, Ancho, Alto]
p1 = getPosition(R1);           % Coordenadas de la primera ROI
p2 = getPosition(R2);           % Coordenadas de la segunda ROI

im6_1 = imcrop(im6, p1);        % Subimagen conteniendo unicamente los pines 1 al 5
figure, imshow(im6_1);

% Comparativa de binarizacion entre la imagen completa y la ROI recortada
figure;
subplot(2, 2, 1), imshow(im6);             % Imagen completa original
subplot(2, 2, 2), imshow(im6_1);           % Subimagen ROI recortada
subplot(2, 2, 3), imshow(imbinarize(im6));   % Binarizacion de imagen completa (fallo por fondo)
subplot(2, 2, 4), imshow(imbinarize(im6_1)); % Binarizacion limpia sobre la ROI

%% =========================================================================
% MODULO 10: Mascaras binarias a partir de ROI (createMask)
% =========================================================================

% createMask(ROI): Genera una mascara binaria del mismo tamano de la imagen base
MB1 = createMask(R1);           % Mascara para la region 1
MB2 = createMask(R2);           % Mascara para la region 2
MB3 = (MB1 | MB2);              % Union booleana de ambas mascaras

% Aislamiento de los pines aplicando la mascara sobre la imagen en niveles de gris
im6_2 = double(im6) .* MB3;      % Filtrado espacial puntual
figure, imshow(im6_2, []);      % Visualizacion de los pines aislados

% Binarizacion de la imagen filtrada por mascara
figure, imshow(imbinarize(im6_2 / 255), []);

% Fin del script
