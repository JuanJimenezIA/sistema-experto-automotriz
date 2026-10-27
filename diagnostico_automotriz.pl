% Sistema experto de diagnostico automotriz
% Paradigmas de Programacion - Prolog

:- discontiguous sintoma/2.
:- discontiguous componente/2.
:- discontiguous rel_sintoma_causa/2.
:- discontiguous nivel_urgencia/2.


% HECHOS

% Sintomas: sintoma(Sintoma, Sistema)
sintoma(clicks_al_intentar_arrancar, encendido_y_arranque).
sintoma(motor_gira_lentamente, encendido_y_arranque).
sintoma(luces_tablero_debiles, encendido_y_arranque).
sintoma(testigo_bateria_encendido, encendido_y_arranque).
sintoma(motor_tiembla, funcionamiento_motor).
sintoma(perdida_fuerza_al_acelerar, funcionamiento_motor).
sintoma(testigo_check_engine_fijo, funcionamiento_motor).
sintoma(temperatura_elevada, enfriamiento).
sintoma(necesidad_frecuente_rellenar_refrigerante, enfriamiento).
sintoma(pedal_freno_blando_o_se_hunde, frenos).
sintoma(chirrido_o_ruido_metalico_frenar, frenos).
sintoma(vibracion_pedal_al_frenar, frenos).
sintoma(zumbido_que_aumenta_con_velocidad, suspension_y_direccion).
sintoma(chasquidos_al_girar_y_acelerar, suspension_y_direccion).
sintoma(testigo_aceite_rojo_encendido, lubricacion).
sintoma(humo_blanco_persistente, motor_interno).

% Componentes: componente(Componente, Sistema)
componente(bateria, encendido_y_arranque).
componente(alternador, encendido_y_arranque).
componente(bujias_o_bobinas, funcionamiento_motor).
componente(ventilador_radiador, enfriamiento).
componente(mangueras_y_radiador, enfriamiento).
componente(circuito_hidraulico_frenos, frenos).
componente(pastillas_de_freno, frenos).
componente(discos_de_freno, frenos).
componente(rodamiento_de_rueda, suspension_y_direccion).
componente(junta_homocinetica, suspension_y_direccion).
componente(bomba_de_aceite, lubricacion).
componente(junta_de_culata, motor_interno).

% Causa y componente que afecta: afecta(Causa, Componente)
afecta(bateria_descargada, bateria).
afecta(bateria_deteriorada, bateria).
afecta(alternador_defectuoso, alternador).
afecta(bujias_bobinas_defectuosas, bujias_o_bobinas).
afecta(ventilador_radiador_no_funciona, ventilador_radiador).
afecta(fuga_refrigerante, mangueras_y_radiador).
afecta(fuga_liquido_frenos, circuito_hidraulico_frenos).
afecta(pastillas_desgastadas, pastillas_de_freno).
afecta(discos_freno_danados, discos_de_freno).
afecta(rodamiento_rueda_desgastado, rodamiento_de_rueda).
afecta(junta_homocinetica_danada, junta_homocinetica).
afecta(presion_aceite_insuficiente, bomba_de_aceite).
afecta(junta_culata_danada, junta_de_culata).

