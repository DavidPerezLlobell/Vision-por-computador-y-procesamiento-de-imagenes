% =========================================================================
% REPOSITORIO DE VISION POR COMPUTADOR
% Archivo: 03_calibracion_camara_proyeccion_medicion_3d.m
% Descripcion: Modulo para la estimacion de parametros intrinsicos y extrinsecos 
%              de camara, construccion de matriz de proyeccion perspectiva, 
%              correccion de distorsion radial en lentes gran angular (GoPro) 
%              y medicion metrica de distancias reales sobre plano 3D.
% Valor practico: Calibracion geometrica de sensores opticos, rectificacion 
%                 de imagen para navegacion/inspeccion y reconstruccion 3D.
% =========================================================================

%% Limpieza inicial del entorno de trabajo
clearvars;      % Elimina todas las variables guardadas en el espacio de trabajo (Workspace)
close all;      % Cierra todas las ventanas de figuras que esten abiertas
clc;            % Limpia el texto visible en la ventana de comandos (Command Window)

%% =========================================================================
% MODULO 1: Inspeccion de parametros intrinsicos y extrinsecos de calibracion
% =========================================================================
% Proposito: Extraer la matriz de calibracion K, evaluar el punto principal 
% respecto al centro del sensor y obtener la pose espacial (R, t) de la camara.

% Se asume la existencia de la variable 'pRealSense' (objeto cameraParameters)
% generada tras procesar el patron de damero de 30x30 mm.
if ~exist('pRealSense', 'var')
    % Generacion de datos sinteticos representativos si no se ha exportado desde la App
    disp('Nota: Estructura pRealSense no detectada en Workspace. Creando matriz de prueba...');
    K_base = [600.9523, 0, 0; 0, 598.5395, 0; 323.3885, 240.1287, 1];
    pRealSense.K = K_base;
    pRealSense.PatternExtrinsics(3).R = eye(3);
    pRealSense.PatternExtrinsics(3).Translation = [-138.08, -19.07, 427.62];
end

% Matriz de parametros intrinsicos K (se requiere la traspuesta de la propiedad K del objeto)
K = pRealSense.K';                % Matriz 3x3 de proyeccion perspectiva y escala

% Coordenadas del punto principal (centro optico estimado) en pixeles
punto_principal = K(3, 1:2);       % Extrae [cx, cy]

% Resolucion nativa del sensor de la camara (640x480)
resolucion_imagen = ;    % [ancho, alto] en pixeles
centro_sensor = resolucion_imagen / 2; % Centro geometrico 

% Calculo de la desviacion entre el centro optico y el centro fisico del sensor
desviacion_centro = centro_sensor - punto_principal; % Error de descentrado en pixeles

disp('Parametros Intrinsicos K (3x3):');
disp(K);
disp(['Centro optico estimado (cx, cy): ', num2str(punto_principal)]);
disp(['Desviacion respecto al centro del sensor: ', num2str(desviacion_centro), ' pixeles']);

% Extraccion de parametros extrinsecos para la posicion 3 de la camara
% R: Matriz de rotacion 3x3 (requiere traspuesta), t: Vector de traslacion 1x3
R3 = pRealSense.PatternExtrinsics(3).R';          % Matriz de rotacion 3x3
t3 = pRealSense.PatternExtrinsics(3).Translation;  % Vector de traslacion [tx, ty, tz]

disp('Matriz de Rotacion R (Posicion 3):');
disp(R3);
disp('Vector de Traslacion t (Posicion 3):');
disp(t3);

%% =========================================================================
% MODULO 2: Modelo de proyeccion perspectiva y superposicion de rejilla 3D
% =========================================================================
% Proposito: Proyectar vertices del patron 3D al plano imagen 2D mediante
% la matriz de camara M = [R; t] * K y renderizar la region delimitada.

% Construccion de la matriz de transformacion ext-int M (4x3)
% M conecta coordenadas 3D del mundo real (X, Y, Z, 1) con coordenadas homogeneas 2D
M3 = [R3; t3] * K;                % Matriz de proyeccion de dimension 4x3

% Definicion de coordenadas 3D de los 4 extremos de la rejilla de calibracion (mm)
% Formato de coordenadas aumentadas homogeneas: [X, Y, Z, 1]
p_3d = [-30, -30, 0, 1; ...
        -30, 150, 0, 1; ...
        240, 150, 0, 1; ...
        240, -30, 0, 1];          % Matriz 4x4 con los limites del damero

% Proyeccion al espacio homogeneo del plano imagen
p_homogeneas = p_3d * M3;          % Multiplicacion matricial (resultado 4x3)

% Normalizacion homogenea (conversion a coordenadas cartesianas de imagen en pixeles)
% Se divide cada fila entre su coordenada de escala w (tercera columna)
puntos_2d = p_homogeneas ./ p_homogeneas(:, 3); % Matriz 4x3 [u, v, 1]

% Visualizacion de la proyeccion sobre la imagen de calibracion
f2 = figure;                      % Inicializa nueva ventana grafica
set(f2, 'Name', 'Modulo 2: Proyeccion de Rejilla 3D sobre Imagen');

% Carga de la imagen correspondiente a la posicion 3
ruta_im3 = fullfile('RealSense', 'realsense03.png');
if exist(ruta_im3, 'file')
    im_rs3 = imread(ruta_im3);    % Lee la imagen desde disco
else
    im_rs3 = zeros(480, 640, 3, 'uint8'); % Imagen en negro de respaldo
end

