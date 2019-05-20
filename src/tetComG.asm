;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; File Name :   tetComG.asm
; Purpose   :   Tetris Wrist App Common Utility Routines
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;ATTEMPT AT A COMMON FILE WITH COMMON FUNCTIONS TO BE INCLUDED IN MULTIPLE STATES;;;;;;;;;;;;;;;;;

                GLOBAL  tetGetCurrentBlockPosIntoParserPos
				
;;; *** Every time we call the block parser function 'tetUtilBPB' copy over its block pos XY to the parser pos XY variables		
;;; *** Every time we call the block parser function 'tetUtilBPB' copy over its block pos XY to the parser pos XY variables		
;;; *** Every time we call the block parser function 'tetUtilBPB' copy over its block pos XY to the parser pos XY variables		
tetGetCurrentBlockPosIntoParserPos:   ;DESTROYS HL AND IY!!!!!!!!!!!!!!!!!!!!!!!!!!

				ld		HL,#TET_GameStatus
				bit		[HL],#bTET_GS_DrawAtNextPos
				jr		NZ,TET_ComDrawAtNextPos
				
                ld		HL,#TET_ParseBlockX
                ld		IX,#TET_BlockPosX
				ld      [HL], [IX]
				
                ld		HL,#TET_ParseBlockY
                ld		IX,#TET_BlockPosY                             
				ld      [HL], [IX]
				ret
				
TET_ComDrawAtNextPos:
				ld		HL,#TET_ParseBlockX
				ld		[HL],#TET_NEXT_BLOCK_START_X
				ld		HL,#TET_ParseBlockY
				ld		[HL],#TET_NEXT_BLOCK_START_Y
				ret
				
				
				ret
		
;;;; ***** ;;;; ***** COMMON DRAW FUNCTION ;;;; ***** ;;;; ***** 
;;;; ***** ;;;; ***** COMMON DRAW FUNCTION ;;;; ***** ;;;; ***** 
;;;; ***** ;;;; ***** COMMON DRAW FUNCTION ;;;; ***** ;;;; ***** 
                GLOBAL  tetDrawBlock
                GLOBAL  tetClearBlock
tetDrawBlock:
				ld		A,#bTET_Draw_Location
				jr		tetContinueDrawClear
tetClearBlock:
				ld		A,#bTET_Clear_Location
tetContinueDrawClear:

				;;Get current screen X Y positions
				car		tetGetCurrentBlockPosIntoParserPos  ;; this destroys IX now not IY
				
                ;;ld      IY, #TET_Current_Shape_7_0  ;;Set IY externally to draw/clear  shape so we can draw 'next' block as well
                ld      IX, #TET_Temp_Shape_7_0
                
                                
                ld		HL,#TETDisplayStatus                
                and		[HL],#TET_CLEAR_PARSER_STATUS
                or		[HL],A					; set the parsing mode for function tetBPB - DRAW or CLEAR depending 
                
                
                car	tetUtilBPB
                
				;car tetDrawFallingBlock   ; temp
				
				ret
				
;;;; ***** ;;;; ***** COMMON ROTATE FUNCTION ;;;; ***** ;;;; ***** 
;;;; ***** ;;;; ***** COMMON ROTATE FUNCTION ;;;; ***** ;;;; ***** 
;;;; ***** ;;;; ***** COMMON ROTATE FUNCTION ;;;; ***** ;;;; ***** 
                GLOBAL  tetRotateBlock
				
