% Subprogramas/Funciones externas necesarias para este código:
% Para que sea posible ejecutar este script en un entorno de MATLAB, hace uso de los siguientes subprogramas (deberán de elaborarse individualmente, ya que la licencia de uso es privada):
% 1. `ver_seguimientoContorno_isa`: Realiza el seguimiento interactivo de contornos pidiendo un punto inicial.
% 2. `uglobal_isa`: Calcula el umbral global de binarización.
% 3. `houghc_isa`: Ejecuta la Transformada de Hough para la detección de círculos.

% =========================================================================
% REPOSITORIO DE VISION POR COMPUTADOR
% Archivo: 07_segmentacion_seguimiento_contornos_umbralizacion_hough.m
% Descripcion: Modulo para la segmentacion de imagenes mediante seguimiento 
%              de contornos (ver_seguimientoContorno_isa), umbralizacion global 
%              (uglobal_isa, Otsu) y adaptativa, aislamiento cromatico HSV 
%              y Transformada de Hough para circulos (houghc_isa) y lineas.
% Valor practico: Delimitacion de contornos, lectura de documentos con sombras, 
%                 segmentacion de cables por color y correccion de inclinacion.
% =========================================================================

%% Limpieza inicial del entorno de trabajo
clearvars;      % Elimina todas las variables guardadas en el espacio de trabajo (Workspace)
close all;      % Cierra todas las ventanas de figuras que esten abiertas
clc;            % Limpia el texto visible en la ventana de comandos (Command Window)

%% =========================================================================
% MODULO 1: Carga y visualizacion de imagenes base de inspeccion
% =========================================================================

im1 = imread('Parts00.png'); 
im2 = imread('Parts 06.jpg'); 
im3 = imread('Text01.jpg'); 
im4 = imread('Text05.jpg'); 
im5 = imread('cables11.jpg');

figure(1);
subplot(2, 3, 1), imshow(im1); hold on;
subplot(2, 3, 2), imshow(im2); hold on;
subplot(2, 3, 3), imshow(im3); hold on;
subplot(2, 3, 4), imshow(im4); hold on;
subplot(2, 3, 5), imshow(im5); hold on;

%% =========================================================================
% MODULO 2: Seguimiento de contornos mediante funcion especifica (ISA)
% =========================================================================

% Llama al subprograma externo ver_seguimientoContorno_isa (requiere seleccion interactiva)
s1 = ver_seguimientoContorno_isa(im1);
s2 = ver_seguimientoContorno_isa(im1);
s3 = ver_seguimientoContorno_isa(im2);
s4 = ver_seguimientoContorno_isa(im2);

% Representacion individual de los vectores de coordenadas extraidos
figure, plot(s1(:, 2), s1(:, 1)); axis equal, axis ij;
figure, plot(s2(:, 2), s2(:, 1)); axis equal, axis ij;
figure, plot(s3(:, 2), s3(:, 1)); axis equal, axis ij;
figure, plot(s4(:, 2), s4(:, 1)); axis equal, axis ij;

% Superposicion de los contornos extraidos sobre las imagenes originales
figure(4);
subplot(2, 1, 1), imshow(im1), hold on;
plot(s1(:, 2), s1(:, 1), 'r');
plot(s2(:, 2), s2(:, 1), 'g');

subplot(2, 1, 2), imshow(im2), hold on;
plot(s3(:, 2), s3(:, 1), 'r');
plot(s4(:, 2), s4(:, 1), 'g');

%% =========================================================================
% MODULO 3: Comparativa de umbralizacion global (uglobal_isa vs Otsu)
% =========================================================================

u1 = uglobal_isa(im2);
u2 = graythresh(im2);
disp(['Global = ', num2str(u1), '--', num2str(u1/255), ' Optimo = ', num2str(u2)]);

im2b = imbinarize(im2, u2);

figure(6);
subplot(2, 2, 1), imshow(im2);
subplot(2, 2, 2), imshow(im2b);
subplot(2, 1, 2), imhist(im2); hold on;
plot([u2, u2] * 255, , 'r');

%% =========================================================================
% MODULO 4: Umbralizacion adaptativa sobre documentos con gradiente de luz
% =========================================================================

im3g = rgb2gray(im3);
im3b1 = imbinarize(im3g, 'global');
im3b2 = imbinarize(im3g, 'adaptive');
im3b3 = imbinarize(im3g, 'adaptive', 'sensitivity', 0.7);

