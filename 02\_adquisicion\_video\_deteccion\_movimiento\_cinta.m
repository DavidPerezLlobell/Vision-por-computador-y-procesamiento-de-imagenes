% =========================================================================
% REPOSITORIO DE VISION POR COMPUTADOR
% Archivo: 02_adquisicion_video_deteccion_movimiento_cinta.m
% Descripcion: Modulo para el procesamiento de secuencias de video en tiempo 
%              real, deteccion de movimiento mediante diferencia de fotogramas, 
%              analisis de espacios de color (RGB, HSV, Luma) e inspeccion 
%              automatizada sobre linea de control en cinta transportadora.
% Valor practico: Sistema de control de calidad industrial para deteccion de 
%                 presencia, parada automatica por sensor virtual y seguimiento.
% =========================================================================

%% Limpieza inicial del entorno de trabajo
clearvars;      % Elimina todas las variables guardadas en el espacio de trabajo (Workspace)
close all;      % Cierra todas las ventanas de figuras que esten abiertas
clc;            % Limpia el texto visible en la ventana de comandos (Command Window)

% Declaracion de variable global para el control de interrupcion de bucles de video
global fin_reproduccion;

%% =========================================================================
% MODULO 1: Reproduccion interactiva de video controlada por eventos
% =========================================================================
% Proposito: Cargar y transmitir una secuencia de video cuadro a cuadro,
% permitiendo la pausa interactiva mediante clic y la detencion mediante rueda de raton.

f1 = figure;                      % Inicializa nueva ventana grafica
set(f1, 'Name', 'Modulo 1: Reproduccion de Video con Control de Eventos'); % Asigna titulo a la ventana

fin_reproduccion = 0;              % Inicializa la bandera de control en estado activo

% Callback de interrupcion por eventos de raton sobre la interfaz grafica
f1.ButtonDownFcn = @PausarVideo;         % Vincula el clic del raton con la funcion PausarVideo
f1.WindowScrollWheelFcn = @TerminarVideo; % Vincula el movimiento de la rueda con TerminarVideo

% VideoReader(): Crea un objeto de lectura de video para extraer fotogramas individuales desde archivo.
fichero_video = 'cinta1_p.mp4';    % Nombre del archivo de video de la cinta transportadora
v1 = VideoReader(fichero_video);   % Instancia el objeto de lectura de video

% hasFrame(v): Retorna un valor booleano verdadero (1) mientras existan fotogramas pendientes de lectura.
while (not(fin_reproduccion) && hasFrame(v1))
    
    % readFrame(v): Lee el siguiente fotograma secuencial de la secuencia de video.
    im_frame = readFrame(v1);      % Extrae la matriz de imagen del fotograma actual
    
    imshow(im_frame);              % Renderiza el fotograma en pantalla
    
    % drawnow: Fuerza la actualizacion inmediata de la figura grafica en tiempo real.
    drawnow;                       % Refresca el buffer grafico de MATLAB
    
end % Fin del bucle de reproduccion

%% =========================================================================
% MODULO 2: Deteccion de movimiento por diferencia de fotogramas consecutivos
% =========================================================================
% Proposito: Identificar zonas de cambio dinamico restando matrices de luminancia
% de dos fotogramas adyacentes en el tiempo.

f2 = figure;                      % Inicializa nueva ventana grafica
set(f2, 'Name', 'Modulo 2: Diferencia Temporal entre Fotogramas'); % Nombre de la ventana

fin_reproduccion = 0;              % Reinicia la bandera de finalizacion
f2.ButtonDownFcn = @PausarVideo;         % Asigna callback de pausa
f2.WindowScrollWheelFcn = @TerminarVideo; % Asigna callback de terminacion

v2 = VideoReader(fichero_video);   % Re-instancia el lector desde el inicio

