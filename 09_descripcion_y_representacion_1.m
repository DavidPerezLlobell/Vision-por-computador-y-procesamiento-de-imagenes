% Subprogramas / Funciones externas necesarias
% Para ejecutar este script en tu entorno de MATLAB necesitarás contar en la misma carpeta o en el *path* con las siguientes funciones auxiliares de la asignatura:
% 1. `vercre_isa(imagen, umbral)`: Crecimiento de regiones interactivo con selección de semilla mediante ratón.
% 2. `cre_isa(imagen, umbral, fila, columna)`: Crecimiento de regiones con semilla por coordenadas.
% 3. `signatura_isa(objeto_binario)`: Obtiene la signatura radial (ángulos y distancias euclídeas al centroide).
% 4. `veradel_isa(objeto_binario)`: Algoritmo de adelgazamiento / esqueleto (Zhang y Suen).
% 5. `histStat(X, P)`: Cálculo de momentos estadísticos del histograma.
% 6. `CargarLcds`: Script para la lectura del conjunto de imágenes LCD.

% =========================================================================
% REPOSITORIO DE VISION POR COMPUTADOR
% Archivo: 09_descripcion_y_representacion_1_solucion.m
% Descripcion: Modulo para la descripcion y representacion de regiones.
%              Cubre el calculo de descriptores morfometricos (regionprops),
%              representacion de signaturas (signatura_isa), calculo de 
%              esqueletos/adelgazamiento (veradel_isa, bwmorph) y operaciones
%              morfologicas sobre componentes y displays LCD.
% =========================================================================

%% Limpieza inicial del entorno de trabajo
clearvars;      % Elimina todas las variables guardadas en el espacio de trabajo (Workspace)
close all;      % Cierra todas las ventanas de figuras que esten abiertas
clc;            % Limpia el texto visible en la ventana de comandos (Command Window)

%% =========================================================================
% EJERCICIO 9.1: Binarizacion e inspeccion inicial de imagenes
% =========================================================================

im1 = imread('Parts00.png'); 
im2 = imread('Parts 01.jpg');

im1b = not(imbinarize(im1)); 
im2b = imbinarize(im2); 

figure('Name','EJERCICIO 9.1'); 
subplot(2,2,1), imshow(im1); 
subplot(2,2,2), imshow(im2); 
subplot(2,2,3), imshow(im1b); 
subplot(2,2,4), imshow(im2b);

%% =========================================================================
% EJERCICIO 9.2: Descriptores de region con regionprops
% =========================================================================

ob = vercre_isa(im1, 90); 
p = regionprops(ob, 'all'); 
set(gcf, 'Name', 'EJERCICIO 9.2'); 
imshow(ob); hold on;

t = categorical({[' Area = ', num2str(p.Area)], ... 
    [' Area convexa = ', num2str(p.ConvexArea)], ... 
    [' Perimetro = ', num2str(p.Perimeter)], ... 
    [' Excentricidad = ', num2str(p.Eccentricity)]});
text(10, 50, t, 'Color', );

%% =========================================================================
% EJERCICIO 9.3: Representacion del centroide, cerco convexo y relleno
% =========================================================================

figure('Name','EJERCICIO 9.3a'); 
imshow(double(im1).*not(ob) + ob*256, [gray(255); 1 0 0]); hold on;
plot(p.Centroid(1), p.Centroid(2), '*');

figure('Name','EJERCICIO 9.3b'); 
subplot(2,2,1), imshow(p.Image); 
subplot(2,2,2), imshow(p.ConvexImage); 
subplot(2,2,3), imshow(p.FilledImage); 
subplot(2,2,4), imshow(p.ConvexImage - p.FilledImage);

%% =========================================================================
% EJERCICIO 9.4: Repeticion de descriptores y regiones sobre im2
% =========================================================================

ob = vercre_isa(im2, 90); 
p = regionprops(ob, 'all'); 

figure('Name','EJERCICIO 9.4a'); 
imshow(ob); hold on;
t = categorical({[' Area = ', num2str(p.Area)], ... 
    [' Area convexa = ', num2str(p.ConvexArea)], ... 
    [' Perimetro = ', num2str(p.Perimeter)], ... 
    [' Excentricidad = ', num2str(p.Eccentricity)]});
text(10, 50, t, 'Color', );

figure('Name','EJERCICIO 9.4b'); 
imshow(double(im2).*not(ob) + ob*256, [gray(255); 1 0 0]); hold on;
plot(p.Centroid(1), p.Centroid(2), '*');

