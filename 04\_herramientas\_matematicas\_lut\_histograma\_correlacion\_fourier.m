% =========================================================================
% REPOSITORIO DE VISION POR COMPUTADOR
% Archivo: 04_herramientas_matematicas_lut_histograma_correlacion_fourier.m
% Descripcion: Modulo para el procesamiento matematico de imagenes digitales.
%              Cubre transformaciones de intensidad mediante tablas LUT,
%              analisis y normalizacion de histogramas, filtrado espacial
%              por convolucion, deteccion de patrones mediante correlacion
%              cruzada normalizada y analisis frecuencial por Transformada de Fourier.
% Valor practico: Algoritmos fundamentales para realce de contraste, filtrado
%                 de ruido, localizacion automatica de componentes (pattern matching)
%                 y procesamiento espectral en inspeccion industrial.
% =========================================================================

%% Limpieza inicial del entorno de trabajo
clearvars;      % Elimina todas las variables guardadas en el espacio de trabajo (Workspace)
close all;      % Cierra todas las ventanas de figuras que esten abiertas
clc;            % Limpia el texto visible en la ventana de comandos (Command Window)

%% =========================================================================
% MODULO 1: Adquisicion y despliegue de imagenes base para analisis
% =========================================================================
% Proposito: Cargar las imagenes de prueba en memoria y mostrarlas en una
% figura compuesta para inspeccion inicial de contraste y estructura.

% imread: Carga archivos de imagen desde disco a matrices numéricas
im1 = imread('Gauges 01.tif');    % Imagen de piezas mecanicas (escala de grises)
im2 = imread('Cables14.jpg');     % Imagen de cables de colores (RGB)
im3 = imread('Pins-00.bmp');      % Imagen de pines integrados (escala de grises)
im4 = imread('Connector 01.jpg'); % Imagen de conector DB15 (escala de grises)

f1 = figure;                      % Inicializa nueva ventana grafica
set(f1, 'Name', 'Modulo 1: Imagenes de Inspeccion Base'); % Asigna titulo a la ventana

% subplot(m, n, p): Divide la ventana en m filas y n columnas, activando la posicion p
subplot(2, 2, 1);                 % Posicion superior izquierda
imshow(im1);                      % Muestra matriz como imagen
title('Componente: Gauges');      % Titulo del cuadrante

subplot(2, 2, 2);                 % Posicion superior derecha
imshow(im2);                      % Muestra imagen RGB
title('Componente: Cables');      % Titulo del cuadrante

subplot(2, 2, 3);                 % Posicion inferior izquierda
imshow(im3);                      % Muestra imagen de pines
title('Componente: Pins');       % Titulo del cuadrante

subplot(2, 2, 4);                 % Posicion inferior derecha
imshow(im4);                      % Muestra imagen de conector
title('Componente: Conector');    % Titulo del cuadrante

%% =========================================================================
% MODULO 2: Transformaciones de intensidad mediante Look-Up Tables (LUT)
% =========================================================================
% Proposito: Construir vectores de mapeo no lineal (LUT) para inversion
% de contraste y umbralizacion por tramos, aplicando intlut.

% Construccion de vectores LUT de 256 elementos (rango 0 a 255)
% uint8(): Garantiza tipo de dato entero sin signo de 8 bits requerido por intlut
lutR = uint8(255:-1:0);           % Vector de rampa invertida (negativo de imagen)

lutE1 = uint8(zeros(256, 1));     % Inicializa vector en cero
lutE1(100:end) = 255;             % Escalon: asigna 255 a niveles de gris >= 100

lutE2 = uint8(zeros(256, 1));     % Inicializa vector en cero
lutE2(175:end) = 255;             % Escalon: asigna 255 a niveles de gris >= 175

% Visualizacion de las curvas de transformacion LUT
f2 = figure;                      % Inicializa ventana grafica
set(f2, 'Name', 'Modulo 2: Curvas de Transformacion LUT');

% plot(X, Y): Dibuja funciones continuas o vectores discretos
plot(0:255, lutR, 'r', 'LineWidth', 1.5); % Curva rampa invertida en rojo
hold on;                          % Retiene la figura para superponer graficas
plot(0:255, lutE1, 'g', 'LineWidth', 1.5); % Curva escalon 100 en verde
plot(0:255, lutE2, 'b', 'LineWidth', 1.5); % Curva escalon 175 en azul
grid on;                          % Muestra rejilla analitica
axis([0, 255, -10, 265]);         % Define limites de los ejes [Xmin Xmax Ymin Ymax]
title('Funciones de Mapeo de Intensidad (LUT)');
xlabel('Nivel de Gris de Entrada');
ylabel('Nivel de Gris de Salida');
legend('Rampa Invertida', 'Escalon 100', 'Escalon 175', 'Location', 'northwest');
hold off;