while (not(fin_reproduccion) && hasFrame(v2))
    
    im1 = readFrame(v2);           % Captura primer fotograma del par
    if not(hasFrame(v2)), break; end % Verificacion de seguridad ante fin de archivo
    im2 = readFrame(v2);           % Captura segundo fotograma consecutivo
    
    % Conversion a escala de grises y normalizacion al rango dinamico de punto flotante [0.0, 1.0]
    im1_gray = double(rgb2gray(im1)) / 255; % Convierte im1 a matriz continua
    im2_gray = double(rgb2gray(im2)) / 255; % Convierte im2 a matriz continua
    
    % abs(): Calcula la diferencia absoluta pixel a pixel para ignorar el signo del cambio.
    % Se amplifica por un factor de 5 para resaltar variaciones sutiles de movimiento.
    dif_frame = 5 * abs(im1_gray - im2_gray); % Matriz de cambio amplificada
    
    subplot(2, 1, 1);              % Cuadrante superior
    imshow(im1);                   % Muestra la imagen de la cinta en color
    title('Fotograma Original en Color'); % Titulo descriptivo
    
    subplot(2, 1, 2);              % Cuadrante inferior
    imshow(dif_frame);             % Muestra el mapa de calor de movimiento
    title('Diferencia de Movimiento Amplificada (x5)'); % Titulo descriptivo
    
    drawnow;                       % Actualiza interfaz grafica
    
end % Fin del bucle de diferencia temporal

%% =========================================================================
% MODULO 3: Comparativa de espacios de color para deteccion robusta de objetos
% =========================================================================
% Proposito: Analizar el comportamiento de la imagen a t = 6.6s evaluando si
% la componente de Valor (HSV) o la Luma (Grises) es mas invariable al color de la pieza.

f3 = figure;                      % Inicializa nueva ventana grafica
set(f3, 'Name', 'Modulo 3: Analisis de Espacios de Color en t = 6.6s'); % Nombre de la figura

v3 = VideoReader(fichero_video);   % Instancia objeto de lectura de video

% CurrentTime: Asigna o consulta la marca de tiempo exacta (en segundos) en la secuencia de video.
v3.CurrentTime = 6.6;              % Posiciona el cabezal de lectura en el segundo 6.6

im_66 = readFrame(v3);             % Extrae el fotograma especifico de la marca temporal
im_hsv_66 = rgb2hsv(im_66);        % Convierte la imagen al espacio de color HSV

canal_V_66 = im_hsv_66(:, :, 3);   % Extrae el plano 3 (Valor / Intensidad luminosa)
canal_L_66 = rgb2gray(im_66);      % Convierte a escala de grises equivalente (Luma)

subplot(1, 3, 1);                 % Posicion 1
imshow(im_66);                    % Renderiza fotograma original
title('Fotograma RGB Original');   % Titulo del cuadrante

subplot(1, 3, 2);                 % Posicion 2
imshow(canal_V_66);               % Muestra componente V (HSV)
title('Componente V (Valor en HSV)'); % Titulo del cuadrante

subplot(1, 3, 3);                 % Posicion 3
imshow(canal_L_66);               % Muestra componente Luma
title('Componente Luma (Grises)'); % Titulo del cuadrante

%% =========================================================================
% MODULO 4: Calibracion de umbrales para sensor virtual de presencia
% =========================================================================
% Proposito: Definir parametros criticos de decision cuantitativa para separar
% el fondo de la cinta respecto a las piezas industriales en paso.

% Umbral 1: Sensibilidad de nivel de intensidad (variacion minima para no considerar fondo)
umbral_intensidad = 0.5;           % Tolera fluctuaciones menores a 0.5 en rango

% Umbral 2: Cantidad espacial de pixeles cambiados para confirmar presencia de pieza
umbral_conteo_pixeles = 20;        % Requiere al menos 20 pixeles sobre la linea para activar la alerta

disp('Parametros de calibracion del sensor virtual:'); % Mensaje informativo
disp(['- Umbral 1 (Intensidad minima): ', num2str(umbral_intensidad)]); % Muestra umbral 1
disp(['- Umbral 2 (Conteo espacial): ', num2str(umbral_conteo_pixeles), ' pixeles']); % Muestra umbral 2

