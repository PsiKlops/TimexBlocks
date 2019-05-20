;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; File Name :   tetDisp.asm
; Purpose   :   Tetris Wrist App Common Display Routines
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;DO NOT MODIFY THE FOLLOWING SUBROUTINE DEFINITION;;;;;;;;;;;;;;;;;

                IF @DEF('SUBROUTINE')
                    UNDEF SUBROUTINE
                ENDIF
                DEFINE  SUBROUTINE      "'tetdisp'"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Module Name : tetwaDefaultDisplay
; Description : Display MODE DEFAULT at default entry. This is merely used by the wizard
; Input(s)    : None
; Output(s)   : None
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                GLOBAL  tetwaDefaultDisplay

tetwaDefaultDisplay:

                ld        IY,#tetwaDefaultDisplayLine1
                ld        IX,#tetwaDefaultDisplayLine2
                car       tetwaDisplayLine1Line2

                jr        tetwaDefaultDisplayExit

; STU GAME
tetwaDefaultDisplayLine1:
                dw        LCDMAINDMLINE1COL10
                db        3, DM5_S, DM5_T, DM5_U

tetwaDefaultDisplayLine2:
                dw        LCDMAINDMLINE2COL6
                db        4, DM5_G, DM5_A, DM5_M, DM5_E

tetwaDefaultDisplayExit:

                ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Module Name : tetwaSetDisplay
; Description : Display SET DEFAULT at set default entry. This is merely used by the wizard
; Input(s)    : None
; Output(s)   : None
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                GLOBAL  tetwaSetDisplay

tetwaSetDisplay:

                ld        IY,#tetwaSetDisplayLine1
                ld        IX,#tetwaSetDisplayLine2
                car       tetwaDisplayLine1Line2

                jr        tetwaSetDisplayExit

tetwaSetDisplayLine1:
                dw        LCDMAINDMLINE1COL14
                db        3, DM5_S, DM5_E, DM5_T

tetwaSetDisplayLine2:

                dw        LCDMAINDMLINE2COL6
                db        7, DM5_D, DM5_E, DM5_F, DM5_A, DM5_U,DM5_L,DM5_T

tetwaSetDisplayExit:

                ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Module Name : tetwaDisplayLine1Line2
; Description : Display message at Main Dot Matrix Line 1 and Line 2
; Input(s)    : IY = table address for Line1, IX = table address for Line2
; Output(s)   : None
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

tetwaDisplayLine1Line2:

                push      IX
                LCD_DISP_FORMATTED_SMALL_PROP_WIDTH_DM_MSG

                pop       IX
                ld        IY,IX
                LCD_DISP_FORMATTED_SMALL_PROP_WIDTH_DM_MSG

tetwaDisplayLine1Line2Exit:
                ret

;TET_SIDELINE_START_X               equ       22
;TET_SIDELINE_START_Y               equ       11
;TET_SIDELINE_LENGTH_X              equ       20

                GLOBAL  tetDrawSideLine
                GLOBAL  tetDrawSideLineNoClear

;DRAW THE LINE DELINEATING THE SIDE OF THE TETRIS AREA
;DRAW THE LINE DELINEATING THE SIDE OF THE TETRIS AREA
;DRAW THE LINE DELINEATING THE SIDE OF THE TETRIS AREA

tetDrawSideLine:
				;clear main dot-matrix
				LCD_CLEAR_MAIN_DM
				
tetDrawSideLineNoClear:
				
				ld	A,#TET_SIDELINE_START_X
				ld	B,#TET_SIDELINE_START_Y
				
tetNextDrawBlockInLine:
				push A
				car tetDrawPixel
				
				pop A
				dec A		
				cp	A,#TET_SIDELINE_END_X
				
				jr	Z,tetFinishedDrawingSideLine
				
				ld	B,#TET_SIDELINE_START_Y
				jr tetNextDrawBlockInLine
				
tetFinishedDrawingSideLine:
				ret
				
				

				
 
                GLOBAL  tetDoBlockBitEmptyAction
tetDoBlockBitEmptyAction:

                GLOBAL  tetClearPixel
tetClearPixel:
                LCD_CLEAR_MAIN_DM_PIXEL
                ret
                
                GLOBAL  tetDrawPixel
tetDrawPixel:
                LCD_DISPLAY_MAIN_DM_PIXEL
                ret



;==============================================================================
;
;                THIS IS YOUR COSTUMIZED MODE BANNER CREATED FROM WRISTAPP WIZARD
;
;==============================================================================

                GLOBAL      tetBannerMsg
tetBannerMsg:

                db        LCDBANNER_COL1, DM5_BLANK, DM5_B, DM5_L, DM5_O, DM5_C, DM5_K, DM5_S
                db        LCD_END_BANNER


                ;TODO: Add your own functionality display below or edit above display routines
                
tetHighScoreData:
                dw        0   ; use this space to save your high score


