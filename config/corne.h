#include <behaviors.dtsi>
#include <dt-bindings/zmk/keys.h>
#include <dt-bindings/zmk/bt.h>
#include <dt-bindings/zmk/outputs.h>
#include <dt-bindings/zmk/ext_power.h>

#define XXX &none
#define ___ &trans

#define TAPPING_TERM 200

#define BASE 0
#define NAV 1
#define NUM 2
#define SYM 3
#define FUN 4
#define BUTTON 5
#define MEDIA 6
#define MOUSE 7

#define STRINGIFY(x) #x

#define _EP_TOG &ext_power EP_TOG

#if defined (CLIPBOARD_FUN)
    #define _RDO &kp K_AGAIN
    #define _PST &kp K_PASTE
    #define _CPY &kp K_COPY
    #define _CUT &kp K_CUT
    #define _UND &kp K_UNDO
#else
    #define _RDO &kp K_AGAIN
    #define _PST &kp LS(INS)
    #define _CPY &kp LC(INS)
    #define _CUT &kp LS(DEL)
    #define _UND &kp K_UNDO
#endif
