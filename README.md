# 👁️ Visión por Computador en MATLAB

[![MATLAB](https://img.shields.io/badge/Language-MATLAB-orange.svg)](https://www.mathworks.com/)
[![Toolbox](https://img.shields.io/badge/Toolbox-Image_Processing-blue.svg)](https://www.mathworks.com/)

Repositorio con **11 módulos prácticos**
de Visión por Computador e Inspección
Industrial Automatizada en MATLAB.

---

## 📌 Tabla de Contenidos

- [Estructura del Repositorio](#-estructura-del-repositorio)
- [Resultados y Ejemplos Visuales](#-demostración-visual-y-resultados-ejecutados)
- [Nota sobre Funciones Propietarias (`_isa`)](#-nota-sobre-funciones-propietarias-_isa)
- [Requisitos del Sistema](#-requisitos-del-sistema)
- [Guía de Ejecución](#-guía-de-ejecución)

---

## 📁 Estructura del Repositorio

### **Módulo 01**
- **Archivo:** `01_fundamentos_procesamiento_imagenes_matlab.m`
- **Contenido:** Adquisición 2D/3D, mapas topográficos,
  perfiles, submuestreo y espacios RGB/HSV.

### **Módulo 02**
- **Archivo:** `02_adquisicion_video_deteccion_movimiento_cinta.m`
- **Contenido:** Procesamiento de vídeo en tiempo real,
  sensores virtuales y detección en cinta.

### **Módulo 03**
- **Archivo:** `03_calibracion_camara_proyeccion_medicion_3d.m`
- **Contenido:** Calibración K/M, rectificación
  de lentes (GoPro) y medición métrica 3D.

### **Módulo 04**
- **Archivo:** `04_herramientas_matematicas_lut_histograma_correlacion_fourier.m`
- **Contenido:** Transformaciones LUT, histogramas,
  correlación cruzada y FFT 2D.

### **Módulo 05**
- **Archivo:** `05_suavizado_filtrado_espacial_frecuencial_realce.m`
- **Contenido:** Ruido Gaussiano y Sal & Pimienta,
  filtros de media/mediana, ILPF/BLPF e igualación.

### **Módulo 06**
- **Archivo:** `06_deteccion_discontinuidades_sobel_laplaciana_pasosporcero.m`
- **Contenido:** Derivadas (Sobel, Canny, LoG),
  y Pasos por Cero en espacio y frecuencia.

### **Módulo 07**
- **Archivo:** `07_segmentacion_seguimiento_contornos_umbralizacion_hough.m`
- **Contenido:** Contornos, binarización de Otsu,
  umbral adaptativo y Hough (líneas/círculos).

### **Módulo 08**
- **Archivo:** `08_segmentacion_crecimiento_regiones_etiquetado_roi.m`
- **Contenido:** Crecimiento de regiones, `bwlabel`,
  centroides, área y selección ROI (`imrect`).

### **Módulo 09**
- **Archivo:** `09_descripcion_y_representacion_1_solucion.m`
- **Contenido:** Descriptores `regionprops`, cerco
  convexo, signaturas y adelgazamiento morfológico.

### **Módulo 10**
- **Archivo:** `10_descripcion_y_representacion_2.m`
- **Contenido:** Clasificación por número de Euler,
  inspección de piezas y OCR en displays LCD.

### **Módulo 11**
- **Archivo:** `11_reconocimiento_patrones_perceptron_medicamentos.m`
- **Contenido:** Perceptrón lineal en el espacio
  de patrones e inspección de blísteres.

---

## 🖼️ Demostración Visual y Resultados Ejecutados

Todos los módulos del repositorio han sido
probados y validados con éxito.

A continuación se presentan **4 ejemplos de
ejecución real** generados por el código:

---

### 1. Filtrado de Ruido y Restauración (Módulo 05)

Evaluación del tratamiento de perturbaciones
ópticas sobre componentes industriales.

El script genera contaminación sintética
(ruido Gaussiano y Sal & Pimienta)
y aplica técnicas de filtrado espacial
y frecuencial para su restauración.

<img width="401" height="105" alt="Filtros de ruido visual" src="https://github.com/user-attachments/assets/33e34329-01f8-4cd4-ac0e-add8f23e696f" />

*Figura 1: Muestra original y respuesta*
*ante filtros de eliminación de ruido.*

---

### 2. Segmentación, Etiquetado y Centroides (Módulo 08 / Módulo 09)

Procesamiento de escenas compuestas con
múltiples piezas mecánicas (`Parts00.png`).

Mediante etiquetado de componentes conectadas
y análisis geométrico, el código aísla la pieza,
calcula su área y ubica su centroide.

| Entrada (`Parts00.png`) | Centroide Detectado |
| :---: | :---: |
| <img width="384" height="269" alt="Parts00" src="https://github.com/user-attachments/assets/beaa749b-e0cd-4724-a71a-277f2471c47a" />| <img width="384" height="269" alt="identificacion de objetos" src="https://github.com/user-attachments/assets/cf09d538-7062-408d-90d9-b5a5ab27e71a" /> |

*Figura 2: Aislamiento del componente y*
*marcado de su centroide físico en rojo.*

---

### 3. Aislamiento de ROI y Extracción de Pines (Módulo 08)

En la inspección del conector DB15, el código
permite definir una ROI interactiva (`imrect`).

Genera máscaras binarias (`createMask`) para
extraer los pines sin ruido de fondo.

| Selección ROI | Pines Segmentados |
| :---: | :---: |
| <img width="385" height="284" alt="Pines seleccionados" src="https://github.com/user-attachments/assets/d2fcaab8-e26f-41fd-ae6d-7aadf473455b" /> | <img width="385" height="284" alt="Pines segmentados" src="https://github.com/user-attachments/assets/c6a299bc-5131-452a-8308-e51a2d87df95" />|


*Figura 3: Delimitación de región y*
*extracción limpia por enmascaramiento.*

---

### 4. Clasificación por Perceptrón (Módulo 11)

A partir de formas geométricas (cuadrados,
círculos y triángulos), se calculan
descriptores mediante signatura radial.

Los datos se proyectan en el espacio
de características, donde el Perceptrón
obtiene las fronteras de decisión.

| Muestra de Entrenamiento | Espacio Clasificado |
| :---: | :---: |
| <img width="518" height="138" alt="ejemplo de identificacion de patrones" src="https://github.com/user-attachments/assets/be05b93c-dd6c-4363-9e80-9e3066403b29" /> |<img width="548" height="330" alt="Clasificacion de elementos" src="https://github.com/user-attachments/assets/57ed98fe-3e41-43dc-bb67-8a88b3bbd26d" /> |

*Figura 4: Agrupamiento de las 3 clases*
*de objetos en el espacio 2D.*

---

## ⚠️ Nota sobre Funciones Propietarias (`_isa`)

En algunas soluciones académicas se utilizan
funciones con el sufijo **`_isa`**:
- `vercre_isa` / `cre_isa`
- `signatura_isa`
- `veradel_isa`
- `houghc_isa`
- `uglobal_isa`
- `perceptron_isa`

> **Aviso de Propiedad Intelectual:**
> Dichas funciones pertenecen al equipo
> docente de la UMA y **no están disponibles**
> en este repositorio por derechos de autor.

### Sustitución Independiente en MATLAB:

Para ejecutar los scripts de forma nativa:
- **`uglobal_isa`** \\(\rightarrow\\) `graythresh(im)`
- **`vercre_isa` / `cre_isa`** \\(\rightarrow\\) `bwselect` / `regiongrowing`
- **`veradel_isa`** \\(\rightarrow\\) `bwmorph(im, 'thin', inf)`
- **`houghc_isa`** \\(\rightarrow\\) `imfindcircles`
- **`signatura_isa`** \\(\rightarrow\\) Coordenadas polares con `bwboundaries`
- **`perceptron_isa`** \\(\rightarrow\\) Clasificador lineal estándar

---

## 🛠️ Requisitos del Sistema

- **MATLAB** (R2020b o superior)
- **Image Processing Toolbox**
- **Computer Vision Toolbox**

---

## 🚀 Guía de Ejecución

1. **Clonar el repositorio:**
   ```bash
   git clone https://github.com/tu_usuario/Vision-por-computador-y-procesamiento-de-imagenes.git
   cd Vision-por-computador-y-procesamiento-de-imagenes
   ```

2. **Abrir MATLAB** y añadir las carpetas
   con las imágenes de prueba al *Path*.

3. **Ejecutar cualquier módulo:**
   ```matlab
   run('01_fundamentos_procesamiento_imagenes_matlab.m')
   ```
