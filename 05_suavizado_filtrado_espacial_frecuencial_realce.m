% =========================================================================
% REPOSITORIO DE VISION POR COMPUTADOR
% Archivo: 05_suavizado_filtrado_espacial_frecuencial_realce.m
% Descripcion: Modulo para la atenuacion de ruido y realce de contraste en imagenes.
%              Cubre modelos de ruido (Gaussiano y Sal y Pimienta), filtrado espacial
%              lineal (Media, Gaussiano) y no lineal (Mediana), filtros paso bajo 
%              en el dominio de Fourier (Ideal y Butterworth) y realce de contraste 
%              mediante igualacion de histograma.
% Valor practico: Acondicionamiento de imagen para eliminar artefactos de adquisicion,
%                 restauracion de componentes electronicas y mejora de visibilidad
%                 en sistemas de inspeccion automatizada.
% =========================================================================

%% Limpieza inicial del entorno de trabajo
clearvars;      % Elimina todas las variables guardadas en el espacio de trabajo (Workspace)
close all;      % Cierra todas las ventanas de figuras que esten abiertas
clc;            % Limpia el texto visible en la ventana de comandos (Command Window)

%% =========================================================================
% MODULO 1: Modelos de ruido sinteticos (Gaussiano y Sal y Pimienta)
% =========================================================================
% Proposito: Simular perturbaciones opticas y electronicas sobre imagenes base
% mediante la adicion de ruido con distribucion Gaussiana e impulsiva.

% imread: Carga archivo de imagen a matriz numerica de memoria
im1 = imread('patron0.jpg');       % Imagen patron de contraste continuo
im3 = imread('fuse 02.tif');       % Imagen de componente de fusible

% imnoise(imagen, tipo, parametros): Contamina la imagen con modelos de ruido
% Ruido Gaussiano: variacion continua de brillo con media 0 y varianza 0.001
im2 = imnoise(im1, 'gaussian', 0, 0.001); % Patron contaminado con ruido Gaussiano

% Adicion de ruido a la imagen del fusible
im4 = imnoise(im3, 'gaussian');    % Fusible con ruido Gaussiano por defecto
im5 = imnoise(im3, 'salt & pepper'); % Fusible con ruido impulsivo Sal y Pimienta

f1 = figure;                      % Inicializa nueva ventana grafica
set(f1, 'Name', 'Modulo 1: Ruido Gaussiano en Patron Base');

% subplot(m, n, p): Divide la ventana en m filas y n columnas, activando posicion p
subplot(2, 2, 1);
imshow(im1);                      % Muestra imagen limpia original
title('Patron Original Limpio');  % Titulo del cuadrante

subplot(2, 2, 2);
imhist(im1);                      % Muestra histograma de niveles de gris
title('Histograma Patron Limpio');

subplot(2, 2, 3);
imshow(im2);                      % Muestra imagen contaminada
title('Patron con Ruido Gaussiano (var = 0.001)');

subplot(2, 2, 4);
imhist(im2);                      % Muestra dispersion del histograma por ruido
title('Histograma con Ruido Gaussiano');

f2 = figure;                      % Inicializa nueva ventana grafica
set(f2, 'Name', 'Modulo 2: Comparativa de Modelos de Ruido sobre Fusible');

subplot(1, 3, 1);
imshow(im3);                      % Fusible original
title('Fusible Original');

subplot(1, 3, 2);
imshow(im4);                      % Ruido Gaussiano
title('Contaminacion: Ruido Gaussiano');

subplot(1, 3, 3);
imshow(im5);                      % Ruido Sal y Pimienta
title('Contaminacion: Ruido Sal y Pimienta');

%% =========================================================================
% MODULO 2: Filtrado espacial lineal mediante mascaras de convolucion
% =========================================================================
% Proposito: Evaluar la respuesta de filtros de promediado aritmetico y filtro
% Gaussiano continuo para atenuar variaciones de alta frecuencia.

