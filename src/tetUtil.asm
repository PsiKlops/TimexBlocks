;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; File Name :   tetUtil.asm
; Purpose   :   Tetris Wrist App Common Utility Routines
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;DO NOT MODIFY THE FOLLOWING SUBROUTINE DEFINITION;;;;;;;;;;;;;;;;;

                IF @DEF('SUBROUTINE')
                    UNDEF SUBROUTINE
                ENDIF
                DEFINE  SUBROUTINE      "'tetutil'"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                ; Add more Utility Routines below
                
				
               GLOBAL  tetCopyBlockFromIYToBlockAtIXAndPointIYAtIX
               
               ;;;IX = temp usually - so copies your block to temp block
tetCopyBlockFromIYToBlockAtIXAndPointIYAtIX:
                ld		HL,IX
				ld      [HL], [IY]
				
				inc		IX
                ld		HL, IX
                ld      [HL], [IY+1]
                
 				dec		IX
                ld      IY,IX
				ret	
				
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;tetBPB START;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;tetBPB START;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;tetBPB START;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;tetBPB START;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; ;;;; ;;;; ;;;;  ;;;; ;;;; BLOCK PARSE BLOCK ;;;; ;;;; ;;;; ;;;; ;;;;;;
;;;; ;;;; ;;;; ;;;;  ;;;; ;;;; BLOCK PARSE BLOCK ;;;; ;;;; ;;;; ;;;; ;;;;;;
;;;; ;;;; ;;;; ;;;;  ;;;; ;;;; BLOCK PARSE BLOCK ;;;; ;;;; ;;;; ;;;; ;;;;;;
;;;; ;;;; ;;;; ;;;;  ;;;; ;;;; BLOCK PARSE BLOCK ;;;; ;;;; ;;;; ;;;; ;;;;;;
;;;; ;;;; ;;;; ;;;;  ;;;; ;;;; BLOCK PARSE BLOCK ;;;; ;;;; ;;;; ;;;; ;;;;;;

                GLOBAL  tetUtilBPB
                
     			;;;ld [TET_ParseBlockX],#TET_INITIAL_BLOCK_START_X
				;;;ld [TET_ParseBlockY],#TET_INITIAL_BLOCK_START_Y
           
tetUtilBPB:
                
                car tetCopyBlockFromIYToBlockAtIXAndPointIYAtIX

               
                ld		HL,#TET_ParseBlockCountX
 				ld		[HL],#TET_INITIAL_DRAW_BLOCK_COUNT_X   ;=4
 				
tetBPBResetDrawBlockCountY:
                ld		HL,#TET_ParseBlockCountY
 				ld		[HL],#TET_INITIAL_DRAW_BLOCK_COUNT_Y
               
tetBPBLoopBack:
  				
  				;? push A
				ld	A,[TET_ParseBlockX]
				ld	B,[TET_ParseBlockY]
				
                ld		HL, IY    ;IY points to current 8 bit section of temp
                rrc		[HL]
                jr	C, tetBPBDoBlockBitSetAction		; if 1 then draw at location
                car tetUtilParseEmptyPixel		; else clear at location        
				
tetBPBCountNibble:

                ld		HL, #TET_ParseBlockY
                inc		[HL]

                ld		HL, #TET_ParseBlockCountY
                dec		[HL]
                
              
                jr		NZ,tetBPBLoopBack
                
                ld		HL, #TET_ParseBlockY
                sub		[HL],#TET_INITIAL_DRAW_BLOCK_COUNT_Y			;Done Nibble so reset y location 
                
                ld		HL, #TET_ParseBlockX
                inc		[HL]											;and move to next X location along
                
                ld		HL, #TET_ParseBlockCountX
                dec		[HL]

                cp		[HL],#2											;are we halfway there? 
                jr		Z,tetBPBGetNextNibblePair						;if so get  next 8bit mask register 
               
                cp		[HL],#0											;are we all the way there?
                jr		Z,tetBPBEnd
               
                jr		tetBPBResetDrawBlockCountY
               
				jr tetBPBEnd
				
tetBPBGetNextNibblePair:
                ld      IY,#TET_Temp_Shape_15_8
                jr		tetBPBResetDrawBlockCountY
				
tetBPBDoBlockBitSetAction:
				car	tetUtilParseSolidPixel
				jr	tetBPBCountNibble

tetBPBEnd:
				ret
				
;;;;;;tetBPB END;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;tetBPB END;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;tetBPB END;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;tetBPB END;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


tetUtilParseEmptyPixel:
                ld      HL, #TETDisplayStatus
                ;bit     [HL], #bTET_Draw_Location
                ;jr      NZ, tetClearPixel
                
                ;bit     [HL], #bTET_Clear_Location
                ;jr      NZ, tetClearPixel
                
                bit     [HL], #bTET_Rotate_RotBlock
                jr      NZ, tetUtilRotateEmptyPixel
                
                ;bit     [HL], #bTET_Test_Location
                ;jr      NZ, tetUtilRotateEmptyPixel
                
                ;bit     [HL], #bTET_TestPixel
                ;jr      NZ, tetUtilRotateEmptyPixel

				ret
				
