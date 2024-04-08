#import <Foundation/Foundation.h>
#import <ApplicationServices/ApplicationServices.h>
#import "CGSInternal/CGSInternal.h"

// Sample https://github.com/noah-nuebling/mac-mouse-fix/blob/master/Shared/Constants.h#L255

CG_EXTERN CGError CGSGetSymbolicHotKeyValue(CGSSymbolicHotKey hotKey, unichar *outKeyEquivalent, unichar *outVirtualKeyCode, CGSModifierFlags *outModifiers);
CG_EXTERN CGError CGSSetSymbolicHotKeyValue(CGSSymbolicHotKey hotKey, unichar keyEquivalent, CGKeyCode virtualKeyCode, CGSModifierFlags modifiers);

static void postSymbolicHotkey(int shk);
static void postKeyboardEventsForSymbolicHotkey(CGKeyCode keyCode, CGSModifierFlags modifierFlags);
// BOOL getCharsForKeyCode(CGKeyCode keyCode, NSString **chars);
// BOOL shkBindingIsUsable(CGKeyCode keyCode, unichar keyEquivalent);
CGEventFlags getModifierFlags(void);

