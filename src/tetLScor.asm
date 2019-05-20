;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; File Name    : tetLScor.asm
; Purpose      : Tetris Application Default State Manager
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;DO NOT MODIFY THE FOLLOWING SUBROUTINE DEFINITION;;;;;;;;;;;;;;;;;

                IF @DEF('SUBROUTINE')
                    UNDEF SUBROUTINE
                ENDIF
                DEFINE  SUBROUTINE      "'tetLScor'"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Module Name : tetMoveDownStateManager
; Description : Tetris Application Delete any full lines and score them 
; Assumptions : Display is cleared on first time entry into the state.
; Input(s)    : CORECurrentEvent  - system event to be processed
;               COREEventArgument - event extra information
; Output(s)   : None
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                GLOBAL  tetLineScoreStateManager

tetLineScoreStateManager:
                ld      A, [CORECurrentEvent]

                ; Check if state entry event.
                cp      A, #TET_STATEENTRY
                jr      Z, tetLineScoreStateStateEntryEvent
                ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; EVENT HANDLERS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

tetLineScorePulledCrownEvent:
                ;**************************************************************
                ;
                ;                       CROWN SET
                ;
                ;**************************************************************

                ld      B, #TETYOUROCKSETSTATE
                CORE_REQ_STATE_CHANGE

                ret

tetLineScoreStateStateEntryEvent:
                ;**************************************************************
                ;
                ;                       STATE ENTRY
                ;
                ;**************************************************************


				car tetLineScore

				ret
                
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;			Delete and Flash each line form bottom to top
;;;			then delete and drop rows above down - scoring as we go along
;;;			until all blocks have fallen
;;;			- set flags and variables accordingly
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
             
tetLineScore:
                ;;Initialise the block pos variables to the Init Block position
                ld		HL,#TET_BlockPosX
				ld		[HL],#TET_INITIAL_BLOCK_START_X				
				ld		HL,#TET_BlockPosY
				ld		[HL],#TET_INITIAL_BLOCK_START_Y
				
				car tetLineScoreGetFullLinesDataAndScore
				
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;				
;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;				
tetLSGoToLS2State:              
                ;Now we have checked the line data go to state for scoring and block clearing
                ld      B, #TET_MOVE_LINE_SCORE_STATE2
                CORE_REQ_STATE_CHANGE_NO_CLEAR_DISPLAY
                ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;				
;;;;;		Kinda the initial thing to do in this state - Checks for any full lines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;				
tetLineScoreGetFullLinesDataAndScore:
				ld	HL,#TET_LS_Status 
				ld	[HL],#@LOW(bTET_LS_Initialised) ;; Effectivel clear all status/flags - tell it we've initialise

   				;ld HL,#DEBUG_BREAKPOINT_VALUE   ;;TEMP TEST!!!!!!!!!!!!!!!!!!!
 				
 				ld	HL,#TET_LS_FlashCount
				ld	[HL],#TET_LINE_FLASH_TIMES
  				
				ld	HL,#TET_ParseBlockX
				ld	[HL],#TET_SIDELINE_START_X
				ld	HL,#TET_ParseBlockY
				ld	[HL],#TET_LS_START_Y
				
				ld	HL,#TET_LS_NumLinesToDrop   ;;Reset number of lines needing to be processed
				ld [HL],#0
				
				ld	HL,#TET_LS_Count
				ld	[HL],#0
				
				ld	IX,#TET_LS_Line1X  ; initialise first line record

tetLSGetDataLoopBack:				
				car tetLineScoreIsLineFull	
				
				ld	HL,#TET_LS_Status
				bit	[HL],#bTET_LS_LineFull
				car	NZ,tetRecordFullLineDataParseXtoIXAndIncrementCounter   ;;Increments -> TET_LS_NumLinesToDrop and moves IX to point to next TET_LS_LinenX
				ld	HL,#TET_LS_Status
				bit	[HL],#bTET_LS_LineEmpty   
				jr	NZ,tetLSGetDataFinished ;;Early out - Found an empty line so end testing (nothing should be floating above)
				
				ld	HL,#TET_LS_Count
				inc	[HL]
				cp	[HL],#TET_NUMBER_OF_GAME_LINES
				jr	Z,tetLSGetDataFinished
				
				ld	HL,#TET_ParseBlockX			;;***DECREMENT!!!***  X to next line
				dec	[HL]
				ld	HL,#TET_ParseBlockY			;;And reset Y for next loop
				ld	[HL],#TET_LS_START_Y
				
				jr	tetLSGetDataLoopBack
			

tetLSGetDataFinished:  ;;Could have up to 4 lines (max) to process
				ret
				


								
			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;				
;;;;;
;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;				
tetLineScoreIsLineFull:
				ld	HL,#TET_LS_Status
				and	[HL],#TET_LS_STATUS_CLEAR_LINE_FULL_EMPTY
				
				ld	HL,#TET_LS_PixelCount
				ld	[HL],#0

tetLSIsLineFullLoopBack:
				ld	HL,#TET_ParseBlockX
				ld	A,[HL]
				ld	HL,#TET_ParseBlockY
				ld	B,[HL]
								
                LCD_GET_STATE_OF_PIXEL
                jr      Z, tetLSPixelNotFound
                
				ld	HL,#TET_LS_PixelCount
				inc	[HL]

tetLSPixelNotFound:
				ld	HL,#TET_ParseBlockY
				inc	[HL]
				cp	[HL],#12
				jr	NZ,tetLSIsLineFullLoopBack
				
				ld	HL,#TET_LS_PixelCount
				cp	[HL],#10
				jr	NZ,tetLSNotAFullLineEnd
				
				ld	HL,#TET_LS_Status
				or	[HL],#bTET_LS_LineFull   ;Found a full line so set flag
			
				;;car	tetRecordFullLineDataParseXtoIXAndIncrementCounter
				;;Want to pull this block out
				;;ld	[IX],[IY]	;;Full line so record the X coordinate
				;;inc	IX			;;increment line record - max 4 - Check this ????				
				;;ld	HL,#TET_LS_NumLinesToDrop   ;;record number of lines needing  to be processed
				;;inc [HL]

tetLSNotAFullLineEnd:
				cp	[HL],#0					;;Does line TET_LS_PixelCount=0
				jr NZ,tetLSFullLineReallyEnd
				
				ld	HL,#TET_LS_Status
				or	[HL],#bTET_LS_LineEmpty   ;Found an empty line so end testing (nothing should be floating above)

tetLSFullLineReallyEnd:
				ret
				
tetRecordFullLineDataParseXtoIXAndIncrementCounter:
				ld	HL,#TET_ParseBlockX
				ld	[IX],[HL]	;;Full line so record the X coordinate
				inc	IX			;;increment line record - max 4 - Check this ????				
				ld	HL,#TET_LS_NumLinesToDrop   ;;record number of lines needing  to be processed
				inc [HL]

				ret
				


                