tetUtilParseSolidPixel:
                ld      HL, #TETDisplayStatus
                bit     [HL], #bTET_Draw_Location
                jr      NZ, tetDrawPixel
                
                bit     [HL], #bTET_Clear_Location
                jr      NZ, tetClearPixel
                
                bit     [HL], #bTET_Rotate_RotBlock
                jr      NZ, tetUtilRotateFullPixel
               
               
               ;;;;Test location and test pixel are grouped together and related
                bit     [HL], #bTET_Test_Location
                car      NZ, tetUtilTestLocation
                
                ld      HL, #TETDisplayStatus             
                bit     [HL], #bTET_TestPixel
                
                ld	A,[TET_ParseBlockX]  ;;if done location test, will need to make sure these are valid
				ld	B,[TET_ParseBlockY]

                jr      NZ, tetUtilTestPixel
               
				ret
		
;;;;;;;;;;;;;;;;;; ROTATE A BLOCK CLOCKWISE 90 Deg START ;;;;;;;;;;;;;;;;;;;;			
;;;;;;;;;;;;;;;;;; ROTATE A BLOCK CLOCKWISE 90 Deg START ;;;;;;;;;;;;;;;;;;;;			
;;;;;;;;;;;;;;;;;; ROTATE A BLOCK CLOCKWISE 90 Deg START ;;;;;;;;;;;;;;;;;;;;			
;;;;;;;;;;;;;;;;;; ROTATE A BLOCK CLOCKWISE 90 Deg START ;;;;;;;;;;;;;;;;;;;;			
tetUtilRotateEmptyPixel:
				ld		A,#0
				jr		tetUtilRotStart
tetUtilRotateFullPixel:
 				ld		A,#1
tetUtilRotStart:
				ld		HL, #TET_ParseBlockCountY
                cp		[HL],#3                   
                jr		GE,tetRotSkipNextReg
                
 				ld      IX, #TET_RotateTemp_Shape_7_0  ;initialise new temp register               
                jr		tetRotContinue
tetRotSkipNextReg:
  				ld      IX, #TET_RotateTemp_Shape_15_8  ;initialise new temp register               
   
tetRotContinue:                  
				ld		HL, IX  ; get current temp register
                or		[HL], A
                swap	[HL]  ;swap ready for next
				
				ld		HL, #TET_ParseBlockCountY
                cp		[HL],#1                   
                jr		NZ,tetRotEnd
                
				ld		HL, #TET_RotateTemp_Shape_15_8
  				rrc		[HL]
				ld		HL, #TET_RotateTemp_Shape_7_0
  				rrc		[HL]
  				
tetRotEnd:
				ret
;;;;;;;;;;;;;;;;;; ROTATE A BLOCK CLOCKWISE 90 Deg END ;;;;;;;;;;;;;;;;;;;;			
;;;;;;;;;;;;;;;;;; ROTATE A BLOCK CLOCKWISE 90 Deg END ;;;;;;;;;;;;;;;;;;;;			
;;;;;;;;;;;;;;;;;; ROTATE A BLOCK CLOCKWISE 90 Deg END ;;;;;;;;;;;;;;;;;;;;			
;;;;;;;;;;;;;;;;;; ROTATE A BLOCK CLOCKWISE 90 Deg END ;;;;;;;;;;;;;;;;;;;;			
	
;;;;;;;;;;;;;;	Check if A (X), B(Y) location coincides with the value in TET_TestBlockPosX,Y
tetUtilTestLocation:

                ld      HL, #TETDisplayStatus
                bit     [HL], #bTET_DontTestXWall
                jr      NZ, tetUtilTestY

				ld	HL,#TET_TestBlockPosX
				cp	[HL],A				
				jr	NZ, tetUtilTestY ;; -- pleaase fix it!!!!!!!!!!!!!!!!!!!!!!
				jr	tetUtilTestSetHit			
			
tetUtilTestY:
                ld      HL, #TETDisplayStatus
                bit     [HL], #bTET_DontTestYWall
                jr      NZ, tetUtilWallNotFound

				ld	HL,#TET_TestBlockPosY
				ld	A,B
				cp	[HL],A
				jr	NZ, tetUtilWallNotFound
tetUtilTestSetHit:				
                ld		HL,#TET_Flags                
                or		[HL],#bTET_HitAnyWall    ;set the hit flag
                ret
				
				
tetUtilWallNotFound:			
                ;ld		HL,#TET_Flags                
                ;and		[HL],#@LOW(~bTET_DontTestXWall)    ;clear the hit flag eh ?
                ret
			
;;;;;;;;;;;;;;	
tetUtilTestPixel:
                LCD_GET_STATE_OF_PIXEL
                jr      Z, tetUtilPixelNotFound
                
                ld		HL,#TET_Flags                
                or		[HL],#bTET_HitPixel    ;set the hit pixel

tetUtilPixelNotFound:
				ret


			    
	
				
;;INCLUDE 'C:\M851\App\Tetris\src\tetCom.asm'
INCLUDE 'C:\M851\App\Tetris\src\tetComG.asm'