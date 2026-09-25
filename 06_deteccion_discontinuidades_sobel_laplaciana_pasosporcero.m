% =========================================================================
% REPOSITORIO DE VISION POR COMPUTADOR
% Archivo: 06_deteccion_discontinuidades_sobel_laplaciana_pasosporcero.m
% Descripcion: Modulo para la deteccion de discontinuidades y bordes en imagenes.
%              Cubre operadores de primera derivada (Sobel, Prewitt), calculo de 
%              magnitud y direccion del gradiente, binarizacion adaptativa, 
%              operadores de segunda derivada (Laplaciana de 4 y 8 vecinos, LoG), 
%              algoritmo de pasos por cero en espacio y frecuencia, y el uso de 
%              algoritmos avanzados de extraccion de contornos (Canny, Sobel).
% Valor practico: Delimitacion de contornos de piezas, inspeccion de defectos 
%                 superficiales, segmentacion de objetos y preparado de mapas 
%                 estructurales para reconocimiento de patrones.
% =========================================================================

%% Limpieza inicial del entorno de trabajo
clearvars;      % Elimina todas las variables guardadas en el espacio de trabajo (Workspace)
close all;      % Cierra todas las ventanas de figuras que esten abiertas
clc;            % Limpia el texto visible en la ventana de comandos (Command Window)

%% =========================================================================
% MODULO 1: Adquisicion y despliegue de imagenes base para inspeccion
% =========================================================================
% Proposito: Cargar las imagenes de ensayo en memoria y desplegarlas en
% una figura compuesta para evaluar los tipos de contornos y texturas.

% imread: Lee archivos de imagen desde disco y los convierte en matrices numéricas
im1 = imread('disk01.jpg');        % Imagen de disquete (escala de grises)
im2 = imread('Parts00.png');       % Imagen de componentes industriales dispersos
im3 = imread('chocolate 01.jpg');  % Imagen de bombones en bandeja
im4 = imread('gauges 01.tif');     % Imagen de galgas mecanicas de precision

f1 = figure;                      % Inicializa nueva ventana grafica
set(f1, 'Name', 'Modulo 1: Imagenes de Inspeccion Base'); % Asigna titulo a la figura

% subplot(m, n, p): Divide la figura en m filas y n columnas, activando posicion p
subplot(2, 2, 1);
imshow(im1);                      % Renderiza la imagen del disquete
title('Componente: Disquete (im1)'); % Titulo identificador

subplot(2, 2, 2);
imshow(im2);                      % Renderiza la imagen de piezas industriales
title('Componente: Piezas (im2)');   % Titulo identificador

subplot(2, 2, 3);
imshow(im3);                      % Renderiza la imagen de bombones
title('Componente: Bombones (im3)'); % Titulo identificador

subplot(2, 2, 4);
imshow(im4);                      % Renderiza la imagen de galgas
title('Componente: Galgas (im4)');   % Titulo identificador

%% =========================================================================
% MODULO 2: Operadores basados en la primera derivada (Sobel)
% =========================================================================
% Proposito: Estimar las componentes direccionales del gradiente (Gx, Gy),
% computar la magnitud total y determinar la orientacion angular de las aristas.

% fspecial('sobel'): Genera la mascara Sobel horizontal predeterminada
sx = fspecial('sobel')';          % Mascara para gradiente horizontal Gx (3x3)
sy = sx';                         % Mascara para gradiente vertical Gy (3x3)

% double(): Convierte la matriz de enteros a coma flotante para operaciones algebraicas
im1_double = double(im1);          % Conversion de tipo de datos

% conv2(imagen, mascara, 'same'): Realiza la convolucion 2D manteniendo el tamano original
im1x = conv2(im1_double, sx, 'same'); % Gradiente en direccion X (bordes verticales)
im1y = conv2(im1_double, sy, 'same'); % Gradiente en direccion Y (bordes horizontales)

