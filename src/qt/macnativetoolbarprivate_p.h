// Copyright (c) 2018 CoinFiles
// Distributed under the MIT software license,
// see http://www.opensource.org/licenses/mit-license.php.

#ifndef MACNATIVETOOLBARPRIVATE_P_H
#define MACNATIVETOOLBARPRIVATE_P_H

#include <QtCore/QObject>

// Forward declares
Q_FORWARD_DECLARE_OBJC_CLASS(NSToolbar);
Q_FORWARD_DECLARE_OBJC_CLASS(NSWindow);
Q_FORWARD_DECLARE_OBJC_CLASS(MacNativeToolbarDelegate);
Q_FORWARD_DECLARE_OBJC_CLASS(NSArray);
class QAction;
class QWindow;
template <typename T> class QList;

// internal
typedef struct
{
    QAction *action;
    QString uniqueId;
} Item;

class MacNativeToolbarPrivate : public QObject
{
    Q_OBJECT
public:
    explicit MacNativeToolbarPrivate(QObject *parent = nullptr);
    ~MacNativeToolbarPrivate();

    void showInWindow(QWindow *window);

    void addAction(QAction *action);
    void addActions(QList<QAction *> actions);
    void removeAction(QAction *action);
    void removeAllActions();

    // build in types:
    void addFlexibleSpace();
    void addFixedSpace();

    QList<QAction *> items();

    NSArray *getDefaultIdentifiers();
    NSArray *getAllowedIdentifiers();
    QAction *getActionForId(QString uniqueId);
    void handleDidBecomeMainNotification();

private:
    MacNativeToolbarPrivate();
    QList<Item> actions;
    NSToolbar *nativeToolbar;
    NSWindow *nativeWindow;
    MacNativeToolbarDelegate *toolbarDelegate;

private:
    QString actionIdentifier(QAction *action);
};

Q_DECLARE_METATYPE(MacNativeToolbarPrivate*)

#endif // MACNATIVETOOLBARPRIVATE_P_H
