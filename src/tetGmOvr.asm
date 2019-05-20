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
                cp      A, #COREEVENT_DISPLAY_UPDATE_STPRES
                jr		Z, tetGameOverScreenFlashUpdate

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

                cp      A, #COREEVENT_MODEDEPRESS
                jr      Z, tetGameOverRestart
                
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
				ld		HL,#TET_GameOverMsgFlash
				dec		[HL]
				cp		[HL],#0
				
				jr		NZ,tetGOSFContinue				
				ld		[HL],#TET_MSG_FLASH_ON_OFF_TIME    ;;reset timer
				
tetGOSFContinue:
				cp		[HL],#TET_MSG_FLASH_ON_TIME
				jr		GT,tetGOSFEndOff
				
				car		tetLSDrawNormalScore
				car		tetDrawWordEnd			
				ret
				
tetGOSFEndOff:
				car		tetLSDrawCurrentHiScore
				car		tetGameOverClearMsgRegion ;;
				ret
				
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				
tetGameOverEntry:


				ld		HL,#TET_GameOverMsgFlash
				ld		[HL],#TET_MSG_FLASH_ON_OFF_TIME    ;;reset timer - on at start
				
				car		tetGameOverClearMsgRegion
				car		tetDrawWordEnd

                 
				ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
tetGameOverRestart:

				car		tetDrawSideLineNoClear  ;; put the sideline back after end message
				
                ld      B, #TET_MOVE_GAME_END_2_STATE ;;this state does the actual initialisation and starts DEF state for new game
                CORE_REQ_STATE_CHANGE_NO_CLEAR_DISPLAY                   
                ret
                
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;               
;;;			   Clear a space in the middle of the game area for little messages 		   	;;;;;               
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;             
tetGameOverClearMsgRegion:

				;;;LCD_FILL_DISPLAY  ; temp so I can see size cleared
				
    			
    			;ld HL,#DEBUG_BREAKPOINT_VALUE   ;;TEMP TEST!!!!!!!!!!!!!!!!!!!
    			
                ld		HL,#TET_ParseBlockX
 				ld		[HL],#TET_MSG_REGION_START_X-1 
				
tetGOCMRResetParseBlockCountY:
 				ld		HL, #TET_ParseBlockX
				inc		[HL]
                cp		[HL],#TET_MSG_REGION_END_X                   
                jr		GT,tetGOCMREndClear

				ld		HL,#TET_ParseBlockY
 				ld		[HL],#TET_MSG_REGION_START_Y

tetGOCMRLoopBack:
  				ld		A,[TET_ParseBlockX]
				ld		B,[TET_ParseBlockY]
				car		tetClearPixel
				
				ld		HL, #TET_ParseBlockY
				inc		[HL]
                cp		[HL],#TET_MSG_REGION_END_Y                   
                jr		GT,tetGOCMRResetParseBlockCountY
				
				jr		tetGOCMRLoopBack


tetGOCMREndClear:
                ret
                
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;;;;;
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
 tetDrawWordEnd:
				ld		IY,#TET_ParseBlockY
				ld		[IY],#11
				car		tetMsgLine
				ld		[IY],#8
				car		tetMsgLine
				ld		[IY],#6
				car		tetMsgLine
				ld		[IY],#3
				car		tetMsgLine
				ld		[IY],#1
				car		tetMsgLine
		
  ;;;E
  				ld		A,#TET_MSG_START_X
				ld		B,#10
				car		tetDrawPixel
   				ld		A,#TET_MSG_START_X+2
				ld		B,#10
				car		tetDrawPixel
   				ld		A,#TET_MSG_END_X
				ld		B,#10
				car		tetDrawPixel

 ;;;N
   				ld		A,#TET_MSG_START_X
				ld		B,#7
				car		tetDrawPixel
 
 ;;;D
  				ld		A,#TET_MSG_START_X
				ld		B,#4
				car		tetDrawPixel
   				ld		A,#TET_MSG_END_X
				ld		B,#4
				car		tetDrawPixel
				
  				ld		A,#TET_MSG_START_X
				ld		B,#2
				car		tetDrawPixel
   				ld		A,#TET_MSG_END_X
				ld		B,#2
				car		tetDrawPixel
				ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;			
;;;;;; IY reg has Y coord to put a line alongin message window	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;				
tetMsgLine:				

				ld		HL,#TET_ParseBlockX
 				ld		[HL],#TET_MSG_START_X

tetMsgLineLoopBack:
  				ld		A,[TET_ParseBlockX]
				ld		B,[IY]
				car		tetDrawPixel
				
				ld		HL, #TET_ParseBlockX
				inc		[HL]
                cp		[HL],#TET_MSG_END_X                   
                jr		GT,tetMsgLineEnd
				
				jr		tetMsgLineLoopBack
tetMsgLineEnd:
				ret
				
tetLSDrawCurrentHiScore:
				ld	IY,#TET_HiScore1	
				;convert HEX to BCD
				ld L, [IY]
				UTL_CONVERT_HEX_TO_2DIGIT_BCD
				ld IX, #LCDSEGDIGIT3
				LCD_DISP_2DIG_SEG_DATA_NO_ZERO_SUP
				
				ld	IY,#TET_HiScore2	
				ld L, [IY]
				UTL_CONVERT_HEX_TO_2DIGIT_BCD
				ld IX, #LCDSEGDIGIT5
				LCD_DISP_2DIG_SEG_DATA_NO_ZERO_SUP
				
				ld		L,#SEG_H ;'H'
				ld		IX,#LCDSEGDIGIT1
				LCD_DISP_SEG_CHAR
				ld		L,#SEG_I ;'I'
				ld		IX,#LCDSEGDIGIT2
				LCD_DISP_SEG_CHAR
				
				ret	
				
tetLSDrawNormalScore:
				ld	IY,#TET_Score1	
				;convert HEX to BCD
				ld L, [IY]
				UTL_CONVERT_HEX_TO_2DIGIT_BCD
				ld IX, #LCDSEGDIGIT3
				LCD_DISP_2DIG_SEG_DATA_NO_ZERO_SUP
				
				ld	IY,#TET_Score2	
				ld L, [IY]
				UTL_CONVERT_HEX_TO_2DIGIT_BCD
				ld IX, #LCDSEGDIGIT5
				LCD_DISP_2DIG_SEG_DATA_NO_ZERO_SUP
				
				ld		L,#SEG_SPACE 
				ld		IX,#LCDSEGDIGIT1
				LCD_DISP_SEG_CHAR
				ld		L,#SEG_SPACE 
				ld		IX,#LCDSEGDIGIT2
				LCD_DISP_SEG_CHAR
				
				ret	

                

                