% Aplicacion de LUTs sobre la imagen del conector (im4)
% intlut(imagen, vector_lut): Sustituye cada pixel segun la posicion del vector
im4_lutR  = intlut(im4, lutR);    % Aplica negativo
im4_lutE1 = intlut(im4, lutE1);   % Aplica escalon 100
im4_lutE2 = intlut(im4, lutE2);   % Aplica escalon 175

f3 = figure;                      % Inicializa ventana grafica
set(f3, 'Name', 'Modulo 2: Resultados de Mapeo LUT sobre Conector');

subplot(2, 2, 1);
imshow(im4);                      % Imagen original
title('Original');

subplot(2, 2, 2);
imshow(im4_lutR);                 % Resultado rampa invertida
title('LUT: Rampa Invertida');

subplot(2, 2, 3);
imshow(im4_lutE1);                % Resultado escalon 100
title('LUT: Escalon 100');

subplot(2, 2, 4);
imshow(im4_lutE2);                % Resultado escalon 175
title('LUT: Escalon 175');

%% =========================================================================
% MODULO 3: Analisis estadistico de histogramas e histogramas normalizados
% =========================================================================
% Proposito: Evaluar la distribucion de luminancia mediante imhist, representar
% diagramas de barras/lineas y computar histogramas de color en espacio HSV.

f4 = figure;                      % Inicializa ventana grafica
set(f4, 'Name', 'Modulo 3: Analisis de Histograma');

% imhist(imagen): Calcula el conteo de pixeles para cada nivel de gris (0-255)
subplot(2, 2, 1);
imshow(im4);                      % Muestra imagen original
title('Imagen Conector');

subplot(2, 2, 2);
imhist(im4);                      % Grafica directamente el histograma por defecto
title('Histograma Directo (imhist)');

% Asignacion del histograma a variable discreta
h_im4 = imhist(im4);              % Vector columna de 256 elementos

subplot(2, 2, 3);
plot(h_im4);                      % Representacion mediante linea continua
grid on;
title('Perfil de Histograma (plot)');
xlabel('Nivel de Gris');
ylabel('Frecuencia');

subplot(2, 2, 4);
bar(h_im4);                       % Representacion mediante diagrama de barras
grid on;
title('Diagrama de Barras (bar)');
xlabel('Nivel de Gris');

% Calculo de histograma normalizado (Funcion de Densidad de Probabilidad)
% numel(): Retorna el numero total de elementos/pixeles en la matriz
h_norm_im3 = imhist(im3) / numel(im3); % Divide conteo entre total de pixeles

f5 = figure;                      % Inicializa ventana grafica
set(f5, 'Name', 'Modulo 3: Histograma Normalizado de Pines');

subplot(2, 1, 1);
imshow(im3);
title('Imagen de Pines');

subplot(2, 1, 2);
bar(h_norm_im3);                  % Grafica histograma normalizado
grid on;
title('Histograma Normalizado (Suma de intensidades = 1)');
xlabel('Nivel de Gris Normalizado');
ylabel('Probabilidad');

% Verificacion matematica de normalizacion (suma de probabilidades debe ser 1)
suma_probabilidades = sum(h_norm_im3); % Sumatorio de todos los bins
disp(['Verificacion de Histograma Normalizado - Suma total: ', num2str(suma_probabilidades)]);

% Histograma en espacio HSV filtrando pixeles de baja saturacion (cables)
im2_hsv = rgb2hsv(im2);           % Convertir imagen de cables a HSV
canal_H = im2_hsv(:, :, 1);       % Extrae matriz de Matiz (Hue)
canal_S = im2_hsv(:, :, 2);       % Extrae matriz de Saturacion

% Mascara booleana para ignorar tonos neutros (Saturacion <= 0.1)
matiz_filtrado = (canal_H .* (canal_S > 0.1)) * 255; % Escala matiz a 0-255

f6 = figure;                      % Inicializa ventana grafica
set(f6, 'Name', 'Modulo 3: Histograma Cromatico HSV de Cables');