% Sintoma que puede indicar una causa: rel_sintoma_causa(Sintoma, Causa)
% Un mismo sintoma puede apuntar a varias causas.
rel_sintoma_causa(clicks_al_intentar_arrancar, bateria_descargada).
rel_sintoma_causa(clicks_al_intentar_arrancar, bateria_deteriorada).
rel_sintoma_causa(motor_gira_lentamente, bateria_descargada).
rel_sintoma_causa(motor_gira_lentamente, bateria_deteriorada).
rel_sintoma_causa(luces_tablero_debiles, bateria_descargada).
rel_sintoma_causa(luces_tablero_debiles, alternador_defectuoso).
rel_sintoma_causa(testigo_bateria_encendido, alternador_defectuoso).
rel_sintoma_causa(motor_tiembla, bujias_bobinas_defectuosas).
rel_sintoma_causa(perdida_fuerza_al_acelerar, bujias_bobinas_defectuosas).
rel_sintoma_causa(testigo_check_engine_fijo, bujias_bobinas_defectuosas).
rel_sintoma_causa(temperatura_elevada, ventilador_radiador_no_funciona).
rel_sintoma_causa(temperatura_elevada, fuga_refrigerante).
rel_sintoma_causa(temperatura_elevada, junta_culata_danada).
rel_sintoma_causa(necesidad_frecuente_rellenar_refrigerante, fuga_refrigerante).
rel_sintoma_causa(necesidad_frecuente_rellenar_refrigerante, junta_culata_danada).
rel_sintoma_causa(pedal_freno_blando_o_se_hunde, fuga_liquido_frenos).
rel_sintoma_causa(chirrido_o_ruido_metalico_frenar, pastillas_desgastadas).
rel_sintoma_causa(vibracion_pedal_al_frenar, discos_freno_danados).
rel_sintoma_causa(zumbido_que_aumenta_con_velocidad, rodamiento_rueda_desgastado).
rel_sintoma_causa(chasquidos_al_girar_y_acelerar, junta_homocinetica_danada).
rel_sintoma_causa(testigo_aceite_rojo_encendido, presion_aceite_insuficiente).
rel_sintoma_causa(humo_blanco_persistente, junta_culata_danada).

% Nivel de urgencia de cada causa: critica, alta, media o baja
nivel_urgencia(bateria_descargada, media).
nivel_urgencia(bateria_deteriorada, media).
nivel_urgencia(alternador_defectuoso, media).
nivel_urgencia(bujias_bobinas_defectuosas, baja).
nivel_urgencia(ventilador_radiador_no_funciona, alta).
nivel_urgencia(fuga_refrigerante, alta).
nivel_urgencia(fuga_liquido_frenos, critica).
nivel_urgencia(pastillas_desgastadas, media).
nivel_urgencia(discos_freno_danados, media).
nivel_urgencia(rodamiento_rueda_desgastado, media).
nivel_urgencia(junta_homocinetica_danada, media).
nivel_urgencia(presion_aceite_insuficiente, critica).
nivel_urgencia(junta_culata_danada, alta).

% Verificacion sugerida para cada causa
verificacion(bateria_descargada, 'Medir voltaje de la bateria y hacer prueba bajo carga.').
verificacion(bateria_deteriorada, 'Revisar bornes, sulfatacion y antiguedad de la bateria.').
verificacion(alternador_defectuoso, 'Medir el sistema de carga y revisar correa, cableado y conexiones.').
verificacion(fuga_liquido_frenos, 'No seguir conduciendo. Revisar nivel de liquido y fugas en el circuito.').
verificacion(presion_aceite_insuficiente, 'Apagar el motor. Revisar nivel de aceite y medir presion con manometro.').
verificacion(ventilador_radiador_no_funciona, 'Revisar fusible, rele, alimentacion y sensor del ventilador.').
verificacion(fuga_refrigerante, 'Buscar fugas en mangueras, radiador y bomba de agua.').
verificacion(junta_culata_danada, 'Prueba de compresion y revisar si hay aceite en el refrigerante.').
verificacion(pastillas_desgastadas, 'Medir el espesor de las pastillas.').
verificacion(discos_freno_danados, 'Medir alabeo y espesor de los discos.').


% REGLAS

% Inferencia de posibles causas.
% Una causa es posible si al menos uno de los sintomas reportados la sugiere.
posible_causa(Sintomas, Causa) :-
    member(S, Sintomas),
    rel_sintoma_causa(S, Causa).

% Lista de causas posibles sin repetir.
causas_posibles(Sintomas, Causas) :-
    setof(C, posible_causa(Sintomas, C), Causas).

