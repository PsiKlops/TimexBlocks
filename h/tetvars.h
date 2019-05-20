;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; File Name :   tetvars.h
; Purpose   :   Tetris Application Variable Offsets
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;==============================================================================
;
; Tetris APPLICATION SYSTEM DATA
;
;==============================================================================

TETSYSTEMDATASTARTOFFSET        equ        0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Do not change this variable but change the value if necessary.
; The equate value of this, is the last number from the above variables plus 1
; When you add variables above, be sure to change the value of this too.

TETSTOPWATCHRESOURCE0OFFSET     equ			0
TETSYSTEMDATASIZE               equ        1
;Resource Index
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;==============================================================================
;
; Tetris COMMON VARIABLE REDEFINITIONS
;
;==============================================================================
; variables to be use on foreground operation
TETDisplayStatus                equ     (COREForegroundCommonBuffer + 0)
bTET_Test_Location              equ     10000000b
bTET_Draw_Location              equ     01000000b
bTET_Clear_Location             equ     00100000b
bTET_Rotate_RotBlock			equ     00010000b
bTET_TestPixel					equ     00001000b
bTET_3_x_3_Rotate			    equ     00000100b
bTET_DontTestXWall              equ     00000010b
bTET_DontTestYWall				equ     00000001b

TET_CLEAR_TEST_XY_WALL			equ		@LOW(~(bTET_DontTestXWall | bTET_DontTestYWall ))
TET_CLEAR_PARSER_STATUS			equ		@LOW(~(bTET_Test_Location | bTET_Draw_Location | bTET_Clear_Location | bTET_Rotate_RotBlock | bTET_TestPixel | bTET_DontTestXWall | bTET_DontTestYWall))
;Current shapes bitmap falling on screen two bytes for 16 bit 4X4 bit map
TET_Current_Shape_7_0             equ     (COREForegroundCommonBuffer + 1)
TET_Current_Shape_15_8            equ     (COREForegroundCommonBuffer + 2)

;;0xBF
TET_Temp_Shape_7_0                equ     (COREForegroundCommonBuffer + 3)

;;0xC0
TET_Temp_Shape_15_8               equ     (COREForegroundCommonBuffer + 4)
;;0xC1
TET_ParseBlockX					equ     (COREForegroundCommonBuffer + 5)
TET_ParseBlockY					equ     (COREForegroundCommonBuffer + 6)

TET_ParseBlockCountX				equ     (COREForegroundCommonBuffer + 7)
TET_ParseBlockCountY				equ     (COREForegroundCommonBuffer + 8)

;;0xC5
TET_RotateTemp_Shape_7_0				equ     (COREForegroundCommonBuffer + 9)
TET_RotateTemp_Shape_15_8				equ     (COREForegroundCommonBuffer + 10)

TET_CurrentBlockType					equ     (COREForegroundCommonBuffer + 11)
;;0xC8
TET_BlockPosX						equ     (COREForegroundCommonBuffer + 12)
TET_BlockPosY						equ     (COREForegroundCommonBuffer + 13)
;;0xCA
TET_TestBlockPosX					equ     (COREForegroundCommonBuffer + 14)
TET_TestBlockPosY					equ     (COREForegroundCommonBuffer + 15)

;;0xCC
TET_Flags							equ     (COREForegroundCommonBuffer + 16)
bTET_HitRightWall					equ     10000000b
bTET_HitLeftWall					equ     01000000b
bTET_HitFloor						equ     00100000b
bTET_HitPixel						equ     00010000b
bTET_HitAnyWall						equ     00001000b
TET_CLEAR_HIT_FLAGS			equ		@LOW(~(bTET_HitRightWall | bTET_HitLeftWall | bTET_HitFloor | bTET_HitPixel | bTET_HitAnyWall))

TET_HIT_PIXEL_OR_WALL			equ		@LOW( bTET_HitAnyWall | bTET_HitPixel )

TET_TopX						equ     (COREForegroundCommonBuffer + 17)
TET_BotX						equ     (COREForegroundCommonBuffer + 18)
TET_RightY						equ     (COREForegroundCommonBuffer + 19)
TET_LeftY						equ     (COREForegroundCommonBuffer + 20)
;;0xD1
TET_CurrFallRate						equ     (COREForegroundCommonBuffer + 21)
;;TET_Score						equ     (COREForegroundCommonBuffer + 22)
;;0xD2
TET_GameStatus						 equ     (COREForegroundCommonBuffer + 23)
bTET_GS_Running						equ     10000000b
bTET_GS_BlockFalling				equ     01000000b
bTET_GS_FallSpeed_1					equ     00100000b
bTET_GS_FallSpeed_2					equ     00010000b
bTET_GS_DrawAtNextPos				equ     00001000b
bTET_GS_FallSpeedQuick				equ     00000100b
bTET_GS_BlkSwitchInit				equ     00000010b
bTET_GS_MsgFlashOn					equ     00000001b

TET_GAME_STATUS_START_FLAGS			equ		@LOW( bTET_GS_Running | bTET_GS_BlockFalling | bTET_GS_FallSpeed_1 )

