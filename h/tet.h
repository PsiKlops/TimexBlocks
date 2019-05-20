;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; File Name :   tet.h
; Purpose   :   Tetris mode application header
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;==============================================================================
;
; STATE REDEFINITIONS
;
;==============================================================================

TETBANNERSTATE              equ     COREBANNERSTATE
TETDEFAULTSTATE             equ     COREDEFAULTSTATE
TETSETBANNERSTATE           equ     CORESETBANNERSTATE
TETYOUROCKSETSTATE          equ     CORESETBANNERSTATE
TETSETSTATE                 equ     CORESETSTATE
TETPOPUPSTATE               equ     COREPOPUPSTATE
TETPASSWORDDEFAULTSTATE     equ     COREPASSWORDDEFAULTSTATE
TETPASSWORDSETBANNERSTATE   equ     COREPASSWORDSETBANNERSTATE
TETPASSWORDSETSTATE         equ     COREPASSWORDSETSTATE

; TODO: Add your own state redefinition here
TET_SWITCH_BLOCK_STATE		equ		TETSETSTATE
TET_MOVE_BLOCK_LEFT_STATE	equ		TETPOPUPSTATE
TET_MOVE_BLOCK_RIGHT_STATE	equ		TETPASSWORDDEFAULTSTATE
TET_MOVE_BLOCK_DOWN_STATE	equ		TETPASSWORDSETBANNERSTATE
TET_MOVE_LINE_SCORE_STATE	equ		TETPASSWORDSETSTATE
TET_MOVE_GAME_START_STATE	equ		TET_MOVE_LINE_SCORE_STATE+1
TET_MOVE_GAME_END_STATE		equ		TET_MOVE_GAME_START_STATE+1
TET_MOVE_LINE_SCORE_STATE2	equ		TET_MOVE_GAME_END_STATE+1
TET_MOVE_COUNTIN_STATE		equ		TET_MOVE_LINE_SCORE_STATE2+1
TET_MOVE_GAME_END_2_STATE	equ		TET_MOVE_COUNTIN_STATE+1

;==============================================================================
;
; EVENT REDEFINITIONS
;
;==============================================================================

TET_STATEENTRY              equ     COREEVENT_STATEENTRY
TET_CROWNHOME               equ     COREEVENT_CROWN_HOME
TET_CROWNSET                equ     COREEVENT_CROWN_SET1
TET_CWPULSES                equ     COREEVENT_CW_PULSES
TET_CCWPULSES               equ     COREEVENT_CCW_PULSES
TET_MODEDEPRESS             equ     COREEVENT_SWITCH1DEPRESS

; TODO: Add your own state redefinition here

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;