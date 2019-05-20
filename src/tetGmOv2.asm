;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; File Name    : tetGmOv2.asm
; Purpose      : Tetris Application Default State Manager
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;DO NOT MODIFY THE FOLLOWING SUBROUTINE DEFINITION;;;;;;;;;;;;;;;;;

                IF @DEF('SUBROUTINE')
                    UNDEF SUBROUTINE
                ENDIF
                DEFINE  SUBROUTINE      "'tetGmOv2'"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Module Name : tetGameOver2StateManager
; Description : Game over second part - After Put up game over stuff in part 1, and user press continue on a button then do space consuming init here
; Assumptions : Display is cleared on first time entry into the state.
; Input(s)    : CORECurrentEvent  - system event to be processed
;               COREEventArgument - event extra information
; Output(s)   : None
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                GLOBAL  tetGameOver2StateManager

tetGameOver2StateManager:
                ld      A, [CORECurrentEvent]
                
				;;  This stop watch check is essentially a timer interrupt function at 16 Hz - put it here at top will give it priority over buttons
                ;cp      A, #COREEVENT_DISPLAY_UPDATE_STPRES
                ;jr		Z, tetGameOverScreenFlashUpdate

                ; Check if state entry event.
                cp      A, #TET_STATEENTRY
                jr      Z, tetGameOver2StateStateEntryEvent

                ; Check if mode depress event.
                ;cp      A, #TET_MODEDEPRESS
                ;jr      Z, tetGameOverModeDepressEvent

                ; Check if crown set event.
                ;cp      A, #TET_CROWNSET
                ;jr      Z, tetGameOverPulledCrownEvent

                ;cp      A, #COREEVENT_CW_EDGE_TRAILING
                ;jr      Z, tetGameOverRestart

                ;cp      A, #COREEVENT_MODEDEPRESS
                ;jr      Z, tetGameOverRestart
                
                ;cp      A, #COREEVENT_STARTSPLITDEPRESS
                ;jr      Z, tetGameOverRestart

                ;cp      A, #COREEVENT_STOPRESETDEPRESS
                ;jr      Z, tetGameOverRestart

                ;TODO: Add more events detection here
                ;There are more events, add your own as needed

                ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; EVENT HANDLERS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

tetGameOver2PulledCrownEvent:
                ;**************************************************************
                ;
                ;                       CROWN SET
                ;
                ;**************************************************************

                ld      B, #TETYOUROCKSETSTATE
                CORE_REQ_STATE_CHANGE

                ret

tetGameOver2StateStateEntryEvent:
                ;**************************************************************
                ;
                ;                       STATE ENTRY
                ;
                ;**************************************************************

				car tetGameOverEntry

                ; start our background timing generator
               ; ld      HL, [CORECurrentASDAddress]
                ;ld      A, [HL]
                ;KSTP_ENABLE_DISP_UPD_EVENT  ;; needed for flashing
                ret
                
             
				
tetGameOverEntry:
				car		tetGO2UpdateDB

				car		tetDrawSideLine   ;; and clears the screen
                car		tetInitialise;

                ld      B, #TETDEFAULTSTATE
                CORE_REQ_STATE_CHANGE_NO_CLEAR_DISPLAY
                ret
                
 tetGO2UpdateDB:
 
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
				ld HL, #TET_HiScore1
				ld [DBInternalMemoryAddress], HL
				; specify the number of bytes to transfer
				ld A, #2
				ld [DBLengthLo], A
				; read the data array from eeprom database
				DB_READ_RECORD
				
				car		tetCheckHighScoreAndWriteBackIfNeeded
				
				DB_CLOSE_FILE
				ret
				
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;; Assume that Database is opened
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
tetCheckHighScoreAndWriteBackIfNeeded:
    			ld HL,#DEBUG_BREAKPOINT_VALUE   ;;TEMP TEST!!!!!!!!!!!!!!!!!!!

				ld	HL,[TET_Score1]
				ld	IY,[TET_HiScore1]
				cp	HL,IY
				
				jr LT,tetCheckHiLeave

				ld HL, #0000H
				ld [DBExternalMemoryAddress], HL
				; specify the memory buffer to store the data read from eeprom

				;;Write our new hi-score out
				; specify the memory buffer to store the data 
				ld HL, #TET_Score1
				ld [DBInternalMemoryAddress], HL
				; specify the number of bytes to transfer
				ld A, #2
				ld [DBLengthLo], A
				; read the data array from eeprom database
				DB_WRITE_RECORD

tetCheckHiLeave:
				ret                
INCLUDE 'C:\M851\App\Tetris\src\tetInit.asm'
;INCLUDE 'C:\M851\App\Tetris\src\tetCom.asm'

                

