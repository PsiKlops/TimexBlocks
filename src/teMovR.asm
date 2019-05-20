;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; File Name    : tetMovR.asm
; Purpose      : Tetris Application Default State Manager
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;DO NOT MODIFY THE FOLLOWING SUBROUTINE DEFINITION;;;;;;;;;;;;;;;;;

                IF @DEF('SUBROUTINE')
                    UNDEF SUBROUTINE
                ENDIF
                DEFINE  SUBROUTINE      "'tetMovR'"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Module Name : tetMoveRightStateManager
; Description : Tetris Application Default State Manager.
; Assumptions : Display is cleared on first time entry into the state.
; Input(s)    : CORECurrentEvent  - system event to be processed
;               COREEventArgument - event extra information
; Output(s)   : None
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                GLOBAL  tetMoveRightStateManager

tetMoveRightStateManager:
                ld      A, [CORECurrentEvent]

                ; Check if state entry event.
                cp      A, #TET_STATEENTRY
                jr      Z, tetDefaultStateStateEntryEvent

                ; Check if mode depress event.
                ;cp      A, #TET_MODEDEPRESS
                ;jr      Z, tetDefaultStateModeDepressEvent

                ; Check if crown set event.
                ;cp      A, #TET_CROWNSET
                ;jr      Z, tetDefaultPulledCrownEvent

                ;cp      A, #COREEVENT_CW_EDGE_TRAILING
                ;jr      Z, tetMoveBlockRight

                ;cp      A, #COREEVENT_CCW_EDGE_TRAILING
                ;jr      Z, tetMoveBlockLeft
                
                ;cp      A, #COREEVENT_STARTSPLITDEPRESS
                ;jr      Z, tetRotateBlock

                ;cp      A, #COREEVENT_STOPRESETDEPRESS
                ;jr      Z, tetDrawBlock

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
                ld      IY, #TET_Current_Shape_7_0  ;;Set IY externally to draw/clear  shape so we can draw 'next' block as well
				car		tetClearBlock  ;;and draw straight after TEMP!!

				car		tetMoveBlockRight

                ; start our background timing generator
                ld      HL, [CORECurrentASDAddress]
                ld      A, [HL]
                KSTP_ENABLE_DISP_UPD_EVENT
                ret
                
tetMoveBlockRight:

                ld		HL,#TET_Flags                
                and		[HL],#TET_CLEAR_HIT_FLAGS
                
                ld      IY, #TET_Current_Shape_7_0  ;;Set IY externally to draw/clear  shape so we can draw 'next' block as well
				car		tetClearBlock  ;;delete the block before the move (if any)


                ld		HL,#TETDisplayStatus                
                and		[HL],#TET_CLEAR_PARSER_STATUS
                or		[HL],#bTET_Test_Location		;Check test locations
                or		[HL],#bTET_DontTestXWall		;Just check Y walls not exact point
                or		[HL],#bTET_TestPixel			;Now improved added pixel test!

                ;;Just set the Y pos for testing as we ignore X
                ld		HL,#TET_TestBlockPosY
                ld		[HL],#TET_LIMIT_BLOCK_RIGHT_Y
				
				;; Move RIGHT to putative new position
	            ld		HL, #TET_BlockPosY
                dec		[HL]
                
                car		tetGetCurrentBlockPosIntoParserPos  ;;Since this destroys IX put it here!
                 
                ld      IY, #TET_Current_Shape_7_0
                ld      IX, #TET_Temp_Shape_7_0
                
                              
				;;now do the check	
                car	tetUtilBPB
                			
				;;See if we hit a wall
                ld		HL, #TET_Flags
                bit		[HL],#TET_HIT_PIXEL_OR_WALL
                
                Jr		Z,Tet_NoWallHitRightOk

				;;We Hit a wall so put it back how it was!!
	            ld		HL, #TET_BlockPosY
                inc		[HL]
                
Tet_NoWallHitRightOk:
                ld      IY, #TET_Current_Shape_7_0  ;;Set IY externally to draw/clear  shape so we can draw 'next' block as well
				car	tetDrawBlock  ;;Draw the block back in old/new position
                ;Now we have set the block, Go back to main default state
                ld      B, #TETDEFAULTSTATE
                CORE_REQ_STATE_CHANGE_NO_CLEAR_DISPLAY
                ret
                
 ;INCLUDE 'C:\M851\App\Tetris\src\tetCom.asm'

                

