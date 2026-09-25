% Subprogramas / Scripts externos necesarios:
% Para ejecutar este script en tu entorno de MATLAB requerirás las siguientes funciones y scripts de la asignatura:
% 1. `CargarMuestra`: Script que carga los patrones de muestra (`pci`, `ptr`, `pcu`) y visualiza el espacio de patrones.
% 2. `perceptron_isa(clase1, clase2, c)`: Función que calcula la matriz/vector de pesos \\(w\\) del hiperplano separador.
% 3. `signatura_isa(objeto_binario)`: Calcula la signatura radial del objeto (distancias del centroide al contorno).
% 4. `vercre_isa(imagen, umbral)`: Crecimiento de regiones interactivo con ratón.
% 5. `CargarMedicamentos`: Script que carga y muestra las imágenes de blísteres de cápsulas.


% =========================================================================
% REPOSITORIO DE VISION POR COMPUTADOR
% Archivo: 11_reconocimiento_patrones_perceptron_medicamentos.m
% Descripcion: Modulo para el reconocimiento multiclase de formas geometricas
%              (circulos, triangulos, cuadrados) mediante el algoritmo del 
%              perceptron y la clasificacion en espacio de patrones, seguido
%              de la inspeccion automatica de blisters de medicamentos.
% Valor practico: Clasificacion automatizada de componentes por su forma 
%                 y control de calidad de empaquetado farmaceutico.
% =========================================================================

%% Limpieza inicial del entorno de trabajo
clearvars;      % Elimina todas las variables guardadas en el espacio de trabajo (Workspace)
close all;      % Cierra todas las ventanas de figuras que esten abiertas
clc;            % Limpia el texto visible en la ventana de comandos (Command Window)

%% =========================================================================
% PARTE 1: RECONOCIMIENTO DE PATRONES Y FORMAS GEOMETRICAS (PERCEPTRON)
% =========================================================================

% 1. Carga de la muestra de entrenamiento (circulos: pci, triangulos: ptr, cuadrados: pcu)
CargarMuestra(); % Genera pci, ptr, pcu y muestra el espacio de patrones

% 2. Entrenar clasificadores binarios mediante perceptron de incremento fijo (c = 1)
c = 1;
dcutr = perceptron_isa(pcu, ptr, c); % Funciones de decision: Cuadrado vs Triangulo
dcuci = perceptron_isa(pcu, pci, c); % Cuadrado vs Circulo
dtrci = perceptron_isa(ptr, pci, c); % Triangulo vs Circulo

% Definicion de funciones opuestas por simetria de frontera de decision
dtrcu = -dcutr;
dcicu = -dcuci;
dcitr = -dtrci;

% 3. Carga y segmentacion de un objeto desconocido en imagen nueva
im = imread('cuadrado.jpg'); % Imagen de entrada
if size(im, 3) == 3
    im_gray = rgb2gray(im);
else
    im_gray = im;
end

% Segmentacion del objeto mediante crecimiento de regiones
objeto_seg = vercre_isa(im_gray, 40);

% 4. Obtenimiento de la signatura radial y calculo del vector de descriptores
s = signatura_isa(objeto_seg);
mu = mean(s(:, 2));            % Media de las distancias radiales
sigma = std(s(:, 2), 1);       % Desviacion tipica
vec_des = [mu, sigma, 1];      % Vector de caracteristicas extendido [mean, std, 1]

% 5. Evaluacion de las funciones de decision para el vector de entrada
citr = dcitr * vec_des';
cicu = dcicu * vec_des';
cuci = dcuci * vec_des';
cutr = dcutr * vec_des';
trcu = dtrcu * vec_des';
trci = dtrci * vec_des';

% Evaluacion de las condiciones multiclase por interseccion de semiespacios
ci = (citr > 0) & (cicu > 0);  % Mascara logica para Circulo
cu = (cuci > 0) & (cutr > 0);  % Mascara logica para Cuadrado
tr = (trcu > 0) & (trci > 0);  % Mascara logica para Triangulo

% 6. Asignacion de etiqueta y despliegue del resultado
figure;
imshow(im);
title('Resultado de la Clasificacion con Perceptron');

sumFlags = double(ci) + double(cu) + double(tr);

if sumFlags ~= 1
    xlabel('SIN CLASIFICAR');
else
    if ci
        xlabel('CIRCULO');
    elseif cu
        xlabel('CUADRADO');
    elseif tr
        xlabel('TRIANGULO');
    end
end

%% =========================================================================
% PARTE 2: INSPECCION AUTOMATIZADA DE BLISTERES DE MEDICAMENTOS
% =========================================================================

% Carga del conjunto de imagenes de blisters
CargarMedicamentos; % Carga y despliega la secuencia de blisters de prueba

% Procesamiento e inspeccion de blisters para conteo de capsulas
for idx = 1:numel(blister)
    im_blister = blister(idx).im;
    
    % Transformacion a espacio HSV para aislamiento cromatico de las capsulas
    im_hsv = rgb2hsv(im_blister);
    
    % Mascara de color para la tonalidad azul/verde de las capsulas
    mask_capsulas = (im_hsv(:, :, 1) > 0.5) & (im_hsv(:, :, 1) < 0.7) & (im_hsv(:, :, 2) > 0.3);
    
    % Limpieza morfologica para eliminar artefactos y reflejos del papel de aluminio
    mask_clean = bwmorph(mask_capsulas, 'open');
    mask_clean = bwmorph(mask_clean, 'close');
    
    % Etiquetado de componentes conectadas (capsulas detectadas)
    L_capsulas = bwlabel(mask_clean);
    num_capsulas = max(L_capsulas(:));
    
    % Evaluacion del estado del blister (total esperado = 15 capsulas)
    num_esperado = 15;
    diferencia = num_capsulas - num_esperado;
    
    figure;
    subplot(1, 3, 1);
    imshow(im_blister);
    if diferencia == 0
        title('CORRECTO');
    else
        title(['INCORRECTO ', num2str(diferencia)]);
    end
    
    subplot(1, 3, 2);
    imshow(mask_clean);
    title('Mascara Binaria de Capsulas');
    
    subplot(1, 3, 3);
    imshow(double(im_blister) / 255 .* cat(3, mask_clean, mask_clean, mask_clean));
    title(['Capsulas Detectadas: ', num2str(num_capsulas)]);
end

% Fin del script
