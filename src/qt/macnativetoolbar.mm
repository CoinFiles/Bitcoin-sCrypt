// Copyright (c) 2018 CoinFiles
// Distributed under the MIT software license,
// see http://www.opensource.org/licenses/mit-license.php.

#include "macnativetoolbar.h"
#include <QAction>
#include <QList>
#include <QtGui>
#include <QString>

#include "macnativetoolbarprivate_p.h"
#include "macnativetoolbardelegate_p.h"


MacNativeToolBar::MacNativeToolBar(QObject *parent):
    QObject(parent)
{
    this->privateMember = new MacNativeToolbarPrivate(parent);
}

MacNativeToolBar::~MacNativeToolBar()
{
    // clean up
    delete this->privateMember;
}

void MacNativeToolBar::showInWindow(QWindow *window)
{
    this->privateMember->showInWindow(window);
}

void MacNativeToolBar::addAction(QAction *action)
{
    this->privateMember->addAction(action);
}

void MacNativeToolBar::addActions(QList<QAction *> actions)
{
    this->privateMember->addActions(actions);
}

void MacNativeToolBar::removeAction(QAction *action)
{
    this->privateMember->removeAction(action);
}

void MacNativeToolBar::removeAllActions()
{
    this->privateMember->removeAllActions();
}

void MacNativeToolBar::addFlexibleSpace()
{
    this->privateMember->addFlexibleSpace();
}

void MacNativeToolBar::addFixedSpace()
{
    this->privateMember->addFixedSpace();
}

QList<QAction *> MacNativeToolBar::actions()
{
    return this->privateMember->items();
}
