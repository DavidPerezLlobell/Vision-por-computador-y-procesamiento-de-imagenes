% =========================================================================
% REPOSITORIO DE VISION POR COMPUTADOR
% Archivo: 10_descripcion_y_representacion_2.m
% Descripcion: Modulo para la clasificacion automatica de componentes mecanicos 
%              (poleas, ejes, engranajes) mediante descriptores topologicos 
%              y el reconocimiento de digitos en displays LCD.
% Valor practico: Control de calidad automatizado en lineas de montaje,
%                 deteccion de piezas defectuosas y lecturas OCR en displays.
% =========================================================================

%% Limpieza inicial del entorno de trabajo
clearvars;      % Elimina todas las variables guardadas en el espacio de trabajo (Workspace)
close all;      % Cierra todas las ventanas de figuras que esten abiertas
clc;            % Limpia el texto visible en la ventana de comandos (Command Window)

%% =========================================================================
% MODULO 1: Clasificacion automatica de objetos (Poleas, Ejes y Engranajes)
% =========================================================================

% Carga del conjunto de imagenes de prueba mediante el script auxiliar
CargarGears; % Carga y muestra g1, g2, g3, g4, g5, g6, g7, g8

% Seleccion de la imagen de inspeccion a procesar
im = g1; % Imagen de entrada

% Mejoramiento y binarizacion de la imagen
if size(im, 3) == 3
    im_gray = rgb2gray(im);
else
    im_gray = im;
end

imb = imbinarize(im_gray, graythresh(im_gray));
if mean(imb(:)) > 0.5
    imb = not(imb); % Asegura objetos en blanco sobre fondo negro
end

% Extraccion de descriptores de region
pro = regionprops(imb, 'all');

figure;
imshow(im);
hold on;

for k = 1:numel(pro)
    % Ignora regiones de ruido de tamano muy reducido
    if pro(k).Area > 100
        E = pro(k).EulerNumber;  % Numero de Euler para caracterizacion topologica
        cx = pro(k).Centroid(1); % Coordenada X del centroide
        cy = pro(k).Centroid(2); % Coordenada Y del centroide
        
        if E == 0
            % Objeto con 1 agujero interior: Eje
            text(cx - 15, cy, 'EJE', 'Color', 'g', 'FontSize', 12, 'FontWeight', 'bold');
            
        elseif E == -6
            % Objeto con 7 agujeros interiores: Polea
            text(cx - 20, cy, 'POLEA', 'Color', 'cyan', 'FontSize', 12, 'FontWeight', 'bold');
            
        elseif E == -4
            % Objeto con 5 agujeros interiores: Engranaje
            % Evaluacion de integridad de los dientes mediante diferencia convexa
            im_rellena = pro(k).FilledImage;
            im_convexa = pro(k).ConvexImage;
            
            % Diferencia entre cerco convexo e imagen rellena
            dif_convexa = im_convexa - im_rellena;
            
            % Mejora morfologica mediante erosion para aislar los valles de los dientes
            dif_erosionada = bwmorph(dif_convexa, 'erode', 3);
            
            % Etiquetado de regiones conectadas para contar los valles
            L_dientes = bwlabel(dif_erosionada);
            N_dientes = max(L_dientes(:)); % Numero de componentes conectadas
            
            if N_dientes == 24
                % Engranaje completo con 24 valles intactos
                text(cx - 50, cy, 'ENGRANAGE CORRECTO', 'Color', 'g', 'FontSize', 11, 'FontWeight', 'bold');
            else
                % Engranaje con dientes faltantes o rotos
                text(cx - 60, cy, 'ENGRANAGE DEFECTUOSO', 'Color', 'r', 'FontSize', 11, 'FontWeight', 'bold');
            end
        end
    end
end
hold off;

%% =========================================================================
% MODULO 2: Reconocimiento de caracteres y digitos en displays LCD
% =========================================================================

% Carga de imagenes LCD mediante el script auxiliar
CargaLcd; % Carga lcd01, lcd02, ..., lcd10

% Procesamiento y extraccion de esquematizacion en pantallas LCD
for idx = 1:numel(lcd)
    im_lcd = lcd(idx).im;
    
    % Secuencia de preprocesamiento morfologico para aislamiento de segmentos
    im_eq = histeq(im_lcd);                     % Igualacion de histograma
    im_bin = not(im2bw(im_eq, 0.25));            % Binarizacion y not
    im_er = bwmorph(im_bin, 'erode');            % Una erosion
    im_dil = bwmorph(im_er, 'dilate', 4);        % Cuatro dilataciones
    im_esq = bwmorph(im_dil, 'thin', inf);       % Adelgazamiento / esqueleto
    
    % Etiquetado de digitos individuales
    L_dig = bwlabel(im_esq);
    num_dig = max(L_dig(:));
    
    figure;
    subplot(1, 2, 1);
    imshow(im_lcd);
    title(['Display LCD original ', num2str(idx)]);
    
    subplot(1, 2, 2);
    imshow(im_esq);
    title('Esqueleto de Digitos Extraido');
    hold on;
    
    texto_detectado = '';
    
    for d = 1:num_dig
        dig_mask = (L_dig == d);
        if bwarea(dig_mask) > 15
            p_dig = regionprops(dig_mask, 'ConvexArea', 'Orientation', 'Centroid', 'BoundingBox');
            
            % Puntos finales (endpoints) del esqueleto
            endpoints = bwmorph(dig_mask, 'endpoints');
            num_endpoints = sum(endpoints(:));
            
            c_x = p_dig.Centroid(1);
            c_y = p_dig.Centroid(2);
            
            % Clasificacion basada en descriptores morfologicos
            digito_char = '?';
            if num_endpoints == 2
                if p_dig.Orientation > 70 || p_dig.Orientation < -70
                    digito_char = '1';
                else
                    digito_char = '2';
                end
            elseif num_endpoints == 4
                digito_char = '3';
            elseif num_endpoints == 0
                digito_char = '8';
            end
            
            text(c_x, c_y, digito_char, 'Color', 'yellow', 'FontSize', 16, 'FontWeight', 'bold');
            texto_detectado = [texto_detectado, digito_char];
        end
    end
    hold off;
    disp(['Display LCD ', num2str(idx), ' - Numero Detectado: ', texto_detectado]);
end

% Fin del script
