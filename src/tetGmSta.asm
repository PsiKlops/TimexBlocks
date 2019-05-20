;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; File Name    : tetGmSta.asm
; Purpose      : Tetris Application Default State Manager
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;DO NOT MODIFY THE FOLLOWING SUBROUTINE DEFINITION;;;;;;;;;;;;;;;;;

                IF @DEF('SUBROUTINE')
                    UNDEF SUBROUTINE
                ENDIF
                DEFINE  SUBROUTINE      "'tetGmSta'"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Module Name : tetGameStartStateManager
; Description : Tetris Application Put up game over stuff
; Assumptions : Display is cleared on first time entry into the state.
; Input(s)    : CORECurrentEvent  - system event to be processed
;               COREEventArgument - event extra information
; Output(s)   : None
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                GLOBAL  tetGameStartStateManager

tetGameStartStateManager:
                ld      A, [CORECurrentEvent]
                
				;;  This stop watch check is essentially a timer interrupt function at 16 Hz - put it here at top will give it priority over buttons
                ;cp      A, #COREEVENT_DISPLAY_UPDATE_STPRES
                ;jr		Z, tetGameStartScreenCountDown

                ; Check if state entry event.
                cp      A, #TET_STATEENTRY
                jr      Z, tetGameStartStateStateEntryEvent

                ; Check if mode depress event.
                ;cp      A, #TET_MODEDEPRESS
                ;jr      Z, tetGameStartModeDepressEvent

                ; Check if crown set event.
                ;cp      A, #TET_CROWNSET
                ;jr      Z, tetGameStartPulledCrownEvent

                ;cp      A, #COREEVENT_CW_EDGE_TRAILING
                ;jr      Z, tetGameRestart

                ;cp      A, #COREEVENT_CCW_EDGE_TRAILING
                ;jr      Z, tetGameRestart
                
                ;cp      A, #COREEVENT_STARTSPLITDEPRESS
                ;jr      Z, tetGameRestart

                ;cp      A, #COREEVENT_STOPRESETDEPRESS
                ;jr      Z, tetGameRestart

                ;TODO: Add more events detection here
                ;There are more events, add your own as needed

                ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; EVENT HANDLERS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

tetGameStartPulledCrownEvent:
                ;**************************************************************
                ;
                ;                       CROWN SET
                ;
                ;**************************************************************

                ld      B, #TETYOUROCKSETSTATE
                CORE_REQ_STATE_CHANGE

                ret

tetGameStartStateStateEntryEvent:
                ;**************************************************************
                ;
                ;                       STATE ENTRY
                ;
                ;**************************************************************

				car tetGameStartEntry

                ; start our background timing generator
                ld      HL, [CORECurrentASDAddress]
                ld      A, [HL]
                KSTP_ENABLE_DISP_UPD_EVENT
                ret
                
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;			Restart game - initialise variables and then countdown - start game state
;;;
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
             
tetGameStartScreenCountDown:

				ret
				
tetGameStartEntry:

                ;Now we have set the block, Go back to main default state  -- OR CHECK PIXEL HERE?? MMMmmmm!
                ;ld      B, #TETDEFAULTSTATE
                ;CORE_REQ_STATE_CHANGE_NO_CLEAR_DISPLAY
                ret

tetGameStartRestart:

                ;Now we have set the block, Go back to main default state  -- OR CHECK PIXEL HERE?? MMMmmmm!
                ;ld      B, #TETDEFAULTSTATE
                ;CORE_REQ_STATE_CHANGE_NO_CLEAR_DISPLAY
                ret

                
 ;INCLUDE 'C:\M851\App\Tetris\src\tetCom.asm'

                

