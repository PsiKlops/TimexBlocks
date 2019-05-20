;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; File Name    : tetGmOvr.asm
; Purpose      : Tetris Application Default State Manager
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;DO NOT MODIFY THE FOLLOWING SUBROUTINE DEFINITION;;;;;;;;;;;;;;;;;

                IF @DEF('SUBROUTINE')
                    UNDEF SUBROUTINE
                ENDIF
                DEFINE  SUBROUTINE      "'tetGmOvr'"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Module Name : tetGameOverStateManager
; Description : Tetris Application Put up game over stuff
; Assumptions : Display is cleared on first time entry into the state.
; Input(s)    : CORECurrentEvent  - system event to be processed
;               COREEventArgument - event extra information
; Output(s)   : None
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                GLOBAL  tetGameOverStateManager

tetGameOverStateManager:
                ld      A, [CORECurrentEvent]
                
				;;  This stop watch check is essentially a timer interrupt function at 16 Hz - put it here at top will give it priority over buttons
                ;cp      A, #COREEVENT_DISPLAY_UPDATE_STPRES
                ;jr		Z, tetGameOverScreenFlashUpdate

                ; Check if state entry event.
                cp      A, #TET_STATEENTRY
                jr      Z, tetGameOverStateStateEntryEvent

                ; Check if mode depress event.
                ;cp      A, #TET_MODEDEPRESS
                ;jr      Z, tetGameOverModeDepressEvent

                ; Check if crown set event.
                ;cp      A, #TET_CROWNSET
                ;jr      Z, tetGameOverPulledCrownEvent

                ;cp      A, #COREEVENT_CW_EDGE_TRAILING
                ;jr      Z, tetGameOverRestart

                ;cp      A, #COREEVENT_CCW_EDGE_TRAILING
                ;jr      Z, tetGameOverRestart
                
                cp      A, #COREEVENT_STARTSPLITDEPRESS
                jr      Z, tetGameOverRestart

                cp      A, #COREEVENT_STOPRESETDEPRESS
                jr      Z, tetGameOverRestart

                ;TODO: Add more events detection here
                ;There are more events, add your own as needed

                ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; EVENT HANDLERS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

tetGameOverPulledCrownEvent:
                ;**************************************************************
                ;
                ;                       CROWN SET
                ;
                ;**************************************************************

                ld      B, #TETYOUROCKSETSTATE
                CORE_REQ_STATE_CHANGE

                ret

tetGameOverStateStateEntryEvent:
                ;**************************************************************
                ;
                ;                       STATE ENTRY
                ;
                ;**************************************************************

				car tetGameOverEntry

                ; start our background timing generator
                ld      HL, [CORECurrentASDAddress]
                ld      A, [HL]
                KSTP_ENABLE_DISP_UPD_EVENT
                ret
                
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;			Put Up Game Over Text in middle screen wait for any button to restart- Flash Hi - score??
;;;
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
             
tetGameOverScreenFlashUpdate:

				ret
				
tetGameOverEntry:

                ;Now we have set the block, Go back to main default state  -- OR CHECK PIXEL HERE?? MMMmmmm!
                ;ld      B, #TETDEFAULTSTATE
                ;CORE_REQ_STATE_CHANGE_NO_CLEAR_DISPLAY
                
                
                ;;//;;//;;//;;//;;// DATABASE ACCESS ;;//;;//;;//;;//;;//;;//
                ;;//;;//;;//;;//;;// DATABASE ACCESS ;;//;;//;;//;;//;;//;;//
                ;;//;;//;;//;;//;;// DATABASE ACCESS ;;//;;//;;//;;//;;//;;//
                
                 ; Read currently viewed record from the EEPROM
                ld      HL, [CORECurrentADDAddress]
                ld      [DBExternalMemoryAddress], HL
                DB_OPEN_FILE
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				; read in data from eeprom to internal memory
				; this example is accessing a sequential type structure
				;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				; specify the base offset of a record in the database
				; always 0 for sequential access memory
				ld HL, #0000H
				ld [DBExternalMemoryAddress], HL
				; specify the memory buffer to store the data read from eeprom
				ld HL, #TET_Score1
				ld [DBInternalMemoryAddress], HL
				; specify the number of bytes to transfer
				ld A, #2
				ld [DBLengthLo], A
				; read the data array from eeprom database

				DB_WRITE_RECORD
				DB_CLOSE_FILE
				ret

tetGameOverRestart:

				car		tetDrawSideLine   ;; and clears the screen
                car		tetInitialise;

                ld      B, #TETDEFAULTSTATE
                CORE_REQ_STATE_CHANGE_NO_CLEAR_DISPLAY
                ret

                
INCLUDE 'C:\M851\App\Tetris\src\tetInit.asm'
;INCLUDE 'C:\M851\App\Tetris\src\tetCom.asm'

                