tetRotateBlock:
                ld      IY, #TET_Current_Shape_7_0  ;;Set IY externally to draw/clear  shape so we can draw 'next' block as well
				car		tetClearBlock  ;;and draw straight after TEMP!!
				
                ld      A, #0							;Clear work area
                ld      [TET_RotateTemp_Shape_7_0], A
                ld      [TET_RotateTemp_Shape_15_8], A
                                
                ld      IY, #TET_Current_Shape_7_0		;point to block to rotate
                ld      IX, #TET_Temp_Shape_7_0
                
                ld		HL,#TETDisplayStatus                
                and		[HL],#TET_CLEAR_PARSER_STATUS
                or		[HL],#bTET_Rotate_RotBlock  ; set the parsing mode for function tetBPB - ROTATE
                
 				;;Get current screen X Y positions
				;car		tetGetCurrentBlockPosIntoParserPos
				
				car		tetUtilBPB
												           
                ld      HL, #TETDisplayStatus
                bit     [HL], #bTET_3_x_3_Rotate
                jr      Z, tetSkip3x3Rotate

                ;;if block a 3x3 type then fix up the bit map
				ld      HL, #TET_RotateTemp_Shape_7_0
				rrc		[HL]
				ld      HL, #TET_RotateTemp_Shape_15_8
				rrc		[HL]
				
				
tetSkip3x3Rotate:
				car	tetCheckCollideWithAnything					
				;;See if we hit anything
                ld		HL, #TET_Flags
                bit		[HL],#TET_HIT_PIXEL_OR_WALL
				jr		NZ,tetRotateCollidedSoLeaveCurrentUnchanged


				ld      IY, #TET_RotateTemp_Shape_7_0
                ld      IX, #TET_Current_Shape_7_0
				car		tetCopyBlockFromIYToBlockAtIXAndPointIYAtIX  ;;now copy the block from temp
				
				
tetRotateCollidedSoLeaveCurrentUnchanged:
                ld      IY, #TET_Current_Shape_7_0  ;;Set IY externally to draw/clear  shape so we can draw 'next' block as well
				car		tetDrawBlock  ;;and draw straight after TEMP!!
				
				ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;	
;;TODO: Yes yes, this func is in common and repeats stuff done in the move states - but we have space enough for now		
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
                GLOBAL  tetCheckCollideWithAnything
                
tetCheckCollideWithAnything:
				;;;I want to check this rotated shape at current position first
				;;; before I commit to copying it over to 'Current'
				
				;;FIRST CLEAR HIT FLAGS!!!
				ld		HL,#TET_Flags                
                and		[HL],#TET_CLEAR_HIT_FLAGS
                
				;;;;;;ld HL,#DEBUG_BREAKPOINT_VALUE   ;;TEMP TEST!!!!!!!!!!!!!!!!!!!

                ld		HL,#TETDisplayStatus                
                and		[HL],#TET_CLEAR_PARSER_STATUS
                or		[HL],#bTET_Test_Location		;Check boundary locations -  X and Y - both walls and floor
                or		[HL],#bTET_TestPixel			;Now improved added pixel test!
                
                ;; set the X pos (floor) for testing  - this is probably always the same value so just do once??
                ld		HL,#TET_TestBlockPosX
                ld		[HL],#TET_LIMIT_BLOCK_X
                ;; set the Y pos for testing  - left wall as default
                ld		HL,#TET_TestBlockPosY
                ld		[HL],#TET_LIMIT_BLOCK_LEFT_Y
				
                ld		HL,#TET_BlockPosY  ; see which wall we are nearest                           
				cp      [HL], #TET_LIMIT_CHECK_MID_POINT
				jr		GE,Tet_SkipCheckRightWall
				
                ;; We are nearer the right wall so set the Y pos for testing right wall position
                ld		HL,#TET_TestBlockPosY
                ld		[HL],#TET_LIMIT_BLOCK_RIGHT_Y
				
Tet_SkipCheckRightWall:
                car		tetGetCurrentBlockPosIntoParserPos  ;;Since this destroys IX put it here!              
                ld      IY, #TET_RotateTemp_Shape_7_0
                ld      IX, #TET_Temp_Shape_7_0
                ;;;;
				;;now do the check	
                car	tetUtilBPB
				;;See if we hit the floor
                ;ld		HL, #TET_Flags
                ;bit		[HL],#TET_HIT_PIXEL_OR_WALL
                ;Jr		Z,Tet_ComNoFloorOrBlockHitOk
                
                ;ld		A,#01
                ;ret

Tet_ComNoFloorOrBlockHitOk:
	            ;ld		A,#0
				ret
				

				