figure('Name','EJERCICIO 9.4c'); 
subplot(2,2,1), imshow(p.Image); 
subplot(2,2,2), imshow(p.ConvexImage); 
subplot(2,2,3), imshow(p.FilledImage); 
subplot(2,2,4), imshow(p.ConvexImage - p.FilledImage);

%% =========================================================================
% EJERCICIO 9.5: Signatura de objetos, picos y momentos estadisticos
% =========================================================================

pro = regionprops(im1b, 'FilledImage', 'ConvexImage', 'Area'); 

for k = 1:numel(pro)
    if (pro(k).Area > 20)
        s1 = signatura_isa(pro(k).FilledImage);
        s2 = signatura_isa(pro(k).ConvexImage);
        
        figure;
        subplot(2,2,1), imshow(pro(k).FilledImage);
        subplot(2,2,2), plot(s1(:,1), s1(:,2));
        subplot(2,2,3), imshow(pro(k).ConvexImage);
        subplot(2,2,4), plot(s2(:,1), s2(:,2));
        
        s2s = conv(s2(:,2), /7, 'valid');
        findpeaks(s2s, 'MinPeakDistance', 10, 'MinPeakProminence', 0);
        
        figure;
        subplot(2,2,1), imshow(pro(k).ConvexImage);
        subplot(2,2,3), plot(s2(:,1), s2(:,2));
        
        h = hist(round(s2(:,2)*25), 0:25);
        h = h / sum(h);
        subplot(2,2,4), bar(h);
        
        [m1, m2, m3, m4] = histStat(1:numel(h), h');
        t = categorical({[' M2 = ', num2str(m1)], ...
            [' M3 = ', num2str(m2)], ...
            [' M4 = ', num2str(m3)], ...
            [' M5 = ', num2str(m4)]});
        subplot(2,2,2), text(0.1, 0.5, t, 'Color', [0 0.5 0], 'FontSize', 18);
        axis off;
    end
end

%% =========================================================================
% EJERCICIO 9.6: Esqueleto de un objeto (veradel_isa)
% =========================================================================

ob = (cre_isa(im2, 90)); 
pro = regionprops(ob, 'FilledImage'); 
ob = pro.FilledImage; 
es = veradel_isa(ob); 
set(gcf, 'Name', 'EJERCICIO 9.6');

%% =========================================================================
% EJERCICIO 9.7: Esqueleto de todos los objetos con veradel_isa
% =========================================================================

es = veradel_isa(im1b); 
imshow(double(im1).*not(es) + es*256, [gray(255); 0 1 0]); 
set(gcf, 'Name', 'EJERCICIO 9.7');

%% =========================================================================
% EJERCICIO 9.8: Adelgazamiento morfologico (bwmorph)
% =========================================================================

es = bwmorph(im1b, 'thin', inf); 
figure;
imshow(double(im1).*not(es) + es*256, [gray(255); 0 1 0]); 
set(gcf, 'Name', 'EJERCICIO 9.8');

%% =========================================================================
% EJERCICIO 9.9: Filtrado morfologico en secuencia (open -> dilate -> erode)
% =========================================================================

im2b_1 = bwmorph(im2b, 'open'); 
im2b_2 = bwmorph(im2b_1, 'dilate', 5); 
im2b_3 = bwmorph(im2b_2, 'erode', 5); 

f = figure; set(f, 'Name', 'EJERCICIO 9.9'); 
subplot(2,2,1), imshow(im2b); 
subplot(2,2,2), imshow(im2b_1); 
subplot(2,2,3), imshow(im2b_2); 
subplot(2,2,4), imshow(im2b_3); 
im3b = im2b_3;

%% =========================================================================
% EJERCICIO 9.10: Adelgazamiento sobre imagen mejorada morfológicamente
% =========================================================================

figure('Name','EJERCICIO 9.10'); 
subplot(1,2,1), imshow(im3b); 
subplot(1,2,2), imshow(bwmorph(im3b, 'thin', inf));

%% =========================================================================
% EJERCICIO 9.11: Extraccion de esqueleto en digitos LCD
% =========================================================================

CargarLcds;
figure('Name','EJERCICIO 9.11'); 

for k = 1:numel(lcd)
    im = lcd(k).im; 
    im = histeq(im); 
    im = not(im2bw(im, 0.25)); 
    im = bwmorph(im, 'erode'); 
    im = bwmorph(im, 'dilate', 4); 
    im = bwmorph(im, 'thin', inf); 
    subplot(3,4,k); 
    imshow(im);
end

% Fin del script
