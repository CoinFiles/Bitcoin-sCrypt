// Copyright (c) 2018 CoinFiles
// Distributed under the MIT software license,
// see http://www.opensource.org/licenses/mit-license.php.

#ifndef MACNATIVETOOLBARDELEGATE_P_H
#define MACNATIVETOOLBARDELEGATE_P_H

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

// Forward declares
class MacNativeToolbarPrivate;

@interface MacNativeToolbarDelegate : NSObject <NSToolbarDelegate>

- (instancetype) initWithRef:(MacNativeToolbarPrivate *)toolbarRef;
- (NSToolbarItem *) toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *) itemIdent willBeInsertedIntoToolbar:(BOOL) willBeInserted;
- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar;
- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar;
- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar;
- (IBAction)itemClicked:(id)sender;

@end


#endif // MACNATIVETOOLBARDELEGATE_P_H