% Cuantos de los sintomas reportados apoyan a una causa.
apoyo(Sintomas, Causa, N) :-
    findall(S, (member(S, Sintomas), rel_sintoma_causa(S, Causa)), L),
    sort(L, Unicos),
    length(Unicos, N).

% Grado de certeza: un solo sintoma no confirma la falla, solo la hace posible.
% Con dos o mas sintomas que coinciden se considera probable.
certeza(Sintomas, Causa, probable) :-
    apoyo(Sintomas, Causa, N),
    N >= 2, !.
certeza(_, _, posible).

% Sintomas asociados a la causa que el usuario no reporto (sirven para preguntar).
sintomas_por_confirmar(Sintomas, Causa, Faltan) :-
    findall(S, (rel_sintoma_causa(S, Causa), \+ member(S, Sintomas)), Faltan).

% Recomendaciones de verificacion.
% Si la causa no tiene una verificacion especifica se da una general.
recomendar_verificacion(Causa, Texto) :-
    verificacion(Causa, Texto), !.
recomendar_verificacion(_, 'Hacer escaneo OBD-II y pruebas segun el manual del fabricante.').

% Prioridad.
es_urgente(Causa) :-
    nivel_urgencia(Causa, critica).

requiere_revision_pronta(Causa) :-
    nivel_urgencia(Causa, Nivel),
    member(Nivel, [alta, media]).

% Suficiencia de informacion.
sintoma_desconocido(Sintoma) :-
    \+ sintoma(Sintoma, _).

% Falta informacion si no se dio ningun sintoma conocido, o si solo hay
% uno y apunta a mas de una causa.
requiere_mas_informacion(Sintomas) :-
    exclude(sintoma_desconocido, Sintomas, []), !.
requiere_mas_informacion(Sintomas) :-
    exclude(sintoma_desconocido, Sintomas, [_]),
    causas_posibles(Sintomas, Causas),
    length(Causas, N),
    N > 1.

% Clasificacion general del caso. El orden importa: primero lo urgente.
clasificar_caso(Sintomas, urgente) :-
    posible_causa(Sintomas, C),
    es_urgente(C), !.
clasificar_caso(Sintomas, mas_informacion) :-
    requiere_mas_informacion(Sintomas), !.
clasificar_caso(Sintomas, revision_pronta) :-
    posible_causa(Sintomas, C),
    requiere_revision_pronta(C), !.
clasificar_caso(Sintomas, revision_normal) :-
    posible_causa(Sintomas, _), !.
clasificar_caso(_, sin_coincidencias).


% PREDICADOS DE CONSULTA

% Devuelve cada causa posible (una por solucion) con su urgencia y certeza.
diagnosticar(Sintomas, Causa, Urgencia, Certeza) :-
    causas_posibles(Sintomas, Causas),
    member(Causa, Causas),
    nivel_urgencia(Causa, Urgencia),
    certeza(Sintomas, Causa, Certeza).

% Diagnostico con el componente y sistema afectados y la verificacion.
diagnostico_completo(Sintomas, Causa, Componente, Sistema, Urgencia, Verificacion) :-
    diagnosticar(Sintomas, Causa, Urgencia, _),
    afecta(Causa, Componente),
    componente(Componente, Sistema),
    recomendar_verificacion(Causa, Verificacion).

% Sintomas y causas relacionados con un sistema del auto.
verificar_estado_sistema(Sistema, Sintoma, Causa) :-
    sintoma(Sintoma, Sistema),
    rel_sintoma_causa(Sintoma, Causa).

% Imprime un reporte legible del caso.
reporte(Sintomas) :-
    clasificar_caso(Sintomas, Clase),
    format("Clasificacion: ~w~n", [Clase]),
    forall(diagnosticar(Sintomas, C, U, Cert),
           ( recomendar_verificacion(C, V),
             format("- ~w (~w, urgencia ~w): ~w~n", [C, Cert, U, V]) )).