% hsv(256): Mapa de colores HSV para colorear los bins del histograma
imhist(matiz_filtrado, hsv(256)); % Muestra histograma de matices coloreado
axis();          % Ajusta limites visibles
grid on;
title('Distribucion de Matiz (Hue) para Cables de Colores');

%% =========================================================================
% MODULO 4: Suavizado espacial mediante convolucion bidimensional
% =========================================================================
% Proposito: Disminuir el ruido y atenuar altas frecuencias espaciales
% mediante promediado de vecindad con mascaras de convolucion conv2.

% Definicion de mascaras de promediado de diferentes dimensiones (kernel)
% ones(N, N) / (N*N): Genera matriz unitaria normalizada para mantener la energia
m3  = ones(3, 3) / 9;             % Mascara de promediado 3x3
m9  = ones(9, 9) / 81;            % Mascara de promediado 9x9
m17 = ones(17, 17) / 289;         % Mascara de promediado 17x17

% conv2(imagen, mascara, 'same'): Realiza convolucion 2D manteniendo el tamano original
im4_smooth3  = conv2(im4, m3, 'same');  % Filtrado con kernel 3x3
im4_smooth9  = conv2(im4, m9, 'same');  % Filtrado con kernel 9x9
im4_smooth17 = conv2(im4, m17, 'same'); % Filtrado con kernel 17x17

f7 = figure;                      % Inicializa ventana grafica
set(f7, 'Name', 'Modulo 4: Filtrado Espacial de Promediado');

% imshow(imagen, []): Escalado automatico del rango dinamico de visualizacion
subplot(2, 2, 1);
imshow(im4, []);
title('Original');

subplot(2, 2, 2);
imshow(im4_smooth3, []);
title('Filtro Media 3x3');

subplot(2, 2, 3);
imshow(im4_smooth9, []);
title('Filtro Media 9x9');

subplot(2, 2, 4);
imshow(im4_smooth17, []);
title('Filtro Media 17x17');

% Inspeccion topografica 3D del efecto de desenfoque/suavizado
f8 = figure;                      % Inicializa ventana grafica
set(f8, 'Name', 'Modulo 4: Topografia 3D de Imagen Suavizada (17x17)');

surf(im4_smooth17);               % Malla de superficie 3D de intensidades
colormap gray;                    % Escala de grises
shading interp;                   % Interpolacion suave de parches
title('Superficie 3D tras Convolucion con Kernel 17x17');
xlabel('Columnas (X)');
ylabel('Filas (Y)');
zlabel('Intensidad Promediada');

%% =========================================================================
% MODULO 5: Deteccion de patrones por Correlacion Cruzada Normalizada
% =========================================================================
% Proposito: Localizar regiones y elementos especificos (pines y orificios)
% buscando la máxima semejanza estructural mediante normxcorr2.

% Extraccion manual de sub-imagen plantilla (patron de pin)
% im4(filas, columnas): Recorte matricial de la region de interes
plantilla_pin = im4(170:225, 105:160); % Selecciona la region de un solo pin

% normxcorr2(plantilla, imagen): Calcula la superficie de correlacion cruzada normalizada.
% Produce valores en el rango [-1.0, 1.0], donde 1.0 es coincidencia perfecta.
matriz_correlacion = normxcorr2(plantilla_pin, im4); % Mapa de correlacion

% Umbralizacion de picos de correlacion para deteccion de coincidencias
umbral_coincidencia = 0.6;        % Nivel minimo de semejanza
[filas_pico, cols_pico] = find(matriz_correlacion > umbral_coincidencia); % Coordenadas de picos

f9 = figure;                      % Inicializa ventana grafica
set(f9, 'Name', 'Modulo 5: Localizacion de Pines por Correlacion');

subplot(2, 1, 1);
imshow(plantilla_pin);            % Muestra la plantilla buscada
axis on;
title('Plantilla de Referencia (Pin)');

subplot(2, 1, 2);
imshow(im4);                      % Muestra imagen completa
axis on;
hold on;

% Correccion del desfase espacial producido por normxcorr2 (centrado de marcas)
offset_x = 28;                    % Ancho medio de la plantilla
offset_y = 28;                    % Alto medio de la plantilla

% plot(): Marca los centros detectados con estrellas azules
plot(cols_pico - offset_x, filas_pico - offset_y, 'b*', 'LineWidth', 1.5);
title('Pines Detectados mediante Picos de Correlacion (> 0.6)');
hold off;

% Visualizacion de la superficie de correlacion en 2D y 3D
f10 = figure;                     % Inicializa ventana grafica
set(f10, 'Name', 'Modulo 5: Mapa de Superficie de Correlacion Cruzada');

