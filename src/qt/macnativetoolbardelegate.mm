// Copyright (c) 2018 CoinFiles
// Distributed under the MIT software license,
// see http://www.opensource.org/licenses/mit-license.php.

#include "macnativetoolbardelegate_p.h"

#include <QAction>
#include <QList>
#include <QString>
#include <QImage>
#include <QDebug>
#include "macnativetoolbarprivate_p.h"

@implementation MacNativeToolbarDelegate
{
    MacNativeToolbarPrivate *_toolbarRef;
    QList<QAction *> _actions;
}

- (instancetype) initWithRef:(MacNativeToolbarPrivate *)toolbarRef
{
    self = [super init];
    if (self){
        _toolbarRef = toolbarRef;
        _actions = QList<QAction *>();
    }
    return self;
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar
{
    Q_UNUSED(toolbar);

    // determines the initial order of the toolbar items
    return _toolbarRef->getDefaultIdentifiers();
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar
{
    Q_UNUSED(toolbar);
    return _toolbarRef->getAllowedIdentifiers();
}

- (NSArray *)toolbarSelectableItemIdentifiers: (NSToolbar *)toolbar
{
    Q_UNUSED(toolbar);
    return _toolbarRef->getAllowedIdentifiers();
}

- (IBAction)itemClicked:(NSToolbarItem *)sender
{
    QString identifier = QString::fromNSString([sender itemIdentifier]);
    qDebug() << identifier;

    QAction *action = _toolbarRef->getActionForId(identifier);
    if (action != nullptr){
        Q_EMIT action->triggered();
    }
}

- (NSToolbarItem *) toolbar: (NSToolbar *)toolbar itemForItemIdentifier: (NSString *) itemIdentifier willBeInsertedIntoToolbar:(BOOL) willBeInserted
{
    Q_UNUSED(toolbar);
    Q_UNUSED(willBeInserted);

    QString identifier = QString::fromNSString(itemIdentifier);
    QAction *action = _toolbarRef->getActionForId(identifier);
    if (action == nullptr){
        return nil;
    }

    NSToolbarItem *toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier] autorelease];
    [toolbarItem setTarget:self];
    [toolbarItem setAction:@selector(itemClicked:)];
    [toolbarItem setEnabled:action->isEnabled()];

    NSString *text = [action->text().toNSString() stringByReplacingOccurrencesOfString:@"&" withString:@""];
    [toolbarItem setLabel:text];
    [toolbarItem setPaletteLabel:text];
    [toolbarItem setToolTip:action->toolTip().toNSString()];

    [toolbarItem setMinSize:CGSizeMake(20, 32)];
    [toolbarItem setMaxSize:CGSizeMake(64, 64)];

    QIcon qtIcon = action->icon();
    NSImage *image = [self convertNSImageFromQIcon:&qtIcon];
    if (image)
        [toolbarItem setImage: image];

    return toolbarItem;
}

- (BOOL)validateToolbarItem:(NSToolbarItem *)item
{
    QString identifier = QString::fromNSString([item itemIdentifier]);
    QAction *action = _toolbarRef->getActionForId(identifier);
    if (action == nullptr){
        return NO;
    }
    return action->isEnabled();
}

- (NSImage *)convertNSImageFromQIcon:(QIcon *)icon
{
    if (icon->isNull()) return nullptr;
    QPixmap pixmap = icon->pixmap(64, 64);
    if (pixmap.isNull()) return nullptr;

    QImage qImage = pixmap.toImage();
    if (qImage.isNull()) return nullptr;

    CGImageRef imageRef = qImage.toCGImage();
    NSImage *image = [[NSImage alloc] initWithCGImage:imageRef size:NSZeroSize];

    // cleanup
    CGImageRelease(imageRef);

    return image;
}

@end
