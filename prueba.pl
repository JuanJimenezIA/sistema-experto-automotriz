% ==============================================================================
% SISTEMA EXPERTO: DIAGNÓSTICO DE FALLAS AUTOMOTRICES
% ==============================================================================

% Memoria dinámica para los síntomas reportados por el usuario
:- dynamic sintoma_presente/1.

% ------------------------------------------------------------------------------
% 1. PREDICADOS PROPIOS Y HECHOS (Total: 36 hechos significativos)
% ------------------------------------------------------------------------------

% Predicado Propio 1: sintoma_info(Sintoma, Sistema)
sintoma_info(no_da_marcha, electrico).
sintoma_info(luces_debiles, electrico).
sintoma_info(chasquido_al_arrancar, electrico).
sintoma_info(pedal_esponjoso, frenos).
sintoma_info(chillido_al_frenar, frenos).
sintoma_info(distancia_frenado_larga, frenos).
sintoma_info(liquido_frenos_bajo, frenos).
sintoma_info(humo_azul, motor).
sintoma_info(humo_blanco_denso, motor).
sintoma_info(temperatura_alta, refrigeracion).
sintoma_info(ventilador_no_enciende, refrigeracion).

% Predicado Propio 2: componente(Pieza, Sistema)
componente(bateria, electrico).
componente(motor_arranque, electrico).
componente(pastillas_freno, frenos).
componente(bomba_frenos, frenos).
componente(liquido_frenos, frenos).
componente(anillos_piston, motor).
componente(empaque_culata, motor).
componente(termostato, refrigeracion).

% Predicado Propio 3: pieza_afectada(Falla, Pieza)
pieza_afectada(falla_bateria, bateria).
pieza_afectada(falla_arranque, motor_arranque).
pieza_afectada(desgaste_frenos, pastillas_freno).
pieza_afectada(fuga_sistema_frenos, bomba_frenos).
pieza_afectada(aire_en_lineas_freno, liquido_frenos).
pieza_afectada(desgaste_anillos_aceite, anillos_piston).
pieza_afectada(falla_empaque_motor, empaque_culata).
pieza_afectada(termostato_pegado, termostato).

% Predicado Propio 4: severidad_falla(Falla, NivelUrgencia)
severidad_falla(falla_bateria, media).
severidad_falla(falla_arranque, media).
severidad_falla(desgaste_frenos, media).
severidad_falla(fuga_sistema_frenos, alta).
severidad_falla(aire_en_lineas_freno, media).
severidad_falla(desgaste_anillos_aceite, media).
severidad_falla(falla_empaque_motor, alta).
severidad_falla(termostato_pegado, alta).

% Predicado Propio 5: accion_recomendada(Falla, AccionTexto)
accion_recomendada(falla_bateria, 'Cargar o reemplazar acumulador de 12V').
accion_recomendada(falla_arranque, 'Revisar solenoide o cambiar motor de arranque').
accion_recomendada(desgaste_frenos, 'Cambio inmediato de pastillas y rectificado de discos').
accion_recomendada(fuga_sistema_frenos, 'No mover vehiculo; fuga hidraulica critica en frenos').
accion_recomendada(aire_en_lineas_freno, 'Purgar lineas de freno y rellenar fluido DOT4').
accion_recomendada(desgaste_anillos_aceite, 'Reparacion mayor: cambio de anillos y sellos de valvula').
accion_recomendada(falla_empaque_motor, 'Detener marcha; riesgo severo de mezcla agua-aceite').
accion_recomendada(termostato_pegado, 'Reemplazar termostato y purgar anticongelante').

% ------------------------------------------------------------------------------
% 2. REGLAS LÓGICAS (10 reglas que deducen la falla a partir de los síntomas)
% ------------------------------------------------------------------------------

% Regla 1: Batería descargada por falta de marcha y luces tenues
diagnostico_falla(falla_bateria) :-
    sintoma_presente(no_da_marcha),
    sintoma_presente(luces_debiles).

% Regla 2: Motor de arranque con falla mecánica/eléctrica
diagnostico_falla(falla_arranque) :-
    sintoma_presente(no_da_marcha),
    sintoma_presente(chasquido_al_arrancar).

% Regla 3: Desgaste físico de pastillas (chillido + distancia larga de frenado)
diagnostico_falla(desgaste_frenos) :-
    sintoma_presente(chillido_al_frenar),
    sintoma_presente(distancia_frenado_larga).

% Regla 4: Pérdida de presión hidráulica crítica (pedal suave + nivel bajo)
diagnostico_falla(fuga_sistema_frenos) :-
    sintoma_presente(pedal_esponjoso),
    sintoma_presente(liquido_frenos_bajo).

% Regla 5: Quema de lubricante en cámara de combustión
diagnostico_falla(desgaste_anillos_aceite) :-
    sintoma_presente(humo_azul).

% Regla 6: Ruptura de empaque de culata / cabeza de motor
diagnostico_falla(falla_empaque_motor) :-
    sintoma_presente(humo_blanco_denso),
    sintoma_presente(temperatura_alta).

% Regla 7: Sobrecalentamiento por termostato trabado en cerrado
diagnostico_falla(termostato_pegado) :-
    sintoma_presente(temperatura_alta),
    sintoma_presente(ventilador_no_enciende).

% Regla 8 (Backtracking): Falla de batería deducible por solo el chasquido
diagnostico_falla(falla_bateria) :-
    sintoma_presente(chasquido_al_arrancar).

% Regla 9: Aire en el circuito hidráulico (pedal esponjoso aislado)
diagnostico_falla(aire_en_lineas_freno) :-
    sintoma_presente(pedal_esponjoso).

% Regla 10: Predicado maestro de inferencia
% Deduce Falla, busca la Pieza, el Sistema, el Nivel y la Solución recomendada.
diagnostico_completo(Falla, Sistema, Pieza, Nivel, Solucion) :-
    diagnostico_falla(Falla),
    pieza_afectada(Falla, Pieza),
    componente(Pieza, Sistema),
    severidad_falla(Falla, Nivel),
    accion_recomendada(Falla, Solucion).