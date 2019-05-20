;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; File Name    : tetLScr2.asm
; Purpose      : Tetris Application Default State Manager
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;DO NOT MODIFY THE FOLLOWING SUBROUTINE DEFINITION;;;;;;;;;;;;;;;;;

                IF @DEF('SUBROUTINE')
                    UNDEF SUBROUTINE
                ENDIF
                DEFINE  SUBROUTINE      "'tetLScr2'"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Module Name : tetMoveDownStateManager
; Description : Tetris Application Delete any full lines and score them - part 2 - Fit it in memory by splitting original!
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
                jr      Z, tetLineScore2StateStateEntryEvent
                
				;;  This stop watch check is essentially a timer interrupt function at 16 Hz - put i
                cp      A, #COREEVENT_DISPLAY_UPDATE_STPRES
                jr		Z, tetLSFlashFullLines
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

tetLineScore2StateStateEntryEvent:
                ;**************************************************************
                ;
                ;                       STATE ENTRY
                ;
                ;**************************************************************

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
             
				
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;				
;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;				
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;				
;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;				
tetLSFlashFullLines:
   				;ld HL,#DEBUG_BREAKPOINT_VALUE   ;;TEMP TEST!!!!!!!!!!!!!!!!!!!

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
                ;Now we have flashed set the block, go to Switch the block state - takes care of 'next' block etc
                ld      B, #TET_SWITCH_BLOCK_STATE
                CORE_REQ_STATE_CHANGE_NO_CLEAR_DISPLAY
                ret

				
				
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;				
;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;				
tetLineScoreDrawLineAtIY_X:
				ld	HL,#TET_ParseBlockY
				ld	[HL],#TET_LS_START_Y
				
tetLSDrawLineLoopBack:
				ld	A,[IY]
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
								
				car		tetLSIncrementScore			;Add up our score (destroys HL!)

				ld		HL,IX		;Get loop counter
				dec		[HL]		;Dec loop count
							
				jr	NZ,	tetLSRejigFirstClearLinesLoopBack

tetLSRejigLinesLeave:
				jr		tetLSBackToDefaultState
				ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;				
tetPulldownEverythingAboveIYTillClearLine:
				ld	HL,#TET_ParseBlockX
				ld	[HL],[IY]
				
tetPDEAIYTCLLoopBack:
				dec	[HL]    ;;Get the next line above
				
				cp	[HL],#TET_TOP_SCREEN_X
				jr	Z,tetLeavePullDownEverything    ;;This shouldnt happen???????????????? -= Check it
				
				ld	HL,#TET_ParseBlockY  ;;Reset Y parse
				ld	[HL],#TET_LS_START_Y
				
				car tetLineScoreIsLineFull	
				
				ld	HL,#TET_LS_Status
				bit	[HL],#bTET_LS_LineEmpty   
				jr	NZ,tetLeavePullDownEverything ;;Found line above IY is empty so end testing (nothing else should be floating above)

				ld	HL,#TET_ParseBlockY  ;;Reset Y parse
				ld	[HL],#TET_LS_START_Y
				car	tetLineScoreCopyLineDown
				
				ld	HL,#TET_ParseBlockX ;; get Parse X back for loop back
				jr tetPDEAIYTCLLoopBack
				


tetLeavePullDownEverything:
				ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;				
;;;;;
;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;				
tetLineScoreCopyLineDown:

tetLSCopyLineDownLoopBack:
				ld	HL,#TET_ParseBlockX
				ld	A,[HL]
				ld	HL,#TET_ParseBlockY
				ld	B,[HL]
								
                LCD_GET_STATE_OF_PIXEL
                jr      Z, tetLSCopyLineDownPixelNotFound
                
				ld	HL,#TET_ParseBlockX
				ld	A,[HL]
				inc A				;Next line down
				ld	HL,#TET_ParseBlockY
				ld	B,[HL]
				
				LCD_DISPLAY_MAIN_DM_PIXEL

				ld	HL,#TET_ParseBlockX
				ld	A,[HL]
				ld	HL,#TET_ParseBlockY
				ld	B,[HL]

				LCD_CLEAR_MAIN_DM_PIXEL  ;;Now clear what we copied
				
tetLSCopyLineDownPixelNotFound:
				ld	HL,#TET_ParseBlockY
				inc	[HL]
				cp	[HL],#12
				jr	NZ,tetLSCopyLineDownLoopBack				
				ret
				
tetLSIncrementScore:
				ld	HL,#TET_Score2	
				inc [HL]
				
				cp	[HL],#100		;These are BCDs so switch over at 100
				jr	NZ,tetDontIncrementHundreds
				
				ld	[HL],#0			;reset 1s and 10s to Zero

				ld	HL,#TET_Score1	;add to 
				inc [HL]

				cp	[HL],#100		;
				jr	NZ,tetDontCycleHundreds
				
				ld	[HL],#0			;Cycle round to zero we have reached limit !!
				
tetDontCycleHundreds:
tetDontIncrementHundreds:
				ret
				

                

                