;;0x57
TET_FallUpdateCnt				 equ     (COREWorkBuffer +  0)
TET_GameUpdateCnt                equ     (COREWorkBuffer +  1)
TET_NextBlockType				 equ     (COREWorkBuffer +  2)
TET_OldShapeOrRot_7_0            equ     (COREWorkBuffer +  3)
TET_OldShapeOrRot_15_8           equ     (COREWorkBuffer +  4)
TET_NextShape_7_0				equ     (COREWorkBuffer +  5)
TET_NextShape_15_8				equ     (COREWorkBuffer +  6)
TET_NextShapeNum				equ     (COREWorkBuffer +  7)

;;Line Score Data
TET_LS_Flags					equ     (COREWorkBuffer +  8)

;;0x60
TET_LS_Status					equ     (COREWorkBuffer +  9)
bTET_LS_Initialised				equ     10000000b
bTET_LS_Flashing				equ     01000000b
bTET_LS_FlashOn					equ     00100000b
bTET_LS_LineEmpty				equ     00010000b
bTET_LS_LineFull				equ     00001000b

TET_LS_STATUS_CLEAR_LINE_FULL_EMPTY		equ @LOW( ~( bTET_LS_LineEmpty | bTET_LS_LineFull ) )

TET_LS_StartLine				equ     (COREWorkBuffer +  10)
TET_LS_EndLine					equ     (COREWorkBuffer +  11)
TET_LS_LineBitMsk				equ     (COREWorkBuffer +  12)

;;0x64
TET_LS_FlashCount				equ     (COREWorkBuffer +  13)
TET_LS_NumLinesToDrop			equ     (COREWorkBuffer +  14)

;;0x66
TET_LS_Line1X					equ     (COREWorkBuffer +  15)
TET_LS_Line2X					equ     (COREWorkBuffer +  16)
TET_LS_Line3X					equ     (COREWorkBuffer +  17)
TET_LS_Line4X					equ     (COREWorkBuffer +  18)

;;0x6A
TET_LS_PixelCount				equ     (COREWorkBuffer +  19)
TET_LS_Count					equ     (COREWorkBuffer +  20)

TET_Score1						equ     (COREWorkBuffer + 21)
TET_Score2						equ     (COREWorkBuffer + 22)
TET_HiScore1					equ     (COREWorkBuffer + 23)
TET_HiScore2					equ     (COREWorkBuffer + 24)
TET_GameOverMsgFlash			equ     (COREWorkBuffer + 25)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; DEFINES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; DEFINES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; DEFINES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; DEFINES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; DEFINES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; DEFINES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TET_FALL_SPEED_1						equ			7
TET_FALL_SPEED_2						equ			1
TET_FALL_SPEED_3						equ			5
TET_FALL_SPEED_AUTO_DROP				equ			1

TET_UPDATE_COUNT						equ			2

TET_INITIAL_DRAW_BLOCK_COUNT_X          equ        4
TET_INITIAL_DRAW_BLOCK_COUNT_Y          equ        4

TET_INITIAL_BLOCK_START_X               equ        16
TET_INITIAL_BLOCK_START_Y               equ        5

TET_NEXT_BLOCK_START_X               equ        4
TET_NEXT_BLOCK_START_Y               equ        1

TET_LIMIT_BLOCK_X					equ        43
TET_LIMIT_BLOCK_RIGHT_Y				equ        1
TET_LIMIT_BLOCK_LEFT_Y				equ        12
TET_LIMIT_CHECK_MID_POINT			equ        5

TET_SIDELINE_START_X				equ        42
TET_SIDELINE_END_X					equ        22
TET_TOP_SCREEN_X					equ        21
TET_SIDELINE_START_Y				equ        1
TET_NUMBER_OF_GAME_LINES			equ        20
TET_LS_START_Y						equ        2

TET_SIDELINE_LENGTH_X				equ       20
TET_LINE_FULL_COUNT					equ       10
TET_LINE_FLASH_TIMES				equ       8

;Initial block shapes
TET_SHAPE_RIGHT_SNAKE_TYPE	equ  0
TET_SHAPE_RIGHT_SNAKE					equ       0001001100100000b

TET_SHAPE_LEFT_SNAKE_TYPE	equ  1
TET_SHAPE_LEFT_SNAKE					equ       0010001100010000b

TET_SHAPE_LEFT_L_TYPE		equ  2
TET_SHAPE_LEFT_L						equ       0011000100010000b

TET_SHAPE_RIGHT_L_TYPE		equ  3
TET_SHAPE_RIGHT_L						equ       0001000100110000b

TET_SHAPE_T_TYPE			equ  4
TET_SHAPE_T								equ       0010001100100000b

TET_SHAPE_SQUARE_TYPE		equ  5
TET_SHAPE_SQUARE						equ       0000011001100000b

TET_SHAPE_LINE_TYPE			equ  6
TET_SHAPE_LINE							equ       0010001000100010b

TET_BLOCK_NUM_MAX			equ	 7




TET_MSG_REGION_START_X		equ			24		
TET_MSG_REGION_START_Y		equ			1
TET_MSG_REGION_END_X		equ			33 	
TET_MSG_REGION_END_Y		equ			11

TET_MSG_START_X				equ			26		
TET_MSG_END_X				equ			30	

TET_MSG_FLASH_ON_OFF_TIME	equ			22
TET_MSG_FLASH_ON_TIME		equ			11
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; TODO: Put here your variables to be use on background operation


;;DEBUG - BREAKPOINT VALUE

DEBUG_BREAKPOINT_VALUE    equ		0DEADH



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
