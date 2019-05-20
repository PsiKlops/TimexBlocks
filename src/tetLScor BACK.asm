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

                ; Set IYReg the address of the Tetris ASD.
                ld      IY, [CORECurrentASDAddress]

                ld      A, [CORECurrentEvent]

                ; Check if state entry event.
                cp      A, #TET_STATEENTRY
                jr      Z, tetLineScoreStateStateEntryEvent
                
				;;  This stop watch check is essentially a timer interrupt function at 16 Hz - put i
                cp      A, #COREEVENT_DISPLAY_UPDATE_STPRES
                jr		Z, tetLSFlashFullLines

                ; Check if mode depress event.
                ;cp      A, #TET_MODEDEPRESS
                ;jr      Z, tetDefaultStateModeDepressEvent

                ; Check if crown set event.
                ;cp      A, #TET_CROWNSET
                ;jr      Z, tetLineScorePulledCrownEvent

                ;cp      A, #COREEVENT_CW_EDGE_TRAILING
                ;jr      Z, tetMoveBlockRight

                ;cp      A, #COREEVENT_CCW_EDGE_TRAILING
                ;jr      Z, tetMoveBlockLeft
                
                ;cp      A, #COREEVENT_STARTSPLITDEPRESS
                ;jr      Z, tetRotateBlock

                ;cp      A, #COREEVENT_STOPRESETDEPRESS
                ;jr      Z, tetDrawBlock - set IY

                ;TODO: Add more events detection here
                ;There are more events, add your own as needed

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

                ; start our background timing generator
                ld      HL, [CORECurrentASDAddress]
                ld      A, [HL]
                KSTP_ENABLE_DISP_UPD_EVENT

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
				
				
                ;Now we have set the block, go to Switch the block state - takes care of 'next' block etc
                ;ld      B, #TET_SWITCH_BLOCK_STATE
                ;CORE_REQ_STATE_CHANGE_NO_CLEAR_DISPLAY
                ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;				
;;;;;		Kinda the initial thing to do in this state - Checks for any full lines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;				
tetLineScoreGetFullLinesDataAndScore:
				ld	HL,#TET_LS_Status 
				ld	[HL],#@LOW(bTET_LS_Initialised) ;; Effectivel clear all status/flags - tell it we've initialise

   				ld HL,#DEBUG_BREAKPOINT_VALUE   ;;TEMP TEST!!!!!!!!!!!!!!!!!!!
 				
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
				car tetLineScoreIsLineFull	;;Increments -> TET_LS_NumLinesToDrop and moves IX to point to next TET_LS_LinenX
				
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;				
tetLSFlashFullLines:
   				ld HL,#DEBUG_BREAKPOINT_VALUE   ;;TEMP TEST!!!!!!!!!!!!!!!!!!!

				ld	HL,#TET_LS_NumLinesToDrop  
				cp	[HL],#0
				jr	Z,tetLSFlashLinesLeave  ;;If no lines filled across then leave
				ld	IX,#TET_LS_Count		;;Otherwise copy number of lines needing to be processed to temp counter	
				ld	[IX],[HL]
				
				ld	IY,#TET_LS_Line1X  ; initialise first line record
				
tetLSFlashFullLinesLoopBack:
				ld	HL,#TET_LS_Status
				bit	[HL],#bTET_LS_FlashOn
				jr	NZ,tetLSFlashOn
				
tetLSFlashOff:
				car tetLineScoreClearLineAtIY_X
				jr	tetLSFFLIterate

tetLSFlashOn:
				car tetLineScoreDrawLineAtIY_X
				
tetLSFFLIterate:
				inc	IY			;Get next full line X address ready (if exists)
				
				ld  HL,IX		;Get loop counter
				dec	[HL]		;Dec loop count
				jr	NZ,	tetLSFlashFullLinesLoopBack
				
				ld	HL,#TET_LS_FlashCount
				dec	[HL]
				jr	Z,tetLSFlashLinesLeaveAndScreenRejig     ;;If done all the flashes then leave and get next block (for now)

				
				ld	HL,#TET_LS_Status
				bit	[HL],#bTET_LS_FlashOn
				jr	NZ,tetLSSwitchFlashOff
				or	[HL],#bTET_LS_FlashOn   ;Switch flash on
				ret
tetLSSwitchFlashOff:
				and	[HL],#@LOW(~bTET_LS_FlashOn)   ;Switch flash off
				ret
tetLSFlashLinesLeaveAndScreenRejig:
				jr	tetRejigTheWholeScreen
tetLSFlashLinesLeave:
				jr	tetLSBackToDefaultState
				ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;				
;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;				
tetLSBackToDefaultState:
 				ld	HL,#TET_LS_Status 
				ld	[HL],#0					;;Clear all status/flags
              
                ;Now we have flashed set the block, go to Switch the block state - takes care of 'next' block etc
                ld      B, #TET_SWITCH_BLOCK_STATE
                CORE_REQ_STATE_CHANGE_NO_CLEAR_DISPLAY
                ret

				
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;				
;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;				
tetLineScoreDropLinesAndrefreshScreen:
				ret
				
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;				
;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;				
tetLineScoreDrawLineAtIY_X:
				ld	HL,#TET_ParseBlockY
				ld	[HL],#TET_LS_START_Y
				
tetLSDrawLineLoopBack:
				ld	A,[IY]
				ld	HL,#TET_ParseBlockY  ; reset Y
				ld	B,[HL]
				
				LCD_DISPLAY_MAIN_DM_PIXEL
				
				ld	HL,#TET_ParseBlockY				
				inc	[HL]
				cp	[HL],#12
				jr	NZ,tetLSDrawLineLoopBack

				ret
				
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;				
;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;				
tetLineScoreClearLineAtIY_X:
				ld	HL,#TET_ParseBlockY
				ld	[HL],#TET_LS_START_Y
				
tetLSClearLineLoopBack:
				ld	A,[IY]
				ld	HL,#TET_ParseBlockY  ; reset Y
				ld	B,[HL]
				
				LCD_CLEAR_MAIN_DM_PIXEL
				
				ld	HL,#TET_ParseBlockY				
				inc	[HL]
				cp	[HL],#12
				jr	NZ,tetLSClearLineLoopBack
				ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;				
;;;;;
;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;				
tetLineScoreIsLineFull:
				ld	HL,#TET_LS_PixelCount
				ld	[HL],#0

tetLSIsLineFullLoopBack:
				ld	IY,#TET_ParseBlockX
				ld	A,[IY]
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
				
				ld	[IX],[IY]	;;Full line so record the X coordinate
				inc	IX			;;increment line record - max 4 - Check this ????
				
				ld	HL,#TET_LS_NumLinesToDrop   ;;record number of lines needing  to be processed
				inc [HL]

tetLSNotAFullLineEnd:
				cp	[HL],#0					;;Does line TET_LS_PixelCount=0
				jr NZ,tetLSFullLineReallyEnd
				
				ld	HL,#TET_LS_Status
				or	[HL],#bTET_LS_LineEmpty   ;Found an empty line so end testing (nothing should be floating above)

tetLSFullLineReallyEnd:
				ret
				
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;				
;;;;;	Now we've flashed, delete all the full lines and drop down all the blocks above
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;				
tetRejigTheWholeScreen:

;;Bit of un-optimised code repeating going now:-
				ld	HL,#TET_LS_NumLinesToDrop  
				cp	[HL],#0
				jr	Z,tetLSRejigLinesLeave  ;;Shouldnt happen but - If no lines filled across then leave
				
				ld	IX,#TET_LS_Count		;;Otherwise copy number of lines needing to be processed to temp counter	
				ld	[IX],[HL]
				
				ld	H,#0
				ld	L,[IX]   ;; get TET_LS_Count into HL pair
				
				ld	IY,#TET_LS_Line1X	;;	Initialise first line record
				add	IY,HL				;;	Increment add by how many lines 
				dec IY					;;	IY should point at the top/highest X position (lowest value) - crossed fingers
				
				;;First we clear all the full lines pixels off the screen once and for all
tetLSRejigFirstClearLinesLoopBack:
				car		tetLineScoreClearLineAtIY_X
				car		tetPulldownEverythingAboveIYTillClearLine  ;;Drop down all blocks (pixels) above this cleared line
				
				dec	IY			;Get next full line X address ready (if exists)
								
				ld  HL,IX		;Get loop counter
				dec	[HL]		;Dec loop count
				jr	NZ,	tetLSRejigFirstClearLinesLoopBack


tetLSRejigLinesLeave:
				jr	tetLSBackToDefaultState
				ret
				
tetPulldownEverythingAboveIYTillClearLine:
				ret

                
 INCLUDE 'C:\M851\App\Tetris\src\tetCom.asm'

                

