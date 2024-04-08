#import "rat.h"

// Reverse Scroll Direction
// Look this code: https://github.com/noah-nuebling/mac-mouse-fix/blob/master/App/UI/Main/Base.lproj/Main.storyboard#L1073
//
// Config file: https://github.com/noah-nuebling/mac-mouse-fix/blob/master/Helper/Core/Config/ScrollConfig.swift#L249-L254
// Code:
//     return c("reverseDirection") as! Bool ? kMFScrollInversionInverted : kMFScrollInversionNonInverted
// Flow Scroll:
//      1. listen event eventTapCallback - https://github.com/noah-nuebling/mac-mouse-fix/blob/master/Helper/Core/Scroll/Scroll.m#L191
//      2. dispatch queue heavyProcessing - https://github.com/noah-nuebling/mac-mouse-fix/blob/master/Helper/Core/Scroll/Scroll.m#L252
//      3. sendScroll
//      4. sendOutputEvents

CGEventRef eventCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon) {
    NSUInteger ButtonNumber = CGEventGetIntegerValueField(event, kCGMouseEventButtonNumber);
    // NSLog(@"Button Number: %ld", ButtonNumber);

    switch (ButtonNumber) {
        case 0:
            {
                // keep touchpad
                // Events: https://developer.apple.com/documentation/coregraphics/cgeventfield/scrollwheeleventmomentumphase
                int64_t ScrollPhase = CGEventGetIntegerValueField(event, kCGScrollWheelEventScrollPhase);
                int64_t MomentumPhase = CGEventGetIntegerValueField(event, kCGScrollWheelEventMomentumPhase);
                if (ScrollPhase > 0 || MomentumPhase > 0) {
                    return event;
                }

                int64_t DeltaAxis1 = CGEventGetIntegerValueField(event, kCGScrollWheelEventDeltaAxis1);
                int64_t PointDeltaAxis1 = CGEventGetIntegerValueField(event, kCGScrollWheelEventPointDeltaAxis1);
                int64_t FixedPtDeltaAxis1 = CGEventGetIntegerValueField(event, kCGScrollWheelEventFixedPtDeltaAxis1);

                CGEventSetIntegerValueField(event, kCGScrollWheelEventDeltaAxis1, -DeltaAxis1);
                CGEventSetIntegerValueField(event, kCGScrollWheelEventPointDeltaAxis1, -PointDeltaAxis1);
                CGEventSetIntegerValueField(event, kCGScrollWheelEventFixedPtDeltaAxis1, -FixedPtDeltaAxis1);

                // NSLog(@"ScrollPhase: %lld | MomentumPhase: %lld ", ScrollPhase, MomentumPhase);

                return event;
            }
        case 3:
            {
                // Sample code: https://github.com/noah-nuebling/mac-mouse-fix/blob/master/Helper/Core/Actions/Actions.m#L39
                // https://github.com/noah-nuebling/mac-mouse-fix/blob/master/App/UI/Main/Tabs/ButtonTab/RemapTable/RemapTableTranslator.m#L199
                postSymbolicHotkey(79); // Move Left Space
                NSLog(@"Button: %ld - Move Left", ButtonNumber);

                return nil;
            }
        case 4:
            {
                postSymbolicHotkey(81); // Move Right Space
                NSLog(@"Button: %ld - Move Right", ButtonNumber);

                return nil;
            }
        default:
            // https://github.com/noah-nuebling/mac-mouse-fix/blob/master/Helper/Core/Buttons/ButtonInputReceiver.m#L178-L184
            return event;
    }
}

static void postSymbolicHotkey(int shk) {
    unichar keyEquivalent;
    CGKeyCode keyCode;
    CGSModifierFlags modifierFlags;
    CGSGetSymbolicHotKeyValue(shk, &keyEquivalent, &keyCode, &modifierFlags);

    BOOL hotkeyIsEnabled = CGSIsSymbolicHotKeyEnabled(shk);

    if (!hotkeyIsEnabled) {
        CGSSetSymbolicHotKeyEnabled(shk, true);
    }

    postKeyboardEventsForSymbolicHotkey(keyCode, modifierFlags);
}

static void postKeyboardEventsForSymbolicHotkey(CGKeyCode keyCode, CGSModifierFlags modifierFlags) {
    CGEventTapLocation tapLoc = kCGSessionEventTap;

    // Create key events
    CGEventRef keyDown = CGEventCreateKeyboardEvent(NULL, keyCode, true);
    CGEventRef keyUp = CGEventCreateKeyboardEvent(NULL, keyCode, false);
    CGEventSetFlags(keyDown, (CGEventFlags)modifierFlags);
    CGEventFlags originalModifierFlags = getModifierFlags();
    CGEventSetFlags(keyUp, originalModifierFlags); // Restore original keyboard modifier flags state on key up. This seems to fix `[Modifiers getCurrentModifiers]`

    // Send key events
    CGEventPost(tapLoc, keyDown);
    CGEventPost(tapLoc, keyUp);

    CFRelease(keyDown);
    CFRelease(keyUp);
}

CGEventFlags getModifierFlags(void) {
    CGEventRef flagEvent = CGEventCreate(NULL);
    CGEventFlags flags = CGEventGetFlags(flagEvent);
    CFRelease(flagEvent);
    return flags;
}

void setupEventTap() {
    CGEventMask eventMask = CGEventMaskBit(kCGEventOtherMouseUp) | CGEventMaskBit(kCGEventScrollWheel);
    CFMachPortRef eventTap = CGEventTapCreate(kCGHIDEventTap, kCGHeadInsertEventTap, kCGEventTapOptionDefault, eventMask, eventCallback, NULL);

    if (!eventTap) {
        NSLog(@"No Mouse");
        return;
    }

    CFRunLoopSourceRef runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0);

    CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, kCFRunLoopCommonModes);

    CFRunLoopRun();

    CFRelease(eventTap);
    CFRelease(runLoopSource);
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        setupEventTap();
    }
    return 0;
}