% Calculo de la magnitud del vector gradiente mediante norma euclidea punto a punto
% sqrt(Gx.^2 + Gy.^2): Calcula la tasa de cambio espacial maxima
im1g = sqrt(im1x.^2 + im1y.^2);    % Modulo del gradiente espacial

% atan2(Gy, Gx): Calcula el angulo de orientacion del gradiente en radianes [-pi, pi]
im1_dir = atan2(im1y, im1x);       % Mapa de orientacion angular del gradiente

f2 = figure;                      % Inicializa nueva ventana grafica
set(f2, 'Name', 'Modulo 2: Gradiente Sobel y Magnitud en Disquete');

subplot(2, 2, 1);
imshow(im1, []);                  % Muestra imagen original
title('Imagen Original');

subplot(2, 2, 2);
imshow(abs(im1x), []);            % Muestra componente absoluta del gradiente X
title('Gradiente Horizontal |Gx|');

subplot(2, 2, 3);
imshow(abs(im1y), []);            % Muestra componente absoluta del gradiente Y
title('Gradiente Vertical |Gy|');

subplot(2, 2, 4);
imshow(im1g, []);                 % Muestra la magnitud combinada del gradiente
title('Magnitud del Gradiente (Modulo)');

% Visualizacion de la direccion del gradiente modulada por la presencia de borde
f3 = figure;                      % Inicializa nueva ventana grafica
set(f3, 'Name', 'Modulo 2: Orientacion Angular del Gradiente');

% Normalizacion del mapa de angulos al rango descartando zonas sin borde
mapa_angulos = ((im1_dir + pi) .* (im1g > 55)) / (2 * pi); % Angulo escalado

imshow(mapa_angulos, []);         % Muestra mapa de direcciones coloreado por escala
colormap hsv;                     % Paleta cromatica circular para angulos
colorbar;                         % Barra de escala angular
title('Direccion del Gradiente (Modulada por Magnitud > 55)');

%% =========================================================================
% MODULO 3: Binarizacion del gradiente y sensibilidad a umbrales
% =========================================================================
% Proposito: Evaluar la continuidad de los bordes extraidos y la supresion
% de ruido binarizando el mapa de gradientes con diferentes umbrales.

im2_double = double(im2);          % Conversiion de imagen de piezas a double
im2x = conv2(im2_double, sx, 'same'); % Gradiente X
im2y = conv2(im2_double, sy, 'same'); % Gradiente Y
im2g = sqrt(im2x.^2 + im2y.^2);    % Magnitud del gradiente

% max(matriz(:)): Encuentra el valor maximo absoluto de la matriz
grad_normalizado = im2g / max(im2g(:)); % Escala el gradiente al rango continuo [0.0, 1.0]

% Binarizacion con umbrales crecientes: 0.1, 0.25, 0.5, 0.75, 0.9
im2g_a = grad_normalizado > 0.10;  % Umbral permisivo (conserva mas detalles y ruido)
im2g_b = grad_normalizado > 0.25;  % Umbral moderado
im2g_c = grad_normalizado > 0.50;  % Umbral equilibrado
im2g_d = grad_normalizado > 0.75;  % Umbral restrictivo
im2g_e = grad_normalizado > 0.90;  % Umbral muy restrictivo (solo contornos mas fuertes)

f4 = figure;                      % Inicializa nueva ventana grafica
set(f4, 'Name', 'Modulo 3: Binarizacion del Gradiente con Umbrales Variables');

subplot(2, 3, 1);
imshow(im2);                      % Muestra la imagen original
title('Original');

subplot(2, 3, 2);
imshow(im2g_a);                   % Binarizado al 10%
title('Umbral = 0.10');

subplot(2, 3, 3);
imshow(im2g_b);                   % Binarizado al 25%
title('Umbral = 0.25');

subplot(2, 3, 4);
imshow(im2g_c);                   % Binarizado al 50%
title('Umbral = 0.50');