subplot(1, 2, 1);
imshow(matriz_correlacion);       % Mapa de calor 2D
title('Matriz de Correlacion 2D (normxcorr2)');

subplot(1, 2, 2);
surf(matriz_correlacion);         % Representacion en relieve 3D
colormap hsv;                     % Paleta de color HSV
shading interp;                   % Interpolacion visual
title('Picos de Correlacion en Espacio 3D');

% Aplicacion de localizacion de orificios sobre piezas mecanicas (im1)
% Recorte de un orificio circular de la pieza como plantilla
plantilla_orificio = im1(110:150, 160:200); % Recorte de orificio

corr_orificios = normxcorr2(plantilla_orificio, im1); % Correlacion
[f_orif, c_orif] = find(corr_orificios > 0.65);        % Filtrado de picos

f11 = figure;                     % Inicializa ventana grafica
set(f11, 'Name', 'Modulo 5: Deteccion de Orificios en Gauges');

imshow(im1);
hold on;
plot(c_orif - 20, f_orif - 20, 'ro', 'MarkerSize', 8, 'LineWidth', 2); % Marcas circulares rojas
title('Orificios Localizados mediante Correlacion Cruzada');
hold off;

%% =========================================================================
% MODULO 6: Analisis frecuencial mediante Transformada de Fourier 2D (FFT)
% =========================================================================
% Proposito: Evaluar el espectro de magnitud en el dominio frecuencial
% aplicando fft2 y fftshift para analizar orientacion y patrones de repeticion.

% fft2(imagen): Computa la Transformada Rapida de Fourier en dos dimensiones
F_im1 = fft2(im1);                % Matriz compleja en el dominio frecuencial

% abs(): Calcula la magnitud/espectro del resultado complejo de Fourier
S_im1 = abs(F_im1);               % Espectro sin centrar (origen en esquinas)

% fftshift(): Desplaza la frecuencia cero (DC) al centro del plano espectral
SC_im1 = abs(fftshift(F_im1));    % Espectro centrado en el origen

f12 = figure;                     % Inicializa ventana grafica
set(f12, 'Name', 'Modulo 6: Espectro de Fourier de Gauges');

subplot(2, 2, 1);
imshow(im1);                      % Imagen en dominio espacial
title('Imagen Espacial Original');

subplot(2, 2, 3);
% Compresion logaritmica para visualizacion de amplio rango dinamico: 30*log10(1 + S)
imshow(30 * log10(1 + S_im1) / 255); % Espectro sin centrar
title('Espectro de Magnitud Directo');

subplot(2, 2, 4);
imshow(30 * log10(1 + SC_im1) / 255); % Espectro centrado
title('Espectro Centrado (fftshift)');

% Analisis frecuencial sobre patron periodico de pines (im3)
F_im3 = fft2(im3);                % FFT de la imagen de pines
SC_im3 = abs(fftshift(F_im3));    % Espectro centrado

f13 = figure;                     % Inicializa ventana grafica
set(f13, 'Name', 'Modulo 6: Espectro Frecuencial de Estructura Periodica');

subplot(2, 1, 1);
imshow(im3);
title('Patron Periodico de Pines');

subplot(2, 1, 2);
imshow(30 * log10(1 + SC_im3) / 255); % Muestra picos frecuenciales del patron repetitivo
title('Espectro Centrado (Evidencia de frecuencia fundamental de alineacion)');

% Demostracion de equivalencia: Convolucion espacial vs Multiplicacion frecuencial
F_im4 = fft2(im4);                % Transformada de la imagen
F_m17 = fft2(m17, size(im4, 1), size(im4, 2)); % Transformada de la mascara ajustada en tamano

% Multiplicacion punto a punto en frecuencia equivale a convolucion espacial
im4_freq_smooth = real(ifft2(F_im4 .* F_m17)); % ifft2: Transformada Inversa 2D

f14 = figure;                     % Inicializa ventana grafica
set(f14, 'Name', 'Modulo 6: Equivalencia Convolucion Espacial vs Frecuencial');

subplot(2, 1, 1);
imshow(im4_smooth17 / 255);       % Resultado por conv2 en espacio
title('Convolucion en Dominio Espacial (conv2)');

subplot(2, 1, 2);
imshow(im4_freq_smooth / 255);    % Resultado por producto en frecuencia
title('Producto en Dominio Frecuencial (ifft2(F_image .* F_kernel))');

% Fin del script