%% =========================================================================
% MODULO 5: Evaluacion de componentes cromaticas H y S en la linea de control
% =========================================================================
% Proposito: Inspeccionar si los canales de Matiz (H) y Saturacion (S) son viables
% para la discriminacion de piezas sobre la linea de control transversal.

f5 = figure;                      % Inicializa nueva ventana grafica
set(f5, 'Name', 'Modulo 5: Perfiles de Control en Canales H, S y V'); % Nombre de la figura

v5 = VideoReader(fichero_video);   % Instancia objeto de lectura de video
v5.CurrentTime = 6.6;              % Posiciona en t = 6.6s
im_m5 = readFrame(v5);             % Captura fotograma
im_hsv_m5 = rgb2hsv(im_m5);        % Transforma a HSV

% Extrae el perfil unidimensional en la fila 100, desde la columna 80 a la 380
linea_H = im_hsv_m5(100, 80:380, 1); % Perfil en canal Matiz (H)
linea_S = im_hsv_m5(100, 80:380, 2); % Perfil en canal Saturacion (S)
linea_V = im_hsv_m5(100, 80:380, 3); % Perfil en canal Valor (V)

subplot(3, 1, 1);                 % Posicion superior
plot(linea_H);                    % Grafica perfil de Matiz
title('Perfil sobre Linea de Control en Canal H (Matiz)'); % Titulo
grid on;                          % Activa rejilla

subplot(3, 1, 2);                 % Posicion central
plot(linea_S);                    % Grafica perfil de Saturacion
title('Perfil sobre Linea de Control en Canal S (Saturacion)'); % Titulo
grid on;                          % Activa rejilla

subplot(3, 1, 3);                 % Posicion inferior
plot(linea_V);                    % Grafica perfil de Valor
title('Perfil sobre Linea de Control en Canal V (Valor)'); % Titulo
grid on;                          % Activa rejilla

%% =========================================================================
% MODULO 6: Sensor virtual con cambio dinamico de color en linea de control
% =========================================================================
% Proposito: Implementar una linea de inspeccion grafica sobre la cinta que cambia
% de verde a rojo en tiempo real al detectar un objeto cruzando la franja.

f6 = figure;                      % Inicializa nueva ventana grafica
set(f6, 'Name', 'Modulo 6: Sensor Virtual Dinamico sobre Cinta'); % Nombre de la figura

fin_reproduccion = 0;              % Reinicia bandera de control
f6.ButtonDownFcn = @PausarVideo;         % Asigna callback de pausa
f6.WindowScrollWheelFcn = @TerminarVideo; % Asigna callback de terminacion

v6 = VideoReader(fichero_video);   % Instancia objeto de lectura de video

% Adquisicion del patron de referencia del fondo en t = 0s
im_ref = readFrame(v6);            % Lee primer fotograma sin piezas
im_ref_hsv = rgb2hsv(im_ref);      % Convierte a HSV
linea_referencia = im_ref_hsv(100, 80:380, 3); % Linea de control base en canal V

v6.CurrentTime = 0;                % Reinicia el video al fotograma inicial

while (not(fin_reproduccion) && hasFrame(v6))
    
    im_actual = readFrame(v6);     % Captura fotograma actual
    im_hsv_act = rgb2hsv(im_actual); % Convierte a HSV
    linea_nueva = im_hsv_act(100, 80:380, 3); % Extrae linea de control actual
    
    % Calculo de la desviacion absoluta respecto al fondo sin objetos
    dif_linea = abs(linea_referencia - linea_nueva); % Vector de diferencias
    
    subplot(2, 1, 1);              % Cuadrante superior
    imshow(im_actual);             % Muestra video de la cinta
    hold on;                       % Habilita superposicion grafica
    
    % Evaluacion del sensor virtual mediante los dos umbrales
    % sum(dif_linea > umbral_intensidad): Cuenta cuantos pixeles superan la variacion de 0.5
    if (sum(dif_linea > umbral_intensidad) > umbral_conteo_pixeles)
        plot(, , '-r', 'LineWidth', 2); % Traza linea en ROJO (Objeto presente)
    else
        plot(, , '-g', 'LineWidth', 2); % Traza linea en VERDE (Cinta despejada)
    end
    hold off;                      % Desactiva superposicion grafica
    title('Inspeccion sobre la Cinta Transportadora'); % Titulo
    
    subplot(2, 1, 2);              % Cuadrante inferior
    plot(dif_linea);               % Muestra curva de diferencia de intensidad
    axis();          % Escala fija para la senal
    grid on;                       % Activa rejilla
    title('Diferencia de Intensidad sobre la Linea de Control'); % Titulo
    
    drawnow;                       % Refresca renderizado
    
