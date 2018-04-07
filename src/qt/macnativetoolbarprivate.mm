// Copyright (c) 2018 CoinFiles
// Distributed under the MIT software license,
// see http://www.opensource.org/licenses/mit-license.php.

#include "macnativetoolbarprivate_p.h"

#include <QAction>
#include <QList>
#include <QtGui>
#include <QString>
#include <QImage>

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#include "macnativetoolbardelegate_p.h"

static void notificationHandler(CFNotificationCenterRef center,
                                void *observer,
                                CFStringRef name,
                                const void *object,
                                CFDictionaryRef userInfo) {
    Q_UNUSED(center);
    Q_UNUSED(object);
    Q_UNUSED(name);
    Q_UNUSED(userInfo);
    (static_cast<MacNativeToolbarPrivate *>(observer))->handleDidBecomeMainNotification();
}

MacNativeToolbarPrivate::MacNativeToolbarPrivate(QObject *parent):
    QObject(parent)
{
    this->actions = QList<Item>();
    this->toolbarDelegate = [[MacNativeToolbarDelegate alloc] initWithRef:this];

    // create the toolbar object
    this->nativeToolbar = [[NSToolbar alloc] initWithIdentifier:@"Bitcoin-sCrypt-Main Toolbar"];

    // set initial toolbar properties
    [this->nativeToolbar setAllowsUserCustomization:NO];
    [this->nativeToolbar setAutosavesConfiguration:YES];
    [this->nativeToolbar setDisplayMode:NSToolbarDisplayModeIconAndLabel];
    [this->nativeToolbar setShowsBaselineSeparator:NO];

    // set our controller as the toolbar delegate
    [this->nativeToolbar setDelegate:this->toolbarDelegate];

    CFNotificationCenterAddObserver
        (
            CFNotificationCenterGetLocalCenter(),
            this,
            &notificationHandler,
            (__bridge CFStringRef)NSWindowDidBecomeMainNotification,
            nullptr,
            CFNotificationSuspensionBehaviorDeliverImmediately
        );
}

MacNativeToolbarPrivate::~MacNativeToolbarPrivate()
{
    // clean up
    [this->nativeToolbar release];
    [this->toolbarDelegate release];
    CFNotificationCenterRemoveEveryObserver
        (
            CFNotificationCenterGetLocalCenter(),
            this
        );
}

void MacNativeToolbarPrivate::showInWindow(QWindow *window)
{
    if (!window) return;
    NSView *view = reinterpret_cast<NSView*>(window->winId());
    if (!view) return;
    this->nativeWindow = [view window];
    if (!this->nativeWindow) return;

    // attach the toolbar to our window
    [this->nativeWindow setToolbar: this->nativeToolbar];
    [this->nativeWindow setShowsToolbarButton:YES];
}

void MacNativeToolbarPrivate::handleDidBecomeMainNotification()
{
    // toolbar icons not enebled right if window is started behind another
    [this->nativeWindow update];
}

QString MacNativeToolbarPrivate::actionIdentifier(QAction *action)
{
    if (!action) return nullptr;

    QString ptrStr = QString("0x%1").arg((quintptr)action,
                                         QT_POINTER_SIZE * 2,
                                         16,
                                         QChar('0'));
    return ptrStr;
}

void MacNativeToolbarPrivate::addAction(QAction *action)
{
    if (!action) return;

    QString identifier = actionIdentifier(action);
    Item item;
    item.action = action;
    item.uniqueId = identifier;
    this->actions.append(item);
}

void MacNativeToolbarPrivate::addActions(QList<QAction *> actions)
{
    for (int idx=0; idx<actions.size();++idx){
        this->addAction(actions.value(idx));
    }
}

void MacNativeToolbarPrivate::removeAction(QAction *action)
{
    QString identifier = actionIdentifier(action);
    for (int idx=0; idx<this->actions.size();++idx){
        if (0 == QString::compare(this->actions.value(idx).uniqueId, identifier, Qt::CaseInsensitive)){
            [this->nativeToolbar removeItemAtIndex:idx];
            this->actions.removeAt(idx);
            return;
        }
    }
}

void MacNativeToolbarPrivate::removeAllActions()
{
    int numOfItems = [[this->nativeToolbar items] count];
    for (int idx=0; idx < numOfItems; ++idx){
        [this->nativeToolbar removeItemAtIndex:0];
    }
    this->actions.clear();
}

void MacNativeToolbarPrivate::addFlexibleSpace()
{
    Item item;
    item.action = nullptr;
    item.uniqueId = QString::fromNSString(NSToolbarFlexibleSpaceItemIdentifier);
    this->actions.append(item);
}

void MacNativeToolbarPrivate::addFixedSpace()
{
    Item item;
    item.action = nullptr;
    item.uniqueId = QString::fromNSString(NSToolbarSpaceItemIdentifier);
    this->actions.append(item);
}

QList<QAction *> MacNativeToolbarPrivate::items()
{
    QList<QAction *> actionList = QList<QAction *>();
    for (int idx=0; idx<this->actions.size();++idx){
        if (this->actions.value(idx).action != nullptr)
            actionList.append(this->actions.value(idx).action);
    }
    return actionList;
}

NSArray *MacNativeToolbarPrivate::getDefaultIdentifiers()
{
    // Returns the ordered list of tool identifiers
    NSMutableArray *defaultIdentifiers = [[NSMutableArray alloc] init];
    for (int idx=0; idx<this->actions.size();++idx){
        [defaultIdentifiers addObject:this->actions.value(idx).uniqueId.toNSString()];
    }
    return defaultIdentifiers;
}

NSArray *MacNativeToolbarPrivate::getAllowedIdentifiers()
{
    // Unique list of tool item identifiers
    NSMutableSet *allowedIdentifiers = [[NSMutableSet alloc]init];

    for (int idx=0; idx<this->actions.size();++idx){
        [allowedIdentifiers addObject:this->actions.value(idx).uniqueId.toNSString()];
    }

    // Valid System build in toolbar items
    [allowedIdentifiers addObject:NSToolbarFlexibleSpaceItemIdentifier];
    [allowedIdentifiers addObject:NSToolbarSpaceItemIdentifier];
    [allowedIdentifiers addObject:NSToolbarShowFontsItemIdentifier];
    [allowedIdentifiers addObject:NSToolbarShowColorsItemIdentifier];
    [allowedIdentifiers addObject:NSToolbarPrintItemIdentifier];

    return [allowedIdentifiers allObjects];
}

QAction *MacNativeToolbarPrivate::getActionForId(QString uniqueId)
{
    for (int idx=0; idx<this->actions.size();++idx){
        if (0 == QString::compare(this->actions.value(idx).uniqueId, uniqueId, Qt::CaseInsensitive)){
            return this->actions.value(idx).action;
        }
    }
    return nullptr;
}