subplot(2, 3, 5);
imshow(im2g_d);                   % Binarizado al 75%
title('Umbral = 0.75');

subplot(2, 3, 6);
imshow(im2g_e);                   % Binarizado al 90%
title('Umbral = 0.90');

%% =========================================================================
% MODULO 4: Extraccion automatizada de bordes mediante algoritmo edge
% =========================================================================
% Proposito: Aplicar detectores de bordes optimizados con supresion de
% no maximos y binarizacion automatica por histeresis (Canny, Sobel, Prewitt).

% edge(imagen, metodo): Detecta bordes binarios de un pixel de grosor
borde_sobel  = edge(im4, 'sobel');   % Operador Sobel con umbral automatico
borde_prewitt = edge(im4, 'prewitt'); % Operador Prewitt
borde_canny  = edge(im4, 'canny');   % Detector de Canny (optimo en histeresis)

f5 = figure;                      % Inicializa nueva ventana grafica
set(f5, 'Name', 'Modulo 4: Comparativa de Detectores de Bordes (edge)');

subplot(2, 2, 1);
imshow(im4);                      % Muestra imagen de galgas
title('Imagen Original');

subplot(2, 2, 2);
imshow(borde_sobel);              % Bordes por Sobel
title('Detector Sobel');

subplot(2, 2, 3);
imshow(borde_prewitt);            % Bordes por Prewitt
title('Detector Prewitt');

subplot(2, 2, 4);
imshow(borde_canny);              % Bordes por Canny (contornos finos y cerrados)
title('Detector Canny');

% Superposicion cromatica de bordes sobre la imagen original
% Se construye una matriz RGB donde el canal verde resalta las aristas detectadas
im_base = double(im4) / 255;      % Imagen base normalizada
im_bordes_canny = edge(im4, 'canny'); % Mascara binaria de bordes

im_compuesta = zeros(size(im4, 1), size(im4, 2), 3); % Inicializa matriz RGB vacia
im_compuesta(:, :, 1) = im_base .* not(im_bordes_canny);                  % Canal Rojo
im_compuesta(:, :, 2) = im_base .* not(im_bordes_canny) + im_bordes_canny; % Canal Verde (resalta en verde)
im_compuesta(:, :, 3) = im_base .* not(im_bordes_canny);                  % Canal Azul

f6 = figure;                      % Inicializa nueva ventana grafica
set(f6, 'Name', 'Modulo 4: Superposicion de Contornos sobre Imagen Base');
imshow(im_compuesta);             % Muestra la imagen con los bordes superpuestos en verde
title('Bordes de Canny Superpuestos en Verde sobre la Imagen Base');

%% =========================================================================
% MODULO 5: Operadores de segunda derivada (Laplaciana y LoG)
% =========================================================================
% Proposito: Calcular la respuesta isotropica de segunda derivada empleando
% mascaras Laplacianas de 4 y 8 vecinos y la Laplaciana de Gaussiana (LoG).

% Mascara Laplaciana de 4 vecinos (conectividad ortogonal)
L4 = [0 -1 0; -1 4 -1; 0 -1 0];   % Kernel L4 (suma de coeficientes = 0)

% Mascara Laplaciana de 8 vecinos (conectividad ortogonal y diagonal)
L8 = [-1 -1 -1; -1 8 -1; -1 -1 -1]; % Kernel L8

% Mascara LoG (Laplacian of Gaussian) de 11x11 con sigma = 2
% fspecial('log', tamano, sigma): Suaviza previamente para reducir sensibilidad al ruido
L11 = fspecial('log', , 2); % Kernel LoG

% Convolucion espacial con los operadores de segunda derivada
im2_L4 = conv2(im2_double, L4, 'same');  % Filtrado con Laplaciana 4 vecinos
im2_L8 = conv2(im2_double, L8, 'same');  % Filtrado con Laplaciana 8 vecinos
im2_LoG = conv2(im2_double, L11, 'same'); % Filtrado con LoG 11x11

