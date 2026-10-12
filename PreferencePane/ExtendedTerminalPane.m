#import <Cocoa/Cocoa.h>
#import <PreferencePanes/PreferencePanes.h>

static NSString * const Domain = @"dev.local.TerminalCopyOnSelect";
static NSString * const Helper = @"/Library/Application Support/Extended Terminal/Extended Terminal.app";

@interface ExtendedTerminalPane : NSPreferencePane
@property NSTextField *statusLabel;
@property NSButton *copyingButton;
@property NSButton *keysButton;
@property NSButton *loginButton;
@property NSTimer *timer;
@end

@implementation ExtendedTerminalPane
- (NSTextField *)label:(NSString *)text frame:(NSRect)frame font:(NSFont *)font {
    NSTextField *label = [NSTextField labelWithString:text];
    label.frame = frame;
    if (font) label.font = font;
    [self.mainView addSubview:label];
    return label;
}
- (NSButton *)button:(NSString *)title action:(SEL)action frame:(NSRect)frame {
    NSButton *button = [NSButton buttonWithTitle:title target:self action:action];
    button.frame = frame;
    [self.mainView addSubview:button];
    return button;
}
- (NSButton *)check:(NSString *)title tag:(NSInteger)tag y:(CGFloat)y {
    NSButton *button = [NSButton checkboxWithTitle:title target:self action:@selector(changed:)];
    button.tag = tag;
    button.frame = NSMakeRect(24, y, 560, 26);
    [self.mainView addSubview:button];
    return button;
}
- (NSView *)loadMainView {
    self.mainView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 620, 390)];
    [self label:@"Extended Terminal" frame:NSMakeRect(24, 339, 570, 30) font:[NSFont boldSystemFontOfSize:23]];
    self.statusLabel = [self label:@"Checking service…" frame:NSMakeRect(24, 305, 570, 24) font:nil];
    self.copyingButton = [self check:@"Copy selected text automatically" tag:0 y:266];
    self.keysButton = [self check:@"Enable Control + arrows and keyboard selection" tag:1 y:230];
    self.loginButton = [self check:@"Start automatically at login" tag:2 y:194];
    [self label:@"Ctrl + ←/→: start/end of line\nAlt + Shift + ←/→: select words\nCtrl + Shift + ←/→: select to start/end of line" frame:NSMakeRect(42, 111, 540, 74) font:[NSFont systemFontOfSize:12]];
    [self button:@"Grant Accessibility…" action:@selector(access:) frame:NSMakeRect(24, 61, 220, 32)];
    [self button:@"Apply Terminal theme" action:@selector(theme:) frame:NSMakeRect(254, 61, 220, 32)];
    [self button:@"Start service" action:@selector(start:) frame:NSMakeRect(24, 15, 160, 32)];
    [self button:@"Stop service" action:@selector(stop:) frame:NSMakeRect(198, 15, 160, 32)];
    [self refresh];
    return self.mainView;
}
- (NSString *)agentPath {
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Library/LaunchAgents/dev.local.ExtendedTerminal.plist"];
}
- (BOOL)setting:(NSString *)key {
    CFPropertyListRef value = CFPreferencesCopyAppValue((__bridge CFStringRef)key, (__bridge CFStringRef)Domain);
    if (!value) return YES;
    BOOL result = [(__bridge id)value boolValue];
    CFRelease(value);
    return result;
}
- (NSRunningApplication *)helperProcess {
    for (NSRunningApplication *app in [NSRunningApplication runningApplicationsWithBundleIdentifier:Domain]) {
        if ([app.bundleURL.path isEqualToString:Helper]) return app;
    }
    return nil;
}
- (void)refresh {
    CFPreferencesAppSynchronize((__bridge CFStringRef)Domain);
    self.copyingButton.state = [self setting:@"copyEnabled"] ? NSControlStateValueOn : NSControlStateValueOff;
    self.keysButton.state = [self setting:@"shortcutsEnabled"] ? NSControlStateValueOn : NSControlStateValueOff;
    self.loginButton.state = [[NSFileManager defaultManager] fileExistsAtPath:self.agentPath] ? NSControlStateValueOn : NSControlStateValueOff;
    NSDictionary *state = [NSDictionary dictionaryWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Application Support/Extended Terminal/service-state.plist"]];
    NSRunningApplication *running = [self helperProcess];
    if (!running) self.statusLabel.stringValue = @"Service stopped";
    else if ([state[@"pid"] intValue] != running.processIdentifier) self.statusLabel.stringValue = @"Starting service…";
    else if (![state[@"trusted"] boolValue]) self.statusLabel.stringValue = @"Accessibility permission required — grant access below";
    else if ([self setting:@"shortcutsEnabled"] && ![state[@"keyboardTap"] boolValue]) self.statusLabel.stringValue = @"Copying available; keyboard access needs a service restart";
    else self.statusLabel.stringValue = @"Running in the background — Terminal only";
}
- (void)willSelect {
    [self refresh];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refresh) userInfo:nil repeats:YES];
}
- (void)didUnselect { [self.timer invalidate]; self.timer = nil; }
- (void)send:(NSString *)action {
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"dev.local.ExtendedTerminal.command" object:nil userInfo:@{@"action":action} deliverImmediately:YES];
}
- (void)changed:(NSButton *)sender {
    if (sender.tag == 2) {
        NSError *error = nil;
        if (sender.state == NSControlStateValueOn) {
            NSString *directory = [self.agentPath stringByDeletingLastPathComponent];
            [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&error];
            NSDictionary *agent = @{@"Label":@"dev.local.ExtendedTerminal", @"ProgramArguments":@[[Helper stringByAppendingPathComponent:@"Contents/MacOS/TerminalCopyOnSelect"], @"--background"], @"RunAtLoad":@YES};
            NSData *data = [NSPropertyListSerialization dataWithPropertyList:agent format:NSPropertyListXMLFormat_v1_0 options:0 error:&error];
            if (data && !error) [data writeToFile:self.agentPath options:NSDataWritingAtomic error:&error];
        } else if ([[NSFileManager defaultManager] fileExistsAtPath:self.agentPath]) {
            [[NSFileManager defaultManager] removeItemAtPath:self.agentPath error:&error];
        }
        if (error) { NSAlert *alert = [NSAlert new]; alert.messageText = error.localizedDescription; [alert runModal]; }
    } else {
        NSString *key = sender.tag == 0 ? @"copyEnabled" : @"shortcutsEnabled";
        CFPreferencesSetAppValue((__bridge CFStringRef)key, sender.state == NSControlStateValueOn ? kCFBooleanTrue : kCFBooleanFalse, (__bridge CFStringRef)Domain);
        CFPreferencesAppSynchronize((__bridge CFStringRef)Domain);
        [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"dev.local.ExtendedTerminal.preferencesChanged" object:nil userInfo:nil deliverImmediately:YES];
    }
    [self refresh];
}
- (void)start:(id)sender {
    if ([self helperProcess]) return;
    NSWorkspaceOpenConfiguration *config = [NSWorkspaceOpenConfiguration configuration];
    config.activates = NO;
    config.arguments = @[@"--background"];
    [[NSWorkspace sharedWorkspace] openApplicationAtURL:[NSURL fileURLWithPath:Helper] configuration:config completionHandler:^(NSRunningApplication *app, NSError *error) {
        if (error) dispatch_async(dispatch_get_main_queue(), ^{ NSAlert *alert = [NSAlert new]; alert.messageText = error.localizedDescription; [alert runModal]; });
    }];
}
- (void)stop:(id)sender { [self send:@"quit"]; }
- (void)theme:(id)sender {
    [self start:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC), dispatch_get_main_queue(), ^{ [self send:@"theme"]; });
}
- (void)access:(id)sender {
    [self start:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC), dispatch_get_main_queue(), ^{ [self send:@"access"]; });
    [[NSWorkspace sharedWorkspace] selectFile:Helper inFileViewerRootedAtPath:[Helper stringByDeletingLastPathComponent]];
    NSAlert *instructions = [NSAlert new];
    instructions.messageText = @"Add the background helper to Accessibility";
    instructions.informativeText = @"macOS may not add background services to the list automatically. Unlock Accessibility, click +, press Command + Shift + G, and paste:\n\n/Library/Application Support/Extended Terminal/Extended Terminal.app\n\nChoose Open and enable its checkbox. If an old Extended Terminal entry exists, remove it first. The helper has the green gear icon.";
    [instructions addButtonWithTitle:@"Open Accessibility"];
    [instructions addButtonWithTitle:@"Cancel"];
    if ([instructions runModal] == NSAlertFirstButtonReturn) {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"]];
    }
}
@end