imshow(im_rs3);                   % Renderiza la imagen base
hold on;                          % Retiene la figura para superposicion

% fill(X, Y, color, 'FaceAlpha', transparencia): Dibuja un poligono relleno
fill(puntos_2d(:, 1), puntos_2d(:, 2), 'r', 'FaceAlpha', 0.5); % Poligono rojo al 50% de transparencia
title('Rejilla 3D proyectada mediante Matriz de Camara M (4x3)');
hold off;

%% =========================================================================
% MODULO 3: Rectificacion de distorsion radial en lentes gran angular
% =========================================================================
% Proposito: Eliminar la distorsion tipo barril (ojo de pez) producida por
% lentes de gran campo de vision (GoPro) mediante coeficientes radiales.

if ~exist('pGoPro', 'var')
    % Coeficientes de prueba si no existe la calibracion previa
    pGoPro.RadialDistortion = [-0.2549, 0.0689];
end

% Coeficientes de distorsion radial k1, k2
coef_distorsion = pGoPro.RadialDistortion; % Vector con los coeficientes radiales
disp('Coeficientes de distorsion radial (k1, k2):');
disp(coef_distorsion);

% Carga de imagenes afectadas por distorsion
ruta_gp1 = fullfile('GoPro', 'gopro01.jpg');
ruta_gp2 = fullfile('GoPro', 'gopro05.jpg');

if exist(ruta_gp1, 'file') && exist(ruta_gp2, 'file')
    im_gp1 = imread(ruta_gp1);    % Imagen 1 original con distorsion
    im_gp2 = imread(ruta_gp2);    % Imagen 2 original con distorsion
    
    % undistortImage(): Elimina la distorsion geometrica aplicando el modelo del sensor
    im_gp1_corr = undistortImage(im_gp1, pGoPro); % Imagen 1 rectificada
    im_gp2_corr = undistortImage(im_gp2, pGoPro); % Imagen 2 rectificada
    
    f3 = figure;                  % Inicializa ventana grafica
    set(f3, 'Name', 'Modulo 3: Comparativa de Rectificacion de Distorsion');
    
    subplot(2, 2, 1);
    imshow(im_gp1);
    title('Imagen 01 Original (Con distorsion)');
    
    subplot(2, 2, 2);
    imshow(im_gp1_corr);
    title('Imagen 01 Corregida (Sin distorsion)');
    
    subplot(2, 2, 3);
    imshow(im_gp2);
    title('Imagen 05 Original (Con distorsion)');
    
    subplot(2, 2, 4);
    imshow(im_gp2_corr);
    title('Imagen 05 Corregida (Sin distorsion)');
end

%% =========================================================================
% MODULO 4: Estimacion de distancias metricas reales sobre plano 3D
% =========================================================================
% Proposito: Seleccionar dos puntos interactivamente sobre la imagen y calcular
% la distancia euclidea real en centimetros utilizando la inversa de proyeccion.

f4 = figure;                      % Inicializa ventana grafica
set(f4, 'Name', 'Modulo 4: Medicion Metrica de Distancias en Centimetros');

ruta_im20 = fullfile('RealSense', 'realsense20.png');
if exist(ruta_im20, 'file')
    im_rs20 = imread(ruta_im20);
else
    im_rs20 = zeros(480, 640, 3, 'uint8');
end

imshow(im_rs20);                  % Muestra la imagen para la toma de muestras
title('Seleccione 2 puntos sobre la superficie para medir la distancia real');
hold on;

% Captura interactiva de dos puntos mediante clics del raton
[x_med, y_med] = ginput(2);        % Devuelve coordenadas (X, Y) en pixeles
puntos_2d_seleccionados = [x_med, y_med]; % Matriz 2x2 de puntos en imagen

% Trazado de la linea de medicion entre los puntos seleccionados
plot(puntos_2d_seleccionados(:, 1), puntos_2d_seleccionados(:, 2), 'g-', 'LineWidth', 2);

% img2world2d(): Transforma puntos 2D de imagen a coordenadas 3D del mundo real (mm) en el plano Z=0
if exist('pRealSense', 'var') && isfield(pRealSense, 'PatternExtrinsics')
    % Extraccion de la pose de la camara para la posicion correspondiente
    pose_camara = pRealSense.PatternExtrinsics(3);
    intrinsicos_camara = pRealSense.Intrinsics;
    
    % Transformacion inversa de perspectiva a coordenadas metricas (mm)
    puntos_3d_real = img2world2d(puntos_2d_seleccionados, pose_camara, intrinsicos_camara);
    
    % Calculo de la distancia euclidea espacial: sqrt((X1-X2)^2 + (Y1-Y2)^2)
    distancia_mm = norm(puntos_3d_real(1, :) - puntos_3d_real(2, :)); % Distancia en mm
    distancia_cm = distancia_mm / 10; % Conversion a centimetros
    
    % Calculo del punto medio para ubicar la etiqueta de texto explicativa
    pos_texto_x = mean(puntos_2d_seleccionados(:, 1));
    pos_texto_y = mean(puntos_2d_seleccionados(:, 2));
    
    % Despliegue de la medida estimada sobre la interfaz grafica
    cadena_distancia = ['Distancia real = ', num2str(distancia_cm, '%.2f'), ' cm'];
    text(pos_texto_x, pos_texto_y, cadena_distancia, 'Color', 'y', 'FontSize', 12, 'FontWeight', 'bold');
    
    disp(['Distancia metrica estimada entre puntos: ', num2str(distancia_cm, '%.2f'), ' cm']);
end

hold off;

% Fin del script
