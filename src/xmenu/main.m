@import Cocoa;

#include <stdbool.h>
#include <stdio.h>
#include "draw.h"
#include "view.h"
#include "items.h"
#include "util.h"

char *toReturn = "";

bool topbar = true;
bool caseSensitive;
float window_height = 24;
const char *promptCStr = "$";
const char *font;
const char *normbgcolor = "#1b202a";
const char *normfgcolor = "#D3D0C8";
const char *selbgcolor = "#004AC1";
const char *selfgcolor = "#F7F7F7";

int main(int argc, const char **argv) {
  parseargs(argc, argv);

  DrawCtx drawCtx;
  drawCtx.nbg = mkColor(normbgcolor);
  drawCtx.nfg = mkColor(normfgcolor);
  drawCtx.sbg = mkColor(selbgcolor);
  drawCtx.sfg = mkColor(selfgcolor);
  drawCtx.x = 0;
  drawCtx.font_siz = 12.0;  // TODO: Fix shadows

  CFStringRef promptStr = CFStringCreateWithCString(NULL, promptCStr, kCFStringEncodingUTF8);
  //CFStringRef fontStr = CFStringCreateWithCString(NULL, "Operator Mono", kCFStringEncodingUTF8);
  CFStringRef fontStr = CFStringCreateWithCString(NULL, "Fira Mono for Powerline", kCFStringEncodingUTF8);
  CTFontDescriptorRef fontDesc = CTFontDescriptorCreateWithNameAndSize(fontStr, drawCtx.font_siz);
  CTFontRef font = CTFontCreateWithFontDescriptor(fontDesc, 0.0, NULL);
  CFRelease(fontStr);
  drawCtx.font = font;

  initDraw(&drawCtx);

  ItemList itemList = ReadStdin();
  if (!itemList.len) {
    return 1;
  }
  itemList.item[0].sel = true;

  [NSAutoreleasePool new];
  [NSApplication sharedApplication];
  [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];

  NSRect screenFrame = [[NSScreen mainScreen] visibleFrame];
  CGFloat y = screenFrame.origin.y;
  if (topbar) {
    y += screenFrame.size.height - window_height;
  }

  NSRect windowRect = NSMakeRect(screenFrame.origin.x, y, screenFrame.size.width, window_height);
  BorderlessWindow *window = [[[BorderlessWindow alloc] initWithContentRect:windowRect
                                                                  styleMask:NSBorderlessWindowMask
                                                                    backing:NSBackingStoreBuffered
                                                                      defer:NO] autorelease];
  [window makeKeyAndOrderFront:nil];
  [NSApp activateIgnoringOtherApps:YES];

  XmenuMainView *view = [[XmenuMainView alloc] initWithFrame:windowRect
                                                       items:itemList
                                                     drawCtx:&drawCtx
                                                   promptStr:promptStr];
  [view setWantsLayer:YES];
  [window setContentView:view];
  [window makeFirstResponder:view];
  [window setupWindowForEvents];
  [NSApp run];
  [view release];
  if (toReturn != NULL) {
    puts(toReturn);
  }

  return 0;
}