% fspecial(tipo, tamano, sigma): Diseña mascaras de filtrado espacial
% Genera kernel Gaussiano 11x11 con desviacion tipica sigma = 2
m_gauss = fspecial('gaussian',, 2); % Kernel Gaussiano de 11x11

f3 = figure;                      % Inicializa nueva ventana grafica
set(f3, 'Name', 'Modulo 2: Perfil 3D de Kernel Gaussiano');

% surf(Z): Visualiza matriz de pesos como una superficie tridimensional
surf(m_gauss);                    % Dibuja la campana de Gauss en 3D
colormap jet;                     % Aplica mapa de color termico
shading interp;                   % Interpolado visual suave
title('Superficie 3D de Kernel Gaussiano (11x11, sigma=2)');
xlabel('Eje X (Columnas)');
ylabel('Eje Y (Filas)');
zlabel('Ponderacion W');

% conv2(imagen, mascara, 'same'): Realiza la convolucion 2D manteniendo dimensiones
% Filtrado por media aritmetica 3x3 y 7x7 sobre ambas imagenes contaminadas
im6 = conv2(im4, ones(3)/9, 'same');   % Media 3x3 sobre Gaussiano
im7 = conv2(im5, ones(3)/9, 'same');   % Media 3x3 sobre Sal y Pimienta
im8 = conv2(im4, ones(7)/49, 'same');  % Media 7x7 sobre Gaussiano
im9 = conv2(im5, ones(7)/49, 'same');  % Media 7x7 sobre Sal y Pimienta

f4 = figure;                      % Inicializa nueva ventana grafica
set(f4, 'Name', 'Modulo 2: Filtrado Espacial por Media Aritmetica');

subplot(2, 3, 1);
imshow(im4);
title('Original: Ruido Gaussiano');

subplot(2, 3, 2);
imshow(im6 / 255);                % Normalizacion dividiendo por 255 para correcto escalado
title('Gaussiano + Media 3x3');

subplot(2, 3, 3);
imshow(im8 / 255);
title('Gaussiano + Media 7x7');

subplot(2, 3, 4);
imshow(im5);
title('Original: Sal y Pimienta');

subplot(2, 3, 5);
imshow(im7 / 255);
title('Sal y Pimienta + Media 3x3');

subplot(2, 3, 6);
imshow(im9 / 255);
title('Sal y Pimienta + Media 7x7');

% Comparativa entre Filtro Gaussiano y Filtro de Media Aritmetica de 11x11
im10 = conv2(im4, m_gauss, 'same');      % Convolucion con kernel Gaussiano 11x11
im11 = conv2(im4, ones(11)/121, 'same'); % Convolucion con media aritmetica 11x11

f5 = figure;                      % Inicializa nueva ventana grafica
set(f5, 'Name', 'Modulo 2: Comparativa Filtro Gaussiano vs Media Aritmetica');

subplot(1, 3, 1);
imshow(im4);
title('Imagen con Ruido Gaussiano');

subplot(1, 3, 2);
imshow(im10 / 255);
title('Filtrado Gaussiano (11x11)');

subplot(1, 3, 3);
imshow(im11 / 255);
title('Filtrado Media Aritmetica (11x11)');

%% =========================================================================
% MODULO 3: Filtrado espacial no lineal mediante mediana
% =========================================================================
% Proposito: Eliminar ruido impulsor (Sal y Pimienta) preservando bordes nítidos
% mediante el operador de estadistica de orden medfilt2.

% medfilt2(imagen): Filtro de mediana en entorno predeterminado de 3x3
im12 = medfilt2(im4);             % Mediana sobre imagen con ruido Gaussiano
im13 = medfilt2(im5);             % Mediana sobre imagen con ruido Sal y Pimienta

f6 = figure;                      % Inicializa nueva ventana grafica
set(f6, 'Name', 'Modulo 3: Respuesta del Filtro de Mediana');

subplot(2, 2, 1);
imshow(im4);
title('Original: Ruido Gaussiano');

subplot(2, 2, 2);
imshow(im12);
title('Ruido Gaussiano + Mediana 3x3');

subplot(2, 2, 3);
imshow(im5);
title('Original: Sal y Pimienta');

subplot(2, 2, 4);
imshow(im13);                     % Muestra eliminacion completa de impulsos negros/blancos
title('Sal y Pimienta + Mediana 3x3');

%% =========================================================================
% MODULO 4: Diseno de filtros paso bajo en el dominio frecuencial (ILPF y BLPF)
% =========================================================================
% Proposito: Construir las transferencias espectrales del Filtro Paso Bajo Ideal (ILPF)
% y del Filtro Paso Bajo Butterworth (BLPF) centrados en el plano frecuencial.

im14 = imread('fuse 23.tif');      % Carga imagen con interferencia de alta frecuencia

% fft2(): Transformada Rapida de Fourier bidimensional
F_im14 = fft2(im14);              % Matriz de numeros complejos en frecuencia

f7 = figure;                      % Inicializa nueva ventana grafica
set(f7, 'Name', 'Modulo 4: Espectro Frecuencial de Fusible');

subplot(2, 1, 1);
imshow(im14);
title('Imagen Fusible con Ruido Frecuencial');

subplot(2, 1, 2);
% fftshift(): Centra la componente continua (frecuencia cero) en el centro de la imagen
% 20*log10(1 + abs(...)): Escala logaritmica para compresion del rango dinamico del espectro
imshow(20 * log10(1 + abs(fftshift(F_im14))) / 255);
title('Espectro de Magnitud Centrado en Frecuencia');

% Generacion de la rejilla de distancias euclideas al centro espectral
[tamx, tamy] = size(im14);         % Dimensiones de la imagen
[xx, yy] = meshgrid(1:tamy, 1:tamx); % Genera matriz de coordenadas X e Y
distancia_centro = sqrt((xx - tamy/2).^2 + (yy - tamx/2).^2); % Distancia radial r = sqrt(X^2 + Y^2)

% Construccion del Filtro Paso Bajo Ideal (ILPF) con frecuencia de corte d0 = 100
d0_ideal = 100;
ILPF = double(distancia_centro < d0_ideal); % Mascara circular binaria (1 en paso, 0 en rechazo)

% Construccion del Filtro Paso Bajo Butterworth (BLPF) con d0 = 50 y orden n = 1
d0_butter = 50;
orden_n = 1;
BLPF = 1 ./ (1 + (distancia_centro / d0_butter).^(2 * orden_n)); % Transferencia continua suave

f8 = figure;                      % Inicializa nueva ventana grafica
set(f8, 'Name', 'Modulo 4: Geometria de Filtros Frecuenciales Paso Bajo');

subplot(2, 2, 1);
imshow(ILPF);                     % Muestra imagen 2D del filtro ideal
title('Filtro Paso Bajo Ideal (d0 = 100)');

subplot(2, 2, 2);
imshow(BLPF);                     % Muestra imagen 2D del filtro Butterworth
title('Filtro Butterworth (d0 = 50, n = 1)');

subplot(2, 2, 3);
surf(double(ILPF));               % Malla 3D del perfil del filtro ideal
shading interp;
title('Perfil 3D: Filtro Ideal');

subplot(2, 2, 4);
surf(double(BLPF));               % Malla 3D del perfil continuo de Butterworth
shading interp;
title('Perfil 3D: Filtro Butterworth');

%% =========================================================================
% MODULO 5: Filtrado espectral en el dominio de Fourier
% =========================================================================
% Proposito: Aplicar el producto de atenuacion punto a punto en frecuencia
% y retornar al dominio espacial mediante la Transformada Inversa (IFFT).

% Centrado de la transformada para atenuacion en origen
F_centrada = fftshift(fft2(im14)); % Espectro complejo centrado

% Producto punto a punto con las mascaras frecuenciales
F_filtrada_ILPF = F_centrada .* ILPF; % Atenuacion espectral por filtro ideal
F_filtrada_BLPF = F_centrada .* BLPF; % Atenuacion espectral por Butterworth

