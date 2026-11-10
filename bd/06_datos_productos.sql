/*==============================================================*/
/* ATHLETIX - Datos completos de los productos en la base        */
/* (características, ficha técnica, etiqueta y fotos)            */
/*==============================================================*/
begin;

update producto set prd_etiqueta = 'Nuevo', prd_caracteristicas = 'Espuma RebotePlus con placa de propulsión
Malla técnica ultraligera y transpirable
Pensada para competencias de 5K a media maratón', prd_ficha = 'Peso: ≈230 g
Desnivel (drop): 8 mm
Amortiguación: RebotePlus + placa de nylon
Uso ideal: Competencia y ritmos rápidos
Tallas: 39 – 45 (EU)' where prd_codigo = 'vx';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Espuma NúcleoNube de doble densidad
Suela ancha que aporta estabilidad
Lengüeta y cuello acolchados', prd_ficha = 'Peso: ≈290 g
Desnivel (drop): 10 mm
Amortiguación: NúcleoNube doble densidad
Uso ideal: Rodajes largos y diarios
Tallas: 39 – 45 (EU)' where prd_codigo = 'sf';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Mediasuela FlexiLigera muy liviana
Malla transpirable de secado rápido
Detalles reflectivos para correr de noche', prd_ficha = 'Peso: ≈210 g
Desnivel (drop): 8 mm
Amortiguación: FlexiLigera
Uso ideal: Entrenamiento diario
Tallas: 36, 36.5, 37, 37.5, 38, 38.5, 39 y 40 (EU)' where prd_codigo = 'oc';
update producto set prd_etiqueta = 'Nuevo', prd_caracteristicas = 'Espuma ResorteLigero de alto retorno
Suela con relieve que mejora el agarre
Diseño de alta visibilidad', prd_ficha = 'Peso: ≈235 g
Desnivel (drop): 6 mm
Amortiguación: ResorteLigero reactiva
Uso ideal: Series y cambios de ritmo
Tallas: 36, 36.5, 37, 37.5, 38, 38.5, 39 y 40 (EU)' where prd_codigo = 'lr';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Tacos de 5 mm para barro y tierra
Puntera reforzada contra impactos
Parte superior resistente a la abrasión', prd_ficha = 'Peso: ≈310 g
Desnivel (drop): 6 mm
Tracción: TacoAgarre de 5 mm
Uso ideal: Montaña, barro y tierra
Tallas: 37 – 45 (EU)' where prd_codigo = 'tn';
update producto set prd_etiqueta = null, prd_caracteristicas = 'GPS de doble frecuencia para rutas precisas
Pantalla AMOLED de 1.4" visible al sol
Hasta 14 días de batería', prd_ficha = 'Pantalla: AMOLED 1.4"
Batería: Hasta 14 días (30 h con GPS)
GPS: Doble frecuencia
Mide: Ritmo, distancia y frecuencia cardiaca
Resistencia al agua: 5 ATM' where prd_codigo = 'pt';
update producto set prd_etiqueta = 'Nuevo', prd_caracteristicas = 'Conducción ósea: oídos libres y atentos
Arco de titanio flexible y liviano
Resistentes al sudor y la lluvia (IP67)', prd_ficha = 'Tipo: Conducción ósea
Batería: Hasta 8 h
Conexión: Bluetooth 5.3
Resistencia: IP67
Peso: ≈29 g' where prd_codigo = 'sa';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Medición de frecuencia cardiaca tipo ECG
Conexión Bluetooth y ANT+
Correa elástica lavable y ajustable', prd_ficha = 'Mide: Frecuencia cardiaca (tipo ECG)
Batería: Hasta 400 h (pila CR2032)
Conexión: Bluetooth y ANT+
Resistencia: Al agua, 3 ATM
Ajuste: Correa de 65 a 110 cm' where prd_codigo = 'cb';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Analiza cadencia y longitud de zancada
Clip universal para cualquier zapatilla
Funciona incluso en cinta de correr', prd_ficha = 'Mide: Cadencia, zancada y tiempo de contacto
Batería: Hasta 20 h, recargable
Conexión: Bluetooth
Montaje: Clip en los cordones
Peso: ≈12 g' where prd_codigo = 'sp';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Incluye 2 botellas de 300 ml
Bolsillo con cierre para celular de hasta 6.7"
Detalles reflectivos y ajuste sin rebote', prd_ficha = 'Capacidad: 2 botellas de 300 ml
Bolsillo: Celular de hasta 6.7"
Ajuste: Cintura de 65 a 110 cm
Visibilidad: Detalles reflectivos
Material: Lycra transpirable' where prd_codigo = 'hb';
update producto set prd_etiqueta = 'Nuevo', prd_caracteristicas = 'Pantalla AMOLED redonda de 1.32"
Mide frecuencia cardiaca, pasos, calorías y sueño
Correa de silicona suave e hipoalergénica', prd_ficha = 'Pantalla: AMOLED redonda 1.32"
Batería: Hasta 10 días
Mide: FC, pasos, calorías y sueño
Resistencia al agua: 5 ATM
Correa: Silicona, ajustable de 14 a 20 cm' where prd_codigo = 'au';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Escalera de 12 peldaños ajustables
4 vallas y 4 conos para armar circuitos
Incluye bolsa de transporte', prd_ficha = 'Escalera: 6 m · 12 peldaños
Vallas: 4 unidades de 15 cm
Conos: 4 unidades
Incluye: Bolsa de transporte
Uso ideal: Velocidad y coordinación' where prd_codigo = 'at';
update producto set prd_etiqueta = 'Nuevo', prd_caracteristicas = 'Peso ajustable con placas extraíbles
Correas laterales que evitan el rebote
Tela resistente y acolchada', prd_ficha = 'Peso: Ajustable hasta 10 kg
Talla: Única, ajustable
Cierre: Correas laterales con velcro
Material: Nylon reforzado
Uso ideal: Fuerza, carrera y saltos' where prd_codigo = 'pv';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Resistencia progresiva al acelerar
Cinturón con liberación rápida
Se guarda plegado en segundos', prd_ficha = 'Diámetro: 142 cm
Cinturón: Ajustable con liberación rápida
Resistencia: Aumenta con tu velocidad
Incluye: Bolsa para guardarlo
Uso ideal: Carreras cortas y arranques' where prd_codigo = 'sc';
update producto set prd_etiqueta = null, prd_caracteristicas = '5 niveles de resistencia por color
Látex natural resistente
Bolsa de transporte incluida', prd_ficha = 'Contenido: 5 bandas de látex
Resistencia: De 5 a 40 kg aprox.
Medida: 60 × 5 cm
Incluye: Bolsa de tela
Uso ideal: Fuerza y movilidad' where prd_codigo = 'fl';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Superficie texturizada antideslizante
Rebote controlado para lanzamientos
Resistente a golpes y caídas', prd_ficha = 'Peso: 6 kg
Diámetro: ≈28 cm
Superficie: Texturizada antideslizante
Material: Caucho reforzado
Uso ideal: Abdomen y fuerza funcional' where prd_codigo = 'cm';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Amortiguación GEL para mayor confort
Malla transpirable en la parte superior
Gran estabilidad en cada zancada', prd_ficha = 'Amortiguación: GEL + espuma FF Blast
Peso: ≈300 g
Desnivel (drop): 10 mm
Uso ideal: Rodajes largos y estabilidad
Tallas: 39 – 45 (EU)' where prd_codigo = 'zh01';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Amortiguación ReactX suave y reactiva
Malla engineered transpirable
Ideal para entrenamientos y competencias', prd_ficha = 'Amortiguación: ReactX
Peso: ≈285 g
Desnivel (drop): 10 mm
Uso ideal: Entrenamiento diario
Tallas: 39 – 45 (EU)' where prd_codigo = 'zh02';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Tecnología Wave para mayor estabilidad
Malla AIRmesh ultraligera
Respuesta firme en cada paso', prd_ficha = 'Amortiguación: Mizuno Enerzy + placa Wave
Peso: ≈290 g
Desnivel (drop): 12 mm
Uso ideal: Uso diario y distancias medias
Tallas: 39 – 45 (EU)' where prd_codigo = 'zh03';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Suela Contagrip de máximo agarre
Amortiguación EnergyFoam
Ideal para asfalto y montaña', prd_ficha = 'Amortiguación: EnergyFoam
Peso: ≈300 g
Desnivel (drop): 8 mm
Uso ideal: Trail y terrenos mixtos
Tallas: 39 – 45 (EU)' where prd_codigo = 'zh04';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Ligereza y alta respuesta
Malla transpirable ultraligera
Diseñada para ritmos rápidos', prd_ficha = 'Amortiguación: Lightstrike Pro + varillas EnergyRods
Peso: ≈260 g
Desnivel (drop): 6 mm
Uso ideal: Series y competencia
Tallas: 39 – 45 (EU)' where prd_codigo = 'zh05';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Amortiguación PWRRUN+
Malla transpirable y cómoda
Transición suave en cada zancada', prd_ficha = 'Amortiguación: PWRRUN+
Peso: ≈275 g
Desnivel (drop): 8 mm
Uso ideal: Versatilidad
Tallas: 39 – 45 (EU)' where prd_codigo = 'zh06';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Amortiguación máxima y ligera
Malla jacquard transpirable
Comodidad en largas distancias', prd_ficha = 'Amortiguación: Espuma CMEVA de alto volumen
Peso: ≈250 g
Desnivel (drop): 5 mm
Uso ideal: Largas distancias
Tallas: 39 – 45 (EU)' where prd_codigo = 'zh07';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Amortiguación DNA LOFT
Ajuste cómodo y seguro
Ideal para entrenamientos diarios y carreras', prd_ficha = 'Amortiguación: DNA LOFT v3
Peso: ≈285 g
Desnivel (drop): 12 mm
Uso ideal: Entrenamiento diario
Tallas: 39 – 45 (EU)' where prd_codigo = 'zh08';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Soporte DUOMAX para mayor estabilidad
Malla superior transpirable
Perfecta para corredores de todos los niveles', prd_ficha = 'Amortiguación: FF Blast Plus + GEL
Peso: ≈285 g
Desnivel (drop): 8 mm
Uso ideal: Pisada pronadora
Tallas: 39 – 45 (EU)' where prd_codigo = 'zh09';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Amortiguación HOVR de retorno de energía
Malla ligera y transpirable
Máximo confort en largas distancias', prd_ficha = 'Amortiguación: HOVR + Flow
Peso: ≈280 g
Desnivel (drop): 8 mm
Uso ideal: Rodajes largos
Tallas: 39 – 45 (EU)' where prd_codigo = 'zh10';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Amortiguación FF Blast+ de larga duración
Soporte y estabilidad para mayor control
Ideal para entrenamientos y carreras largas', prd_ficha = 'Amortiguación: GEL + FF Blast+
Peso: ≈260 g
Desnivel (drop): 10 mm
Uso ideal: Rodajes largos y estabilidad
Tallas: 35 – 41 (EU)' where prd_codigo = 'zm01';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Amortiguación ReactX con retorno de energía
Malla transpirable ultraligera
Perfecta para entrenamientos diarios y carreras', prd_ficha = 'Amortiguación: ReactX
Peso: ≈240 g
Desnivel (drop): 10 mm
Uso ideal: Entrenamiento diario
Tallas: 35 – 41 (EU)' where prd_codigo = 'zm02';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Tecnología Mizuno Wave para mayor estabilidad
Amortiguación suave y reactiva
Ideal para distancias medias y largas', prd_ficha = 'Amortiguación: Mizuno Enerzy + placa Wave
Peso: ≈245 g
Desnivel (drop): 12 mm
Uso ideal: Distancias medias y largas
Tallas: 35 – 41 (EU)' where prd_codigo = 'zm03';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Fresh Foam X ultra suave
Malla de ingeniería transpirable
Ideal para carreras largas y uso diario', prd_ficha = 'Amortiguación: Fresh Foam X
Peso: ≈250 g
Desnivel (drop): 6 mm
Uso ideal: Máxima comodidad
Tallas: 35 – 41 (EU)' where prd_codigo = 'zm04';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Ligereza y gran respuesta
Suela Lightstrike ultraligera
Ideal para mejorar tu ritmo y velocidad', prd_ficha = 'Amortiguación: Lightstrike + Lightstrike Pro
Peso: ≈225 g
Desnivel (drop): 8 mm
Uso ideal: Velocidad
Tallas: 35 – 41 (EU)' where prd_codigo = 'zm05';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Amortiguación PWRRUN+ para mayor confort
Malla transpirable y ligera
Ideal para todo tipo de entrenamientos', prd_ficha = 'Amortiguación: PWRRUN+
Peso: ≈240 g
Desnivel (drop): 8 mm
Uso ideal: Versatilidad
Tallas: 35 – 41 (EU)' where prd_codigo = 'zm06';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Amortiguación máxima con suela EVA
Gran ligereza y flexibilidad
Ideal para largas distancias y recuperación', prd_ficha = 'Amortiguación: Espuma CMEVA de alto volumen
Peso: ≈205 g
Desnivel (drop): 5 mm
Uso ideal: Largas distancias
Tallas: 35 – 41 (EU)' where prd_codigo = 'zm07';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Amortiguación DNA LOFT
Transiciones suaves y estables
Excelente para entrenamientos diarios y carreras', prd_ficha = 'Amortiguación: DNA LOFT v3
Peso: ≈255 g
Desnivel (drop): 12 mm
Uso ideal: Entrenamiento diario
Tallas: 35 – 41 (EU)' where prd_codigo = 'zm08';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Soporte Dynamic DUOMAX para mayor estabilidad
Amortiguación FF Blast+
Ideal para corredoras con pronación', prd_ficha = 'Amortiguación: FF Blast+ + GEL
Peso: ≈250 g
Desnivel (drop): 8 mm
Uso ideal: Pisada pronadora
Tallas: 35 – 41 (EU)' where prd_codigo = 'zm09';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Amortiguación HOVR de retorno de energía
Malla ligera y transpirable
Ideal para entrenamientos y competencias', prd_ficha = 'Amortiguación: HOVR + Flow
Peso: ≈240 g
Desnivel (drop): 8 mm
Uso ideal: Entrenamiento y competencia
Tallas: 35 – 41 (EU)' where prd_codigo = 'zm10';
update producto set prd_etiqueta = null, prd_caracteristicas = 'GPS integrado para registrar tus rutas
Pulso en la muñeca las 24 horas
Hasta 10 días de batería', prd_ficha = 'Pantalla: AMOLED redonda 1.3''
GPS: Integrado
Mide: Ritmo, distancia, tiempo y pulso
Batería: Hasta 10 días
Resistencia al agua: 5 ATM' where prd_codigo = 'tm01';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Ajuste firme que no se cae al correr
Resistentes al sudor y a la lluvia
Estuche de carga incluido', prd_ficha = 'Conexión: Bluetooth 5.3
Batería: 6 h + 24 h con estuche
Resistencia: IPX5 (sudor y lluvia)
Incluye: Estuche de carga y almohadillas
Uso ideal: Correr y gimnasio' where prd_codigo = 'tm02';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Pasos, sueño y frecuencia cardiaca
Pantalla a color fácil de leer
Hasta 14 días de batería', prd_ficha = 'Pantalla: AMOLED 1.1''
Mide: Pasos, sueño, pulso y calorías
Batería: Hasta 14 días
Resistencia al agua: 5 ATM
Compatible: Android y iPhone' where prd_codigo = 'tm03';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Mide sueño, actividad y recuperación
Diseño discreto de titanio
Hasta 6 días de batería', prd_ficha = 'Material: Titanio, acabado oro rosa
Mide: Sueño, pulso, temperatura y actividad
Batería: Hasta 6 días
Resistencia al agua: 10 ATM
Incluye: Base de carga' where prd_codigo = 'tm07';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Analizan pisada y presión del pie
Datos en tiempo real en la app
Recargables por USB', prd_ficha = 'Sensores: Presión en 3 zonas del pie
Mide: Pisada, cadencia y tiempo de contacto
Batería: Hasta 20 h de uso
Tallas: Recortables 35 – 41
Compatible: Android y iPhone' where prd_codigo = 'tm08';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Botón SOS con ubicación compartida
Alarma de 120 dB
Clip para cintura o brazo', prd_ficha = 'Funciones: SOS, ubicación y alarma
Alarma: 120 dB
Batería: Hasta 7 días
Montaje: Clip y correa
Compatible: App en el celular' where prd_codigo = 'tm09';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Recordatorios de hidratación con luz
Registro de consumo en la app
Acero inoxidable con doble pared', prd_ficha = 'Capacidad: 600 ml
Material: Acero inoxidable
Mantiene frío: Hasta 12 h
Batería: Hasta 14 días
Compatible: Android y iPhone' where prd_codigo = 'tm10';
update producto set prd_etiqueta = null, prd_caracteristicas = '5 niveles de intensidad
4 cabezales intercambiables
Silenciosa y liviana', prd_ficha = 'Velocidades: 5 niveles
Cabezales: 4 incluidos
Batería: Hasta 4 h
Peso: ≈450 g
Uso ideal: Recuperación muscular' where prd_codigo = 'tm11';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Sensor cardiaco integrado en la tela
Tela transpirable de secado rápido
Compatible con relojes y apps', prd_ficha = 'Mide: Frecuencia cardiaca
Conexión: Bluetooth y ANT+
Tela: Poliamida y elastano
Tallas: S, M, L
Lavado: Lavable (retirando el sensor)' where prd_codigo = 'tm12';
update producto set prd_etiqueta = null, prd_caracteristicas = '3 modos: fija, intermitente y suave
Recargable por USB-C
Clip firme para ropa o mochila', prd_ficha = 'Modos: 3
Batería: Hasta 8 h
Carga: USB-C
Resistencia: IPX4 (lluvia)
Peso: ≈30 g' where prd_codigo = 'tm13';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Conexión magnética fácil
Cable USB de 1 m incluido
Diseño compacto para el escritorio', prd_ficha = 'Tipo: Base magnética
Cable: USB de 1 m
Material: Silicona y aluminio
Compatible: Relojes deportivos con carga de pines
Incluye: Base y cable' where prd_codigo = 'tm14';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Memoria de vueltas y parciales
Temporizador de intervalos
Resistente al agua', prd_ficha = 'Memoria: 100 vueltas
Precisión: 1/100 s
Funciones: Cronómetro, intervalos y alarma
Resistencia al agua: 3 ATM
Batería: Pila de botón (1 año)' where prd_codigo = 'tm15';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Ganchos de ajuste seguro
Resistentes al sudor y al agua
Estuche de carga incluido', prd_ficha = 'Conexión: Bluetooth 5.3
Batería: 8 h + 30 h con estuche
Resistencia: IPX7
Incluye: Estuche y almohadillas
Uso ideal: Correr y gimnasio' where prd_codigo = 'th02';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Actividad, pulso y sueño
Más de 100 modos deportivos
Hasta 14 días de batería', prd_ficha = 'Pantalla: AMOLED 1.6''
Mide: Pasos, pulso, sueño y oxígeno
Batería: Hasta 14 días
Resistencia al agua: 5 ATM
Compatible: Android y iPhone' where prd_codigo = 'th03';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Mide potencia de carrera en vatios
Se engancha a los cordones
Compatible con relojes deportivos', prd_ficha = 'Mide: Potencia, cadencia y zancada
Conexión: Bluetooth y ANT+
Batería: Hasta 40 h
Peso: ≈15 g
Resistencia: IP67' where prd_codigo = 'th05';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Mide sueño, pulso y recuperación
Diseño resistente de titanio
Hasta 6 días de batería', prd_ficha = 'Material: Titanio negro
Mide: Sueño, pulso, temperatura y actividad
Batería: Hasta 6 días
Resistencia al agua: 10 ATM
Incluye: Base de carga' where prd_codigo = 'th07';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Analizan pisada y presión
Datos en tiempo real en la app
Recargables por USB', prd_ficha = 'Sensores: Presión en 3 zonas del pie
Mide: Pisada, cadencia y tiempo de contacto
Batería: Hasta 20 h de uso
Tallas: Recortables 39 – 45
Compatible: Android y iPhone' where prd_codigo = 'th08';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Video 4K estabilizado
Resistente al agua sin carcasa
Pantalla doble para encuadrarte', prd_ficha = 'Video: 4K a 60 fps
Estabilización: Electrónica
Resistencia al agua: Hasta 10 m
Batería: ≈90 min de grabación
Incluye: Soporte y batería' where prd_codigo = 'th09';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Ubicación en tiempo real
Botón de emergencia
Batería de larga duración', prd_ficha = 'Funciones: Ubicación y SOS
Conectividad: GPS y red móvil
Batería: Hasta 7 días
Resistencia: IP67
Uso ideal: Trail y entrenamientos al aire libre' where prd_codigo = 'th10';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Recordatorios de hidratación
Registro de consumo en la app
Acero inoxidable con doble pared', prd_ficha = 'Capacidad: 700 ml
Material: Acero inoxidable
Mantiene frío: Hasta 12 h
Batería: Hasta 14 días
Compatible: Android y iPhone' where prd_codigo = 'th11';
update producto set prd_etiqueta = null, prd_caracteristicas = '6 niveles de intensidad
4 cabezales intercambiables
Motor potente y silencioso', prd_ficha = 'Velocidades: 6 niveles
Cabezales: 4 incluidos
Batería: Hasta 5 h
Peso: ≈800 g
Uso ideal: Recuperación muscular' where prd_codigo = 'th12';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Hasta 400 lúmenes
Recargable por USB-C
Banda elástica cómoda', prd_ficha = 'Potencia: 400 lúmenes
Modos: 4 (incluye luz roja)
Batería: Hasta 10 h
Resistencia: IPX4 (lluvia)
Peso: ≈80 g' where prd_codigo = 'th14';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Memoria de vueltas y parciales
Precisión de 1/100 s
Diseño robusto y resistente', prd_ficha = 'Memoria: 200 vueltas
Precisión: 1/100 s
Funciones: Cronómetro, parciales e intervalos
Resistencia al agua: 5 ATM
Batería: Pila de botón (2 años)' where prd_codigo = 'th15';
update producto set prd_etiqueta = null, prd_caracteristicas = '3 alturas en un solo cajón
Superficie antideslizante
Estructura firme y estable', prd_ficha = 'Alturas: 50, 60 y 75 cm
Material: Madera reforzada
Carga máxima: 150 kg
Superficie: Antideslizante
Uso ideal: Saltos y potencia' where prd_codigo = 'en07';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Inclinación ajustable
Base metálica estable
Pedales con superficie de agarre', prd_ficha = 'Material: Aluminio y acero
Ajuste: Distancia e inclinación
Pedales: Antideslizantes
Peso: ≈6 kg
Uso ideal: Salidas de velocidad' where prd_codigo = 'en08';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Fotoceldas de alta precisión
Trípodes ajustables incluidos
Resultados en el celular', prd_ficha = 'Precisión: 1/1000 s
Incluye: 2 fotoceldas y 2 trípodes
Alcance: Hasta 50 m
Batería: Hasta 10 h
Conexión: Bluetooth' where prd_codigo = 'en09';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Cinturón acolchado y ajustable
Cuerda elástica de alta resistencia
Liberación rápida', prd_ficha = 'Cinturón: Ajustable 65 – 120 cm
Cuerda: Elástica 3 m
Resistencia: Media – alta
Material: Nylon y látex
Uso ideal: Aceleraciones y sprints' where prd_codigo = 'en10';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Rodamientos para giros rápidos
Largo ajustable
Mangos ergonómicos', prd_ficha = 'Cable: Acero recubierto
Largo: Hasta 3 m (ajustable)
Mangos: Aluminio con agarre
Peso: ≈180 g
Uso ideal: Cardio y coordinación' where prd_codigo = 'en11';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Superficie con relieve de 3 zonas
Núcleo rígido que no se deforma
Liviano y fácil de llevar', prd_ficha = 'Medida: 33 × 14 cm
Material: EVA sobre núcleo rígido
Carga máxima: 150 kg
Peso: ≈700 g
Uso ideal: Automasaje y movilidad' where prd_codigo = 'en12';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Superficie antideslizante
Base que gira en 360°
Ayuda a prevenir lesiones', prd_ficha = 'Diámetro: 40 cm
Material: Madera con superficie de goma
Inclinación: Hasta 15°
Carga máxima: 150 kg
Uso ideal: Equilibrio y tobillos' where prd_codigo = 'en13';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Tobilleras acolchadas con velcro
Bandas de distintas resistencias
Ideal para casa o gimnasio', prd_ficha = 'Contenido: 2 tobilleras y 3 bandas
Resistencia: Ligera, media y fuerte
Ajuste: Velcro
Material: Neopreno y látex
Uso ideal: Piernas y glúteos' where prd_codigo = 'en14';
update producto set prd_etiqueta = null, prd_caracteristicas = 'Estructura de acero resistente
Admite discos de peso
Para empujar o arrastrar', prd_ficha = 'Material: Acero
Peso propio: ≈12 kg
Carga: Discos de hasta 100 kg
Superficie: Césped y pista
Uso ideal: Fuerza y aceleración' where prd_codigo = 'en15';

insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values
  ('vx', 1, 'img/productos/vx-1.jpg', 'vista principal'),
  ('vx', 2, 'img/productos/vx-2.jpg', 'vista del otro lado'),
  ('vx', 3, 'img/productos/vx-3.jpg', 'detalle de la suela'),
  ('sf', 1, 'img/productos/sf-1.jpg', 'vista principal'),
  ('sf', 2, 'img/productos/sf-2.jpg', 'vista del otro lado'),
  ('sf', 3, 'img/productos/sf-3.jpg', 'detalle de la suela'),
  ('oc', 1, 'img/productos/oc-1.jpg', 'vista principal'),
  ('oc', 2, 'img/productos/oc-2.jpg', 'vista del otro lado'),
  ('oc', 3, 'img/productos/oc-3.jpg', 'detalle de la suela'),
  ('lr', 1, 'img/productos/lr-1.jpg', 'vista principal'),
  ('lr', 2, 'img/productos/lr-2.jpg', 'vista del otro lado'),
  ('lr', 3, 'img/productos/lr-3.jpg', 'detalle de la suela'),
  ('tn', 1, 'img/productos/tn-1.jpg', 'vista principal'),
  ('tn', 2, 'img/productos/tn-2.jpg', 'vista del otro lado'),
  ('tn', 3, 'img/productos/tn-3.jpg', 'detalle de la suela'),
  ('pt', 1, 'img/productos/pt-1.jpg', 'vista principal'),
  ('pt', 2, 'img/productos/pt-2.jpg', 'pantalla'),
  ('pt', 3, 'img/productos/pt-3.jpg', 'correa'),
  ('sa', 1, 'img/productos/sa-1.jpg', 'vista principal'),
  ('sa', 2, 'img/productos/sa-2.jpg', 'auricular'),
  ('sa', 3, 'img/productos/sa-3.jpg', 'arco'),
  ('cb', 1, 'img/productos/cb-1.jpg', 'vista principal'),
  ('cb', 2, 'img/productos/cb-2.jpg', 'sensor'),
  ('cb', 3, 'img/productos/cb-3.jpg', 'broche'),
  ('sp', 1, 'img/productos/sp-1.jpg', 'vista principal'),
  ('sp', 2, 'img/productos/sp-2.jpg', 'clip'),
  ('sp', 3, 'img/productos/sp-3.jpg', 'sensor'),
  ('hb', 1, 'img/productos/hb-1.jpg', 'vista principal'),
  ('hb', 2, 'img/productos/hb-2.jpg', 'botella'),
  ('hb', 3, 'img/productos/hb-3.jpg', 'bolsillo'),
  ('au', 1, 'img/productos/au-1.jpg', 'vista principal'),
  ('au', 2, 'img/productos/au-2.jpg', 'pantalla'),
  ('au', 3, 'img/productos/au-3.jpg', 'correa'),
  ('at', 1, 'img/productos/at-1.jpg', 'kit completo'),
  ('at', 2, 'img/productos/at-2.jpg', 'escalera'),
  ('at', 3, 'img/productos/at-3.jpg', 'vallas y conos'),
  ('pv', 1, 'img/productos/pv-1.jpg', 'vista principal'),
  ('pv', 2, 'img/productos/pv-2.jpg', 'bolsillos de peso'),
  ('pv', 3, 'img/productos/pv-3.jpg', 'hombros'),
  ('sc', 1, 'img/productos/sc-1.jpg', 'vista principal'),
  ('sc', 2, 'img/productos/sc-2.jpg', 'paracaídas'),
  ('sc', 3, 'img/productos/sc-3.jpg', 'cinturón'),
  ('fl', 1, 'img/productos/fl-1.jpg', 'set completo'),
  ('fl', 2, 'img/productos/fl-2.jpg', 'bolsa'),
  ('fl', 3, 'img/productos/fl-3.jpg', 'bandas'),
  ('cm', 1, 'img/productos/cm-1.jpg', 'vista principal'),
  ('cm', 2, 'img/productos/cm-2.jpg', 'textura'),
  ('cm', 3, 'img/productos/cm-3.jpg', 'agarre'),
  ('zh01', 1, 'img/productos/zh01-1.jpg', 'vista principal'),
  ('zh01', 2, 'img/productos/zh01-2.jpg', 'detalle de la puntera'),
  ('zh01', 3, 'img/productos/zh01-3.jpg', 'detalle del talón'),
  ('zh02', 1, 'img/productos/zh02-1.jpg', 'vista principal'),
  ('zh02', 2, 'img/productos/zh02-2.jpg', 'detalle de la puntera'),
  ('zh02', 3, 'img/productos/zh02-3.jpg', 'detalle del talón'),
  ('zh03', 1, 'img/productos/zh03-1.jpg', 'vista principal'),
  ('zh03', 2, 'img/productos/zh03-2.jpg', 'detalle de la puntera'),
  ('zh03', 3, 'img/productos/zh03-3.jpg', 'detalle del talón'),
  ('zh04', 1, 'img/productos/zh04-1.jpg', 'vista principal'),
  ('zh04', 2, 'img/productos/zh04-2.jpg', 'detalle de la puntera'),
  ('zh04', 3, 'img/productos/zh04-3.jpg', 'detalle del talón'),
  ('zh05', 1, 'img/productos/zh05-1.jpg', 'vista principal'),
  ('zh05', 2, 'img/productos/zh05-2.jpg', 'detalle de la puntera'),
  ('zh05', 3, 'img/productos/zh05-3.jpg', 'detalle del talón'),
  ('zh06', 1, 'img/productos/zh06-1.jpg', 'vista principal'),
  ('zh06', 2, 'img/productos/zh06-2.jpg', 'detalle de la puntera'),
  ('zh06', 3, 'img/productos/zh06-3.jpg', 'detalle del talón'),
  ('zh07', 1, 'img/productos/zh07-1.jpg', 'vista principal'),
  ('zh07', 2, 'img/productos/zh07-2.jpg', 'detalle de la puntera'),
  ('zh07', 3, 'img/productos/zh07-3.jpg', 'detalle del talón'),
  ('zh08', 1, 'img/productos/zh08-1.jpg', 'vista principal'),
  ('zh08', 2, 'img/productos/zh08-2.jpg', 'detalle de la puntera'),
  ('zh08', 3, 'img/productos/zh08-3.jpg', 'detalle del talón'),
  ('zh09', 1, 'img/productos/zh09-1.jpg', 'vista principal'),
  ('zh09', 2, 'img/productos/zh09-2.jpg', 'detalle de la puntera'),
  ('zh09', 3, 'img/productos/zh09-3.jpg', 'detalle del talón'),
  ('zh10', 1, 'img/productos/zh10-1.jpg', 'vista principal'),
  ('zh10', 2, 'img/productos/zh10-2.jpg', 'detalle de la puntera'),
  ('zh10', 3, 'img/productos/zh10-3.jpg', 'detalle del talón'),
  ('zm01', 1, 'img/productos/zm01-1.jpg', 'vista principal'),
  ('zm01', 2, 'img/productos/zm01-2.jpg', 'detalle de la puntera'),
  ('zm01', 3, 'img/productos/zm01-3.jpg', 'detalle del talón'),
  ('zm02', 1, 'img/productos/zm02-1.jpg', 'vista principal'),
  ('zm02', 2, 'img/productos/zm02-2.jpg', 'detalle de la puntera'),
  ('zm02', 3, 'img/productos/zm02-3.jpg', 'detalle del talón'),
  ('zm03', 1, 'img/productos/zm03-1.jpg', 'vista principal'),
  ('zm03', 2, 'img/productos/zm03-2.jpg', 'detalle de la puntera'),
  ('zm03', 3, 'img/productos/zm03-3.jpg', 'detalle del talón'),
  ('zm04', 1, 'img/productos/zm04-1.jpg', 'vista principal'),
  ('zm04', 2, 'img/productos/zm04-2.jpg', 'detalle de la puntera'),
  ('zm04', 3, 'img/productos/zm04-3.jpg', 'detalle del talón'),
  ('zm05', 1, 'img/productos/zm05-1.jpg', 'vista principal'),
  ('zm05', 2, 'img/productos/zm05-2.jpg', 'detalle de la puntera'),
  ('zm05', 3, 'img/productos/zm05-3.jpg', 'detalle del talón'),
  ('zm06', 1, 'img/productos/zm06-1.jpg', 'vista principal'),
  ('zm06', 2, 'img/productos/zm06-2.jpg', 'detalle de la puntera'),
  ('zm06', 3, 'img/productos/zm06-3.jpg', 'detalle del talón'),
  ('zm07', 1, 'img/productos/zm07-1.jpg', 'vista principal'),
  ('zm07', 2, 'img/productos/zm07-2.jpg', 'detalle de la puntera'),
  ('zm07', 3, 'img/productos/zm07-3.jpg', 'detalle del talón'),
  ('zm08', 1, 'img/productos/zm08-1.jpg', 'vista principal'),
  ('zm08', 2, 'img/productos/zm08-2.jpg', 'detalle de la puntera'),
  ('zm08', 3, 'img/productos/zm08-3.jpg', 'detalle del talón'),
  ('zm09', 1, 'img/productos/zm09-1.jpg', 'vista principal'),
  ('zm09', 2, 'img/productos/zm09-2.jpg', 'detalle de la puntera'),
  ('zm09', 3, 'img/productos/zm09-3.jpg', 'detalle del talón'),
  ('zm10', 1, 'img/productos/zm10-1.jpg', 'vista principal'),
  ('zm10', 2, 'img/productos/zm10-2.jpg', 'detalle de la puntera'),
  ('zm10', 3, 'img/productos/zm10-3.jpg', 'detalle del talón'),
  ('tm01', 1, 'img/productos/tm01-1.jpg', 'vista principal'),
  ('tm01', 2, 'img/productos/tm01-2.jpg', 'detalle superior'),
  ('tm01', 3, 'img/productos/tm01-3.jpg', 'detalle inferior'),
  ('tm02', 1, 'img/productos/tm02-1.jpg', 'vista principal'),
  ('tm02', 2, 'img/productos/tm02-2.jpg', 'detalle superior'),
  ('tm02', 3, 'img/productos/tm02-3.jpg', 'detalle inferior'),
  ('tm03', 1, 'img/productos/tm03-1.jpg', 'vista principal'),
  ('tm03', 2, 'img/productos/tm03-2.jpg', 'detalle superior'),
  ('tm03', 3, 'img/productos/tm03-3.jpg', 'detalle inferior'),
  ('tm07', 1, 'img/productos/tm07-1.jpg', 'vista principal'),
  ('tm07', 2, 'img/productos/tm07-2.jpg', 'detalle superior'),
  ('tm07', 3, 'img/productos/tm07-3.jpg', 'detalle inferior'),
  ('tm08', 1, 'img/productos/tm08-1.jpg', 'vista principal'),
  ('tm08', 2, 'img/productos/tm08-2.jpg', 'detalle superior'),
  ('tm08', 3, 'img/productos/tm08-3.jpg', 'detalle inferior'),
  ('tm09', 1, 'img/productos/tm09-1.jpg', 'vista principal'),
  ('tm09', 2, 'img/productos/tm09-2.jpg', 'detalle superior'),
  ('tm09', 3, 'img/productos/tm09-3.jpg', 'detalle inferior'),
  ('tm10', 1, 'img/productos/tm10-1.jpg', 'vista principal'),
  ('tm10', 2, 'img/productos/tm10-2.jpg', 'detalle superior'),
  ('tm10', 3, 'img/productos/tm10-3.jpg', 'detalle inferior'),
  ('tm11', 1, 'img/productos/tm11-1.jpg', 'vista principal'),
  ('tm11', 2, 'img/productos/tm11-2.jpg', 'detalle superior'),
  ('tm11', 3, 'img/productos/tm11-3.jpg', 'detalle inferior'),
  ('tm12', 1, 'img/productos/tm12-1.jpg', 'vista principal'),
  ('tm12', 2, 'img/productos/tm12-2.jpg', 'detalle superior'),
  ('tm12', 3, 'img/productos/tm12-3.jpg', 'detalle inferior'),
  ('tm13', 1, 'img/productos/tm13-1.jpg', 'vista principal'),
  ('tm13', 2, 'img/productos/tm13-2.jpg', 'detalle superior'),
  ('tm13', 3, 'img/productos/tm13-3.jpg', 'detalle inferior'),
  ('tm14', 1, 'img/productos/tm14-1.jpg', 'vista principal'),
  ('tm14', 2, 'img/productos/tm14-2.jpg', 'detalle superior'),
  ('tm14', 3, 'img/productos/tm14-3.jpg', 'detalle inferior'),
  ('tm15', 1, 'img/productos/tm15-1.jpg', 'vista principal'),
  ('tm15', 2, 'img/productos/tm15-2.jpg', 'detalle superior'),
  ('tm15', 3, 'img/productos/tm15-3.jpg', 'detalle inferior'),
  ('th02', 1, 'img/productos/th02-1.jpg', 'vista principal'),
  ('th02', 2, 'img/productos/th02-2.jpg', 'detalle superior'),
  ('th02', 3, 'img/productos/th02-3.jpg', 'detalle inferior'),
  ('th03', 1, 'img/productos/th03-1.jpg', 'vista principal'),
  ('th03', 2, 'img/productos/th03-2.jpg', 'detalle superior'),
  ('th03', 3, 'img/productos/th03-3.jpg', 'detalle inferior'),
  ('th05', 1, 'img/productos/th05-1.jpg', 'vista principal'),
  ('th05', 2, 'img/productos/th05-2.jpg', 'detalle superior'),
  ('th05', 3, 'img/productos/th05-3.jpg', 'detalle inferior'),
  ('th07', 1, 'img/productos/th07-1.jpg', 'vista principal'),
  ('th07', 2, 'img/productos/th07-2.jpg', 'detalle superior'),
  ('th07', 3, 'img/productos/th07-3.jpg', 'detalle inferior'),
  ('th08', 1, 'img/productos/th08-1.jpg', 'vista principal'),
  ('th08', 2, 'img/productos/th08-2.jpg', 'detalle superior'),
  ('th08', 3, 'img/productos/th08-3.jpg', 'detalle inferior'),
  ('th09', 1, 'img/productos/th09-1.jpg', 'vista principal'),
  ('th09', 2, 'img/productos/th09-2.jpg', 'detalle superior'),
  ('th09', 3, 'img/productos/th09-3.jpg', 'detalle inferior'),
  ('th10', 1, 'img/productos/th10-1.jpg', 'vista principal'),
  ('th10', 2, 'img/productos/th10-2.jpg', 'detalle superior'),
  ('th10', 3, 'img/productos/th10-3.jpg', 'detalle inferior'),
  ('th11', 1, 'img/productos/th11-1.jpg', 'vista principal'),
  ('th11', 2, 'img/productos/th11-2.jpg', 'detalle superior'),
  ('th11', 3, 'img/productos/th11-3.jpg', 'detalle inferior'),
  ('th12', 1, 'img/productos/th12-1.jpg', 'vista principal'),
  ('th12', 2, 'img/productos/th12-2.jpg', 'detalle superior'),
  ('th12', 3, 'img/productos/th12-3.jpg', 'detalle inferior'),
  ('th14', 1, 'img/productos/th14-1.jpg', 'vista principal'),
  ('th14', 2, 'img/productos/th14-2.jpg', 'detalle superior'),
  ('th14', 3, 'img/productos/th14-3.jpg', 'detalle inferior'),
  ('th15', 1, 'img/productos/th15-1.jpg', 'vista principal'),
  ('th15', 2, 'img/productos/th15-2.jpg', 'detalle superior'),
  ('th15', 3, 'img/productos/th15-3.jpg', 'detalle inferior'),
  ('en07', 1, 'img/productos/en07-1.jpg', 'vista principal'),
  ('en07', 2, 'img/productos/en07-2.jpg', 'detalle superior'),
  ('en07', 3, 'img/productos/en07-3.jpg', 'detalle inferior'),
  ('en08', 1, 'img/productos/en08-1.jpg', 'vista principal'),
  ('en08', 2, 'img/productos/en08-2.jpg', 'detalle superior'),
  ('en08', 3, 'img/productos/en08-3.jpg', 'detalle inferior'),
  ('en09', 1, 'img/productos/en09-1.jpg', 'vista principal'),
  ('en09', 2, 'img/productos/en09-2.jpg', 'detalle superior'),
  ('en09', 3, 'img/productos/en09-3.jpg', 'detalle inferior'),
  ('en10', 1, 'img/productos/en10-1.jpg', 'vista principal'),
  ('en10', 2, 'img/productos/en10-2.jpg', 'detalle superior'),
  ('en10', 3, 'img/productos/en10-3.jpg', 'detalle inferior'),
  ('en11', 1, 'img/productos/en11-1.jpg', 'vista principal'),
  ('en11', 2, 'img/productos/en11-2.jpg', 'detalle superior'),
  ('en11', 3, 'img/productos/en11-3.jpg', 'detalle inferior'),
  ('en12', 1, 'img/productos/en12-1.jpg', 'vista principal'),
  ('en12', 2, 'img/productos/en12-2.jpg', 'detalle superior'),
  ('en12', 3, 'img/productos/en12-3.jpg', 'detalle inferior'),
  ('en13', 1, 'img/productos/en13-1.jpg', 'vista principal'),
  ('en13', 2, 'img/productos/en13-2.jpg', 'detalle superior'),
  ('en13', 3, 'img/productos/en13-3.jpg', 'detalle inferior'),
  ('en14', 1, 'img/productos/en14-1.jpg', 'vista principal'),
  ('en14', 2, 'img/productos/en14-2.jpg', 'detalle superior'),
  ('en14', 3, 'img/productos/en14-3.jpg', 'detalle inferior'),
  ('en15', 1, 'img/productos/en15-1.jpg', 'vista principal'),
  ('en15', 2, 'img/productos/en15-2.jpg', 'detalle superior'),
  ('en15', 3, 'img/productos/en15-3.jpg', 'detalle inferior')
on conflict (prd_codigo, pim_orden) do nothing;

commit;
