;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; File Name     : tetBckHd.asm
; Purpose       : Handles the following application specific functions:
;                   - application initialization
;                   - resource refresh
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;DO NOT MODIFY THE FOLLOWING SUBROUTINE DEFINITION;;;;;;;;;;;;;;;;;

                IF @DEF('SUBROUTINE')
                    UNDEF SUBROUTINE
                ENDIF
                DEFINE  SUBROUTINE      "'tetBckHd'"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Module Name : tetBackgroundHandler
; Description : Handles application initialization and refresh resource handlers.
; Assumptions : COREInitializationASDAddress is already set by kernel.
;               COREInitializationADDAddress is already set by kernel.
; Input(s)    : None
; Output(s)   : None
;               ( Destroyed: All registers )
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                GLOBAL  tetBackgroundHandler

tetBackgroundHandler:

                ; Load the event to be process to AReg.
                ld      A, [COREBackgroundEvent]

                ; Check if INIT event.
                cp      A, #COREEVENT_INIT
                jr      NZ, tetBackgroundProcessExit
                
                ; Check if INIT event.
                cp      A, #COREEVENT_TASKEXIT
                jr      Z, tetBackgroundTaskExitEvent

tetBackgroundInitEvent:

                ;TODO: Initialize your variableS here

;;;;;;;;;;;;;;;;;< EXAMPLE >;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;               ld      A, #0
;               ld      IY, [COREInitializationASDAddress]
;               ld      [IY + AABMYDATA], A
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
tetBackgroundProcessExit:

                ret
                
tetBackgroundTaskExitEvent:

                LCD_SET_NORMAL_CONTRAST

                ; start our stopwatch resource
                ld      HL, [CORECurrentASDAddress]
                ld      A, [HL]
                KSTP_STOP_RESOURCE
                
                ret