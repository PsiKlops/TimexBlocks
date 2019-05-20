;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; File Name    : tetInStt.asm
; Purpose      : Tetris Application Default State Manager
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;DO NOT MODIFY THE FOLLOWING SUBROUTINE DEFINITION;;;;;;;;;;;;;;;;;

                IF @DEF('SUBROUTINE')
                    UNDEF SUBROUTINE
                ENDIF
                DEFINE  SUBROUTINE      "'tetInStt'"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Module Name : tetDefaultStateManager
; Description : Does any of the initialisation that was previously done in default 'Def'
; Assumptions : Display is cleared on first time entry into the state.
; Input(s)    : CORECurrentEvent  - system event to be processed
;               COREEventArgument - event extra information
; Output(s)   : None
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                GLOBAL  tetDefaultStateManager

tetDefaultStateManager:

                ; Set IYReg the address of the Tetris ASD.
                ld      IY, [CORECurrentASDAddress]

                ld      A, [CORECurrentEvent]
				
                ; Check if state entry event.
                cp      A, #TET_STATEENTRY
                jr      Z, tetDefaultStateStateEntryEvent              
                

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

                ;This is the default display, replace it with your own
                ;car      tetwaDefaultDisplay
                
                ;clear block parse states
                ;ld      A, #0
                ;ld      [TETDisplayStatus], A

                ;TODO: Add your own code initialization here
                ;ld      A, #@LOW(TET_SHAPE_SQUARE)
                ;ld      [TET_Current_Shape_7_0], A
                ;ld      A, #@HIGH(TET_SHAPE_SQUARE)         
                ;ld      [TET_Current_Shape_15_8], A
                
                ;;Will draw the 'Current' shape at an address pre-defined in function (for now)
                ;car tetDrawBlock - set IY
                
                ;;DRAW THE NEXT BLOCK
                ld      HL, #TET_GameStatus
                or     [HL], #bTET_GS_DrawAtNextPos

				ld		IY,#TET_NextShape_7_0
                car		tetDrawBlock   ;; Draw the Next block at to of screen
                
                ld      HL, #TET_GameStatus
                and     [HL], #@LOW(~bTET_GS_DrawAtNextPos)

				car tetDrawSideLineNoClear
				car tetDefInitScore
				
				; start our background timing generator
                ld      HL, [CORECurrentASDAddress]
                ld      A, [HL]
                KSTP_ENABLE_DISP_UPD_EVENT
                
                ld      B, #TETDEFAULTSTATE
                CORE_REQ_STATE_CHANGE_NO_CLEAR_DISPLAY
                ret


				

