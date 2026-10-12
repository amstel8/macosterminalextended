#import <Cocoa/Cocoa.h>
#import <PreferencePanes/PreferencePanes.h>
int main(int argc, const char *argv[]) {
    @autoreleasepool {
        NSBundle *bundle = [NSBundle bundleWithPath:[NSString stringWithUTF8String:argv[1]]];
        NSError *error = nil;
        if (![bundle loadAndReturnError:&error]) { NSLog(@"%@", error); return 1; }
        Class principal = bundle.principalClass;
        if (![principal isSubclassOfClass:[NSPreferencePane class]]) return 2;
        NSPreferencePane *pane = [[principal alloc] initWithBundle:bundle];
        NSView *view = [pane loadMainView];
        if (!view || view.subviews.count < 10) return 3;
        printf("Preference pane: principal class loaded and settings view created\n");
        return 0;
    }
}