f7 = figure;                      % Inicializa nueva ventana grafica
set(f7, 'Name', 'Modulo 5: Respuestas Laplacianas en el Dominio Espacial');

subplot(2, 2, 1);
imshow(im2);                      % Muestra imagen original
title('Imagen Original');

subplot(2, 2, 2);
imshow(im2_L4, []);               % Muestra respuesta L4
title('Laplaciana 4 Vecinos (L4)');

subplot(2, 2, 3);
imshow(im2_L8, []);               % Muestra respuesta L8
title('Laplaciana 8 Vecinos (L8)');

subplot(2, 2, 4);
imshow(im2_LoG, []);              % Muestra respuesta LoG
title('Laplaciana de Gaussiana (LoG 11x11, sigma=2)');

% Visualizacion 3D de la respuesta LoG sobre la imagen
f8 = figure;                      % Inicializa nueva ventana grafica
set(f8, 'Name', 'Modulo 5: Malla Topografica 3D de la Respuesta LoG');
surf(im2_LoG);                    % Renderiza el relieve 3D de segundas derivadas
colormap jet;                     % Paleta termica
shading interp;                   % Interpolacion suave
title('Superficie 3D de la Filtrada LoG');
xlabel('Columnas (X)');
ylabel('Filas (Y)');
zlabel('Valor de la Segunda Derivada');

%% =========================================================================
% MODULO 6: Deteccion de bordes por pasos por cero (Zero-Crossing)
% =========================================================================
% Proposito: Identificar las transiciones de signo de positivo a negativo
% en la imagen Laplaciana empleando el algoritmo porcero con umbral de amplitud.

umbral_amplitud = 0.001;          % Umbral de tolerancia para evitar falsos bordes por ruido

% Llama a la funcion local porcero para extraer las aristas binarias
im2_L4_pc  = porcero(im2_L4, umbral_amplitud);  % Pasos por cero sobre L4
im2_L8_pc  = porcero(im2_L8, umbral_amplitud);  % Pasos por cero sobre L8
im2_LoG_pc = porcero(im2_LoG, umbral_amplitud); % Pasos por cero sobre LoG

f9 = figure;                      % Inicializa nueva ventana grafica
set(f9, 'Name', 'Modulo 6: Mapas Binarios de Pasos por Cero');

subplot(2, 2, 1);
imshow(im2);                      % Muestra imagen original
title('Imagen Original');

subplot(2, 2, 2);
imshow(im2_L4_pc);                % Bordes por pasos por cero L4
title('Pasos por Cero: Laplaciana L4');

subplot(2, 2, 3);
imshow(im2_L8_pc);                % Bordes por pasos por cero L8
title('Pasos por Cero: Laplaciana L8');

subplot(2, 2, 4);
imshow(im2_LoG_pc);               % Bordes por pasos por cero LoG (contornos cerrados)
title('Pasos por Cero: LoG 11x11');

%% =========================================================================
% MODULO 7: Operador Laplaciano en el dominio frecuencial
% =========================================================================
% Proposito: Computar la segunda derivada directamente en el espacio espectral
% mediante el filtro cuadratico H(u,v) = -4*pi^2*(u^2 + v^2).

[tamx, tamy] = size(im2);          % Dimensiones de la matriz
[uu, vv] = meshgrid(1:tamy, 1:tamx); % Genera rejilla de frecuencias espaciales

% Calculo de la distancia cuadratica al centro espectral
u_centro = uu - tamy / 2;         % Centrado del eje U
v_centro = vv - tamx / 2;         % Centrado del eje V

% Transferencia del filtro Laplaciano frecuencial H = -(2*pi)^2 * (U^2 + V^2)
H_laplace = -((2 * pi)^2 * (u_centro.^2 + v_centro.^2)); % Operador cuadratico espectral