figure(7);
subplot(2, 2, 1), imshow(im3); title('A');
subplot(2, 2, 2), imshow(im3b1); title('B');
subplot(2, 2, 3), imshow(im3b2); title('C');
subplot(2, 2, 4), imshow(im3b3); title('D');

% Representacion del mapa de umbrales dinámicos
u = adaptthresh(double(im3g) / 255, 0.7);
figure(8);
im3b4 = (double(im3g) / 255) > u;
subplot(2, 1, 1), imshow(u);
subplot(2, 1, 2), imshow(im3b4);

% Aplicacion analoga sobre la segunda imagen de texto (im4)
im4g = rgb2gray(im4);
im4b1 = imbinarize(im4g, 'global');
im4b2 = imbinarize(im4g, 'adaptive');
im4b3 = imbinarize(im4g, 'adaptive', 'sensitivity', 0.7);

figure(9);
subplot(2, 2, 1), imshow(im4g);
subplot(2, 2, 2), imshow(im4b1);
subplot(2, 2, 3), imshow(im4b2);
subplot(2, 2, 4), imshow(im4b3);

%% =========================================================================
% MODULO 5: Segmentacion por color en espacio HSV (Cables)
% =========================================================================

im5hsv = rgb2hsv(im5);
h = imhist((im5hsv(:, :, 1) .* (im5hsv(:, :, 2) > 0.4)) * 255, hsv(255)) / (numel(im5) / 3);

figure(10);
bar(0:1/254:1, h), axis([0 1 0 0.005]); grid on;
colormap(hsv(256));
colorbar('Location', 'southoutside', 'Ticks', []);
title('HISTOGRAMA H (mejorado)');

figure(11);
% Segmentacion de cable verde
bH = im5hsv(:, :, 1) > 0.3 & im5hsv(:, :, 1) < 0.5;
bS = im5hsv(:, :, 2) > 0.15;
imb = bH .* bS;
imb3 = cat(3, imb, imb, imb);
im5Verde = double(im5) .* imb3;

% Segmentacion de cables azules
bH = im5hsv(:, :, 1) > 0.6 & im5hsv(:, :, 1) < 0.7;
bS = im5hsv(:, :, 2) > 0.15;
imb = bH .* bS;
imb3 = cat(3, imb, imb, imb);
im5Azul = double(im5) .* imb3;

% Segmentacion de cable rojo
bH = im5hsv(:, :, 1) < 0.1 | im5hsv(:, :, 1) > 0.9;
bS = im5hsv(:, :, 2) > 0.4;
imb = bH .* bS;
imb3 = cat(3, imb, imb, imb);
im5Rojo = double(im5) .* imb3;

subplot(2, 2, 1), imshow(im5);
subplot(2, 2, 2), imshow(im5Verde / 255);
subplot(2, 2, 3), imshow(im5Azul / 255);
subplot(2, 2, 4), imshow(im5Rojo / 255);

%% =========================================================================
% MODULO 6: Transformada de Hough para circulos (houghc_isa)
% =========================================================================

im6 = imread('bat0001.png');
im7 = imread('oilfilt1.jpg');

% Deteccion en conector de bateria para radios 18, 50, 60 y 88
[centros1, AC1] = houghc_isa(im6, 0.3, 18);
[centros2, AC2] = houghc_isa(im6, 0.3, 50);
[centros3, AC3] = houghc_isa(im6, 0.3, 60);
[centros4, AC4] = houghc_isa(im6, 0.3, 88);

% Deteccion interactiva en filtro de aceite
figure(17);
imshow(im7);
r = (sqrt(sum((ginput(1) - ginput(1)).^2))) / 2;
[centros5, AC5] = houghc_isa(im7, 0.2, r);

figure(18);
surf(AC5), shading interp;

%% =========================================================================
% MODULO 7: Transformada de Hough para lineas y correccion de angulo
% =========================================================================

im3b3n = not(im3b3);
AC = hough(im3b3n);

figure(19), surf(AC), shading interp;

picos = houghpeaks(AC, 5);
m = mean(picos(:, 2));

figure(20);
imshow(AC, []), axis square, set(gca, 'OuterPosition', );
hold on;
plot(picos(:, 2), picos(:, 1), 'go');

% Rotacion para corregir la inclinacion del documento
im3r = imrotate(im3, m);

figure(21);
subplot(1, 2, 1), imshow(im3);
subplot(1, 2, 2), imshow(im3r);

% Fin del script
