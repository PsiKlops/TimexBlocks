;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; File Name    : tetdef.asm
; Purpose      : Tetris Application Default State Manager
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;DO NOT MODIFY THE FOLLOWING SUBROUTINE DEFINITION;;;;;;;;;;;;;;;;;

                IF @DEF('SUBROUTINE')
                    UNDEF SUBROUTINE
                ENDIF
                DEFINE  SUBROUTINE      "'tetdef'"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Module Name : tetDefaultStateManager
; Description : Tetris Application Default State Manager.
; Assumptions : Display is cleared on first time entry into the state.
; Input(s)    : CORECurrentEvent  - system event to be processed
;               COREEventArgument - event extra information
; Output(s)   : None
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                GLOBAL  tetDefaultStateManager

tetDefaultStateManager:
                ld      A, [CORECurrentEvent]
				
				;;  This stop watch check is essentially a timer interrupt function at 16 Hz - put it here at top will give it priority over buttons
                cp      A, #COREEVENT_DISPLAY_UPDATE_STPRES
                jr		Z, tetDefUpdateGame

                ; Check if state entry event.
                cp      A, #TET_STATEENTRY
                jr      Z, tetDefaultStateStateEntryEvent              

                ; Check if mode depress event.
                cp      A, #TET_MODEDEPRESS
                jr      Z, tetDefaultStateModeDepressEvent

                ; Check if crown set event.
                cp      A, #TET_CROWNSET
                jr      Z, tetDefaultPulledCrownEvent

                cp      A, #COREEVENT_CW_EDGE_TRAILING
                jr      Z, tetMoveBlockRight

                cp      A, #COREEVENT_CCW_EDGE_TRAILING
                jr      Z, tetMoveBlockLeft
                
                cp      A, #COREEVENT_STARTSPLITDEPRESS
                jr      Z, tetRotateBlock
                

                cp      A, #COREEVENT_STOPRESETDEPRESS
                ;;jr      Z, tetDefChangeBlockType       
                jr		Z, tetDefHurryUpBlock

                ;TODO: Add more events detection here
                ;There are more events, add your own as needed
                

                ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; EVENT HANDLERS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

tetDefaultPulledCrownEvent:
                ;**************************************************************
                ;
                ;                       CROWN SET
                ;
                ;**************************************************************

                ld      B, #TETYOUROCKSETSTATE
                CORE_REQ_STATE_CHANGE

                ret

tetDefaultStateStateEntryEvent:
                ;**************************************************************
                ;
                ;                       STATE ENTRY
                ;
                ;**************************************************************
 				ld	HL,#TET_LS_Status 
				ld	[HL],#0					;;Clear all Line Score status/flags

                ld      A, #TET_FALL_SPEED_1    ;MOVED FROM INIT TO REDUCE BYTE COUNT > 900
                ld      [TET_FallUpdateCnt], A
               
                ;;DRAW THE NEXT BLOCK
                ld      HL, #TET_GameStatus
                or     [HL], #bTET_GS_DrawAtNextPos

				ld		IY,#TET_NextShape_7_0
                car		tetDrawBlock   ;; Draw the Next block at to of screen
                
                ld      HL, #TET_GameStatus
                and     [HL], #@LOW(~bTET_GS_DrawAtNextPos)

				car tetDrawSideLineNoClear  ;;Need this?
				car tetLSDrawCurrentScore
				
				
				
				; start our background timing generator
                ld      HL, [CORECurrentASDAddress]
                ld      A, [HL]
                KSTP_ENABLE_DISP_UPD_EVENT
                ret

                ret

tetDefaultStateModeDepressEvent:
                ;**************************************************************
                ;
                ;                       MODE DEPRESS
                ;
                ;**************************************************************

                ;This is default to go to the next mode

                CORE_REQ_MODE_CHANGE_NEXT

                ret
                
 tetMoveBlockDown:
                ld      B, #TET_MOVE_BLOCK_DOWN_STATE
                CORE_REQ_STATE_CHANGE_NO_CLEAR_DISPLAY
                ret
                
 tetMoveBlockLeft:
                ld      B, #TET_MOVE_BLOCK_LEFT_STATE
                CORE_REQ_STATE_CHANGE_NO_CLEAR_DISPLAY
                ret
				
 tetMoveBlockRight:
                ld      B, #TET_MOVE_BLOCK_RIGHT_STATE
                CORE_REQ_STATE_CHANGE_NO_CLEAR_DISPLAY
                ret
	
tetDefChangeBlockType:			
                ;ld      IY, #TET_Current_Shape_7_0  ;;Set IY externally to draw/clear  shape so we can draw 'next' block as well
				;car		tetClearBlock  ;;and draw straight after TEMP!!
				
				; When press Stop/reset change the block type by going to special switch block state - this state will return immediately
                ld      B, #TET_SWITCH_BLOCK_STATE
                CORE_REQ_STATE_CHANGE_NO_CLEAR_DISPLAY
                ret
                
tetDefHurryUpBlock:
                ld      HL,#TET_GameStatus         
				or      [HL], #bTET_GS_FallSpeedQuick   ;;User wants to hurry the block drop 
				ret 


	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;			Main Loop of game
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			
tetDefUpdateGame:
						
 				;;		Check if block run off top of screen - and therefore play sample from Aliens "Game over man! Game over!!" - Not
                ld      HL, #TET_GameStatus
                bit		[HL],#bTET_GS_Running		
                jr		Z,tetDefGameOverMan

			  ;;Has our noddy timeout happened?
              ;  ld      HL,#TET_GameUpdateCnt         
              ;  dec	[HL]             
              ;  cp		[HL],#0
                
              ;  jr		NZ, tetSkipDoGameUpdate

              ;  ld      [HL], #TET_UPDATE_COUNT   ;;Reset TET_GameUpdate counter
              ;  car		tetDefChangeBlockType
		
tetSkipDoGameUpdate:

				;;Has our fall rate timeout happened?
                ld      HL, #TET_GameStatus
                bit     [HL], #bTET_GS_FallSpeedQuick
                jr      NZ, tetDoTheFallStep   ;; fall every frame if user wants to hurry up

				ld      HL,#TET_FallUpdateCnt         
                dec		[HL]             
				cp		[HL],#0
				jr		NZ, tetSkipFallReset
				               
tetFallResetRate1:
                ld      HL, #TET_GameStatus
                bit     [HL], #bTET_GS_FallSpeed_1
                jr      Z, tetFallResetRate2
                
               ld      HL,#TET_FallUpdateCnt         
               ld      [HL], #TET_FALL_SPEED_1   ;;Reset TET_FallUpdateCnt counter
				jr		tetDoTheFallStep ;;done it so leave - optimise

tetFallResetRate2:
               ld      HL,#TET_FallUpdateCnt         ;;TODO -- MAKE THIS MORE EFFICIENT!!!
	           ld      [HL], #TET_FALL_SPEED_2   ;;Reset TET_FallUpdateCnt counter
	           
tetDoTheFallStep:
	           car		tetMoveBlockDown				
				
tetSkipFallReset:	
				ret
				
Tet_DefNoFloorOrBlockHitOk:
tetDropBlock:
				ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;	Do the line destroying and scoring if any
;;;	At the end of the block fall - It hit the floor or another block
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				
tetDefGameOverMan:
                ld      B, #TET_MOVE_GAME_END_STATE
                CORE_REQ_STATE_CHANGE_NO_CLEAR_DISPLAY
                ret

				
;INCLUDE 'C:\M851\App\Tetris\src\tetCom.asm'

				
tetLSDrawCurrentScore:
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

				