% Transformada de Fourier de la imagen de entrada
F_im2 = fftshift(fft2(double(im2))); % Espectro centrado

% Aplicacion del filtro Laplaciano por producto directo en frecuencia
F_laplace_im2 = F_im2 .* H_laplace;   % Producto espectral

% Transformada inversa de Fourier para retornar al dominio espacial
im2_laplace_freq = real(ifft2(fftshift(F_laplace_im2))); % Respuesta espacio-frecuencial

% Deteccion de pasos por cero sobre el resultado frecuencial
im2_freq_pc = porcero(im2_laplace_freq, 0.00001); % Extrae bordes binarios

f10 = figure;                     % Inicializa nueva ventana grafica
set(f10, 'Name', 'Modulo 7: Deteccion Laplaciana en el Dominio Frecuencial');

subplot(2, 2, 1);
imshow(im2);                      % Muestra imagen original
title('Imagen Original');

subplot(2, 2, 2);
imshow(-H_laplace / max(-H_laplace(:))); % Muestra el filtro espectral parabólico
title('Mascara Laplaciana Frecuencial -H(u,v)');

subplot(2, 2, 3);
imshow(im2_laplace_freq, []);     % Muestra la respuesta en espacio de la filtrada frecuencial
title('Respuesta Laplaciana via IFFT');

subplot(2, 2, 4);
imshow(im2_freq_pc);              % Muestra el mapa binario de pasos por cero
title('Pasos por Cero Frecuenciales');

%% =========================================================================
% FUNCIONES LOCALES / SUBPROGRAMAS DEL MODULO
% =========================================================================

function impc = porcero(iml, u)
    % PORCERO: Detecta los pasos por cero (cambios de signo) en una matriz
    %          Laplaciana evaluando la diferencia entre vecinos contiguos
    %          y verificando que la amplitud supere un umbral u.
    % Entrada:
    %   iml - Matriz de entrada con la respuesta de segunda derivada (double)
    %   u   - Umbral de amplitud minima para validar la presencia de arista
    % Salida:
    %   impc - Matriz binaria (logical) con valor 1 en la ubicacion del borde
    
    if nargin < 2
        u = 0;                     % Asigna umbral nulo por defecto
    end
    
    % Normalizacion del rango de la matriz Laplaciana para estabilidad
    max_val = max(abs(iml(:)));    % Obtiene el pico maximo absoluto
    if max_val > 0
        iml_norm = iml / max_val;  % Escala la respuesta al rango [-1.0, 1.0]
    else
        iml_norm = iml;
    end
    
    [tamx, tamy] = size(iml_norm);  % Obtiene las dimensiones de la imagen
    
    % Extraccion de sub-matrices desplazadas de 1 pixel en las direcciones X e Y
    imt1 = iml_norm(1:tamx-1, 1:tamy-1); % Sub-matriz original (superior izquierda)
    imt2 = iml_norm(2:tamx,   1:tamy-1); % Sub-matriz desplazada 1 fila abajo
    imt3 = iml_norm(1:tamx-1, 2:tamy);   % Sub-matriz desplazada 1 columna a la derecha
    imt4 = iml_norm(2:tamx,   2:tamy);   % Sub-matriz desplazada en diagonal
    
    % Un producto negativo entre vecinos indica un cambio de signo (paso por cero)
    % Se evalua que la magnitud de la transicion sea menor que -u (mayor que la tolerancia)
    condicion_paso = (imt1 .* imt2 < -u) | ...
                     (imt1 .* imt3 < -u) | ...
                     (imt1 .* imt4 < -u);
                 
    % Inicializa la mascara binaria de salida del mismo tamano que la imagen original
    impc = false(tamx, tamy);      % Matriz de ceros de tipo booleano
    impc(1:tamx-1, 1:tamy-1) = condicion_paso; % Asigna el mapa de pasos por cero
    
end % Fin de la funcion porcero

% Fin del script
