// Copyright (c) 2018 CoinFiles
// Distributed under the MIT software license,
// see http://www.opensource.org/licenses/mit-license.php.

#ifndef MACTOOLBAR_H
#define MACTOOLBAR_H

#include <QtCore/QObject>

// Forward declares
class QAction;
class QWindow;
class MacNativeToolbarPrivate;
template <typename T> class QList;


/** MacToolBar is a wrapper class for the native NSToolbar.
 *  Main purpose is to support QAction and provide a typical
 *  mac look and feel.
 */
class MacNativeToolBar : public QObject
{
    Q_OBJECT
public:
    explicit MacNativeToolBar(QObject *parent = nullptr);
    ~MacNativeToolBar();

    void showInWindow(QWindow *window);

    void addAction(QAction *action);
    void addActions(QList<QAction *> actions);
    void removeAction(QAction *action);
    void removeAllActions();

    void addFlexibleSpace();
    void addFixedSpace();

    QList<QAction *> actions();

private:
    MacNativeToolBar();
    MacNativeToolbarPrivate *privateMember;
};

Q_DECLARE_METATYPE(MacNativeToolBar*)

#endif // MACTOOLBAR_H