end % Fin del bucle de inspeccion dinamica

%% =========================================================================
% MODULO 7: Sistema automatizado de parada de cinta por presencia de pieza
% =========================================================================
% Proposito: Detener automaticamente la reproduccion del video al ingresar una nueva pieza,
% reanudando la marcha tras una pulsacion de tecla por parte del operador.

f7 = figure;                      % Inicializa nueva ventana grafica
set(f7, 'Name', 'Modulo 7: Parada Automatica por Deteccion de Presencia'); % Nombre de la figura

fin_reproduccion = 0;              % Reinicia bandera de control
f7.ButtonDownFcn = @PausarVideo;         % Asigna callback de pausa
f7.WindowScrollWheelFcn = @TerminarVideo; % Asigna callback de terminacion

v7 = VideoReader(fichero_video);   % Instancia objeto de lectura de video

% Adquisicion de referencia del fondo
im_ref7 = readFrame(v7);
im_ref7_hsv = rgb2hsv(im_ref7);
linea_referencia = im_ref7_hsv(100, 80:380, 3);

v7.CurrentTime = 0;                % Reinicia posicion del video
objeto_en_zona = false;            % Variable de estado (latch) para evitar pausas repetidas

while (not(fin_reproduccion) && hasFrame(v7))
    
    im_actual = readFrame(v7);     % Captura fotograma
    im_hsv_act = rgb2hsv(im_actual); % Convierte a HSV
    linea_nueva = im_hsv_act(100, 80:380, 3); % Extrae linea de control
    
    dif_linea = abs(linea_referencia - linea_nueva); % Calcula diferencia respecto a referencia
    
    subplot(2, 1, 1);              % Cuadrante superior
    imshow(im_actual);             % Muestra fotograma
    hold on;
    plot(, , '-g', 'LineWidth', 2); % Dibuja linea de control
    hold off;
    
    subplot(2, 1, 2);              % Cuadrante inferior
    plot(dif_linea);               % Dibuja perfil de diferencia
    axis();          % Ajusta limites
    grid on;                       % Activa rejilla
    title('Senal de Deteccion en Tiempo Real'); % Titulo
    
    drawnow;                       % Refresca renderizado
    
    % Condicion de disparo de parada: Pieza supera umbrales Y no estaba registrada previamente
    if (sum(dif_linea > umbral_intensidad) > umbral_conteo_pixeles) && ~objeto_en_zona
        disp('Pieza detectada en linea de control. Sistema en PAUSA (Pulse una tecla para continuar)...');
        objeto_en_zona = true;    % Activa memoria de estado de presencia
        pause;                     % Detiene el script hasta entrada por teclado
    end
    
    % Condicion de reinicio de estado: La pieza despeja completamente la linea de control
    if (sum(dif_linea > umbral_intensidad) < 5)
        objeto_en_zona = false;   % Libera la memoria de estado
    end
    
end % Fin del bucle de parada automatica

%% =========================================================================
% FUNCIONES AUXILIARES DE CONTROL DE EVENTOS DE INTERFAZ
% =========================================================================

function PausarVideo(~, ~)
    % Interrumpe o reanuda la ejecucion del script al hacer clic con el raton sobre la figura
    pause;
end

function TerminarVideo(~, ~)
    % Finaliza el bucle de video al desplazar la rueda del raton sobre la figura
    global fin_reproduccion;
    fin_reproduccion = 1;
end

% Fin del script