% ifft2(): Transformada Rapida de Fourier Inversa bidimensional
% real(): Descarta posibles residuos imaginarios causados por imprecision numerica
im15 = real(ifft2(fftshift(F_filtrada_ILPF))); % Imagen filtrada por ILPF
im16 = real(ifft2(fftshift(F_filtrada_BLPF))); % Imagen filtrada por BLPF

f9 = figure;                      % Inicializa nueva ventana grafica
set(f9, 'Name', 'Modulo 5: Resultados de Filtrado Frecuencial');

subplot(2, 3, 1);
imshow(im14);
title('Original con Ruido');

subplot(2, 3, 2);
imshow(im15 / 255);               % Muestra atenuacion de ruido con efecto ringing
title('Filtrado Paso Bajo Ideal');

subplot(2, 3, 3);
imshow(im16 / 255);               % Muestra atenuacion suave sin artefactos
title('Filtrado Butterworth');

subplot(2, 3, 4);
imshow(20 * log10(1 + abs(fftshift(fft2(im14)))) / 255);
title('Espectro Original');

subplot(2, 3, 5);
imshow(20 * log10(1 + abs(fftshift(fft2(im15)))) / 255);
title('Espectro Filtrado Ideal');

subplot(2, 3, 6);
imshow(20 * log10(1 + abs(fftshift(fft2(im16)))) / 255);
title('Espectro Filtrado Butterworth');

%% =========================================================================
% MODULO 6: Realce de contraste mediante igualacion de histograma
% =========================================================================
% Proposito: Redistribuir los niveles de intensidad para maximizar la entropia
% y expandir el rango dinamico de la imagen usando la funcion acumulada (CDF).

% imhist(imagen): Obtiene vector de frecuencias de 256 elementos
h_base = imhist(im14);            % Conteo discreto por nivel de gris

% Normalizacion para obtener la Funcion de Densidad de Probabilidad (PDF)
% numel(): Cuenta la cantidad total de pixeles en la matriz
h_probabilidad = h_base / numel(im14); % Probabilidad de cada nivel

% cumsum(): Suma acumulativa para calcular la Funcion de Distribucion Acumulada (CDF)
suma_acumulada = cumsum(h_probabilidad); % Vector CDF normalizado de 0 a 1

% uint8(): Escala la CDF al rango dinmico de 8 bits (0-255) para construir la LUT
lut_igualacion = uint8(suma_acumulada * 255); % Tabla de mapeo de igualacion

% intlut(imagen, lut): Aplica la transformacion de contraste por tabla
im14_igualada_manual = intlut(im14, lut_igualacion); % Imagen con contraste amplificado

% histeq(): Funcion nativa equivalente para igualacion automatica de histograma
im14_igualada_nativa = histeq(im14);  % Resultado nativo

f10 = figure;                     % Inicializa nueva ventana grafica
set(f10, 'Name', 'Modulo 6: Realce de Contraste e Igualacion de Histograma');

subplot(2, 3, 1);
imshow(im14);
title('Imagen Original (Bajo Contraste)');

subplot(2, 3, 2);
imshow(im14_igualada_manual);
title('Igualacion Manual (via CDF/LUT)');

subplot(2, 3, 3);
imshow(im14_igualada_nativa);
title('Igualacion Nativa (histeq)');

subplot(2, 3, 4);
imhist(im14);                     % Histograma concentrado en rango estrecho
title('Histograma Original Concentrado');

subplot(2, 3, 5);
imhist(im14_igualada_manual);     % Histograma expandido uniformemente
title('Histograma Igualado (Distribucion Uniforme)');

subplot(2, 3, 6);
plot(lut_igualacion, 'r', 'LineWidth', 1.5); % Muestra la funcion de transferencia CDF
grid on;
title('Funcion de Transferencia Acumulada (CDF)');
xlabel('Nivel Entrada');
ylabel('Nivel Salida');

% Fin del script
