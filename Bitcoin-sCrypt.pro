#qmake parses this file min 3 times
TEMPLATE = app
TARGET =
VERSION = 1.6.0
INCLUDEPATH += src src/json src/qt
QT += core gui network
greaterThan(QT_MAJOR_VERSION, 4): QT += widgets concurrent
DEFINES += QT_GUI BOOST_THREAD_USE_LIB BOOST_SPIRIT_THREADSAFE BOOST_THREAD_PROVIDES_GENERIC_SHARED_MUTEX_ON_WIN __NO_SYSTEM_INCLUDES UNICODE
CONFIG += no_include_pwd thread c++11 exceptions 

#create Both makefiles and then use "make release" or "make debug"
CONFIG += debug_and_release

CONFIG(debug, debug|release) {
   QMAKE_CXXFLAGS += -DDEBUG -DDEBUG_LOCKORDER

    # debug flag for gdb:
    # macx: clang_64/mkspecs/common/gcc-base.conf defaults
    windows: {	
        #hard overwrite of defaults
        QMAKE_CXXFLAGS_DEBUG = -ggdb -O0
    	QMAKE_CFLAGS_DEBUG = -ggdb -O0	
    	QMAKE_LFLAGS_DEBUG = -ggdb -O0
    } else {
    	QMAKE_CXXFLAGS_DEBUG += -O0
    	QMAKE_CFLAGS_DEBUG += -O0
        QMAKE_LFLAGS_DEBUG += -g -O0

	macx:QMAKE_CXXFLAGS += -arch x86_64
	macx:QMAKE_CFLAGS += -arch x86_64
 	macx:QMAKE_LFLAGS += -arch x86_64
    }
} else {
   # release
   !windows:!macx {
        # Linux: static link
        LIBS += -Wl,-Bstatic
    }
}


# UNCOMMENT THIS SECTION TO BUILD ON WINDOWS
# Change paths if needed, these use the Bitcoin-sCrypt/deps.git repository locations

#windows:LIBS += -lshlwapi
#LIBS += $$join(BOOST_LIB_PATH,,-L,) $$join(BDB_LIB_PATH,,-L,) $$join(OPENSSL_LIB_PATH,,-L,) $$join(QRENCODE_LIB_PATH,,-L,)
#LIBS += -lssl -lcrypto -ldb_cxx$$BDB_LIB_SUFFIX
#windows:LIBS += -lws2_32 -lole32 -loleaut32 -luuid -lgdi32
#LIBS += -lboost_system-mgw46-mt-sd-1_53 -lboost_filesystem-mgw46-mt-sd-1_53 -lboost_program_options-mgw46-mt-sd-1_53 -lboost_thread-mgw46-mt-sd-1_53
#BOOST_LIB_SUFFIX=-mgw46-mt-sd-1_53
#BOOST_INCLUDE_PATH=C:/deps/boost_1_49_0
#BOOST_LIB_PATH=C:/deps/boost_1_49_0/stage/lib
#BDB_INCLUDE_PATH=c:/deps/db-4.8.30.NC/build_unix
#BDB_LIB_PATH=c:/deps/db-4.8.30.NC/build_unix
#OPENSSL_INCLUDE_PATH=c:/deps/openssl-1.0.1g/include
#OPENSSL_LIB_PATH=c:/deps/openssl-1.0.1g

BOOST_INCLUDE_PATH=/usr/local/opt/boost/include
BOOST_LIB_PATH=/usr/local/opt/boost/lib
BDB_INCLUDE_PATH=/usr/local/opt/berkeley-db@4/include
BDB_LIB_PATH=/usr/local/opt/berkeley-db@4/lib
OPENSSL_INCLUDE_PATH=/usr/local/opt/openssl/include
OPENSSL_LIB_PATH=/usr/local/opt/openssl/lib
MINIUPNPC_INCLUDE_PATH=/usr/local/opt/miniupnpc/include
MINIUPNPC_LIB_PATH=/usr/local/opt/miniupnpc/lib
QRENCODE_INCLUDE_PATH=/usr/local/opt/qrencode/include
QRENCODE_LIB_PATH=/usr/local/opt/qrencode/lib


OBJECTS_DIR = build
MOC_DIR = build
UI_DIR = build

# Mac: compile for min macOS: Mountain Lion (10.8, 64-bit only)
#      From macOS 10.8, libc++ is installed by default
#
# TODO:
# to support 10.6 and 10.7 you need to add libc++ yourself
# see https://stackoverflow.com/questions/18033255/install-libc-on-mac-10-6-8
# macx:QMAKE_CXXFLAGS += -mmacosx-version-min=10.8 -arch x86_64
# macx:QMAKE_CFLAGS += -mmacosx-version-min=10.8 -arch x86_64
# macx:QMAKE_LFLAGS += -mmacosx-version-min=10.8 -arch x86_64

# override clang_64/mkspecs/qmake.conf defaults
#                  
QMAKE_MACOSX_DEPLOYMENT_TARGET = 10.8
#QMAKE_APPLE_DEVICE_ARCHS = x86_64


# qmake "USE_UPNP=-" (not supported)
contains(USE_UPNP, -) {
	message(Building without UPNP support)
} else {
	message(Building with UPNP support)
	count(USE_UPNP, 0) {
		USE_UPNP=1
	}
	DEFINES += USE_UPNP=$$USE_UPNP STATICLIB
	INCLUDEPATH += $$MINIUPNPC_INCLUDE_PATH
	LIBS += $$join(MINIUPNPC_LIB_PATH,,-L,) -lminiupnpc
}

# use: qmake "USE_QRCODE=1"
# libqrencode (http://fukuchi.org/works/qrencode/index.en.html) must be installed for support
contains(USE_QRCODE, 1) {
    message(Building with QRCode support)
    DEFINES += USE_QRCODE
    LIBS += -lqrencode
}

# use: qmake "USE_DBUS=1"
contains(USE_DBUS, 1) {
    message(Building with DBUS (Freedesktop notifications) support)
    DEFINES += USE_DBUS
    QT += dbus
}

# use: qmake "FIRST_CLASS_MESSAGING=1"
contains(FIRST_CLASS_MESSAGING, 1) {
    message(Building with first-class messaging)
    DEFINES += FIRST_CLASS_MESSAGING
}

contains(BITCOIN_NEED_QT_PLUGINS, 1) {
    DEFINES += BITCOIN_NEED_QT_PLUGINS
    QTPLUGIN += qcncodecs qjpcodecs qtwcodecs qkrcodecs qtaccessiblewidgets
}

!windows {
    # for extra security against potential buffer overflows
    QMAKE_CXXFLAGS += -fstack-protector
    QMAKE_LFLAGS += -fstack-protector
    # do not enable this on windows, as it will result in a non-working executable!
}

# regenerate src/build.h
!windows|contains(USE_BUILD_INFO, 1) {
    genbuild.depends = FORCE
    genbuild.commands = cd $$PWD; /bin/sh share/genbuild.sh $$OUT_PWD/build/build.h
    genbuild.target = $$OUT_PWD/build/build.h
    PRE_TARGETDEPS += $$OUT_PWD/build/build.h
    QMAKE_EXTRA_TARGETS += genbuild
    DEFINES += HAVE_BUILD_INFO
}

QMAKE_CXXFLAGS_WARN_ON = -fdiagnostics-show-option -Wall -Wextra -Wformat -Wformat-security -Wno-unused-parameter

# Input
DEPENDPATH += src src/json src/qt
HEADERS += src/qt/bitcoingui.h \
    src/qt/transactiontablemodel.h \
    src/qt/addresstablemodel.h \
    src/qt/optionsdialog.h \
    src/qt/sendcoinsdialog.h \
    src/qt/coincontroldialog.h \
    src/qt/coincontroltreewidget.h \
    src/qt/addressbookpage.h \
    src/qt/signverifymessagedialog.h \
    src/qt/aboutdialog.h \
    src/qt/editaddressdialog.h \
    src/qt/bitcoinaddressvalidator.h \
    src/addrman.h \
    src/base58.h \
    src/bignum.h \
    src/checkpoints.h \
    src/compat.h \
    src/sync.h \
    src/util.h \
    src/uint256.h \
    src/serialize.h \
    src/strlcpy.h \
    src/main.h \
    src/net.h \
    src/key.h \
    src/db.h \
    src/walletdb.h \
    src/script.h \
    src/init.h \
    src/irc.h \
    src/mruset.h \
    src/json/json_spirit_writer_template.h \
    src/json/json_spirit_writer.h \
    src/json/json_spirit_value.h \
    src/json/json_spirit_utils.h \
    src/json/json_spirit_stream_reader.h \
    src/json/json_spirit_reader_template.h \
    src/json/json_spirit_reader.h \
    src/json/json_spirit_error_position.h \
    src/json/json_spirit.h \
    src/qt/clientmodel.h \
    src/qt/guiutil.h \
    src/qt/transactionrecord.h \
    src/qt/guiconstants.h \
    src/qt/optionsmodel.h \
    src/qt/monitoreddatamapper.h \
    src/qt/transactiondesc.h \
    src/qt/transactiondescdialog.h \
    src/qt/bitcoinamountfield.h \
    src/wallet.h \
    src/keystore.h \
    src/qt/transactionfilterproxy.h \
    src/qt/transactionview.h \
    src/qt/walletmodel.h \
    src/bitcoinrpc.h \
    src/qt/overviewpage.h \
    src/qt/csvmodelwriter.h \
    src/crypter.h \
    src/qt/sendcoinsentry.h \
    src/qt/qvalidatedlineedit.h \
    src/qt/bitcoinunits.h \
    src/qt/qvaluecombobox.h \
    src/qt/askpassphrasedialog.h \
    src/protocol.h \
    src/qt/notificator.h \
    src/qt/qtipcserver.h \
    src/allocators.h \
    src/ui_interface.h \
    src/scrypt.h \
    src/qt/miningpage.h \
    src/version.h \
    src/qt/rpcconsole.h \
    src/qt/macnativetoolbardelegate_p.h \
    src/qt/macnativetoolbarprivate_p.h \
    src/qt/macnativetoolbar.h

SOURCES += src/qt/bitcoin.cpp src/qt/bitcoingui.cpp \
    src/qt/transactiontablemodel.cpp \
    src/qt/addresstablemodel.cpp \
    src/qt/optionsdialog.cpp \
    src/qt/sendcoinsdialog.cpp \
    src/qt/coincontroldialog.cpp \
    src/qt/coincontroltreewidget.cpp \
    src/qt/addressbookpage.cpp \
    src/qt/signverifymessagedialog.cpp \
    src/qt/aboutdialog.cpp \
    src/qt/editaddressdialog.cpp \
    src/qt/bitcoinaddressvalidator.cpp \
    src/version.cpp \
    src/sync.cpp \
    src/util.cpp \
    src/netbase.cpp \
    src/key.cpp \
    src/script.cpp \
    src/main.cpp \
    src/init.cpp \
    src/net.cpp \
    src/irc.cpp \
    src/checkpoints.cpp \
    src/addrman.cpp \
    src/db.cpp \
    src/walletdb.cpp \
    src/json/json_spirit_writer.cpp \
    src/json/json_spirit_value.cpp \
    src/json/json_spirit_reader.cpp \
    src/qt/clientmodel.cpp \
    src/qt/guiutil.cpp \
    src/qt/transactionrecord.cpp \
    src/qt/optionsmodel.cpp \
    src/qt/monitoreddatamapper.cpp \
    src/qt/transactiondesc.cpp \
    src/qt/transactiondescdialog.cpp \
    src/qt/bitcoinstrings.cpp \
    src/qt/bitcoinamountfield.cpp \
    src/wallet.cpp \
    src/keystore.cpp \
    src/qt/transactionfilterproxy.cpp \
    src/qt/transactionview.cpp \
    src/qt/walletmodel.cpp \
    src/bitcoinrpc.cpp \
    src/rpcdump.cpp \
    src/rpcnet.cpp \
    src/rpcrawtransaction.cpp \
    src/qt/overviewpage.cpp \
    src/qt/csvmodelwriter.cpp \
    src/crypter.cpp \
    src/qt/sendcoinsentry.cpp \
    src/qt/qvalidatedlineedit.cpp \
    src/qt/bitcoinunits.cpp \
    src/qt/qvaluecombobox.cpp \
    src/qt/askpassphrasedialog.cpp \
    src/protocol.cpp \
    src/qt/notificator.cpp \
    src/qt/qtipcserver.cpp \
    src/qt/rpcconsole.cpp \
    src/scrypt.c \
    src/qt/miningpage.cpp \
    src/noui.cpp \
    src/qt/macnativetoolbardelegate.mm \
    src/qt/macnativetoolbarprivate.mm \
    src/qt/macnativetoolbar.mm

RESOURCES += \
    src/qt/bitcoin.qrc

FORMS += \
    src/qt/forms/sendcoinsdialog.ui \
    src/qt/forms/coincontroldialog.ui \
    src/qt/forms/addressbookpage.ui \
    src/qt/forms/signverifymessagedialog.ui \
    src/qt/forms/aboutdialog.ui \
    src/qt/forms/editaddressdialog.ui \
    src/qt/forms/transactiondescdialog.ui \
    src/qt/forms/overviewpage.ui \
    src/qt/forms/sendcoinsentry.ui \
    src/qt/forms/askpassphrasedialog.ui \
    src/qt/forms/rpcconsole.ui \
    src/qt/forms/miningpage.ui \
    src/qt/forms/optionsdialog.ui

contains(USE_QRCODE, 1) {
HEADERS += src/qt/qrcodedialog.h
SOURCES += src/qt/qrcodedialog.cpp
FORMS += src/qt/forms/qrcodedialog.ui
}

contains(BITCOIN_QT_TEST, 1) {
SOURCES += src/qt/test/test_main.cpp \
    src/qt/test/uritests.cpp
HEADERS += src/qt/test/uritests.h
DEPENDPATH += src/qt/test
QT += testlib
TARGET = bitcoin-qt_test
DEFINES += BITCOIN_QT_TEST
}

CODECFORTR = UTF-8

# for lrelease/lupdate
# also add new translations to src/qt/bitcoin.qrc under translations/
TRANSLATIONS = $$files(src/qt/locale/bitcoin_*.ts)

isEmpty(QMAKE_LRELEASE) {
    win32:QMAKE_LRELEASE = $$[QT_INSTALL_BINS]\\lrelease.exe
    else:QMAKE_LRELEASE = $$[QT_INSTALL_BINS]/lrelease
}
isEmpty(QM_DIR):QM_DIR = $$PWD/src/qt/locale
# automatically build translations, so they can be included in resource file
TSQM.name = lrelease ${QMAKE_FILE_IN}
TSQM.input = TRANSLATIONS
TSQM.output = $$QM_DIR/${QMAKE_FILE_BASE}.qm
TSQM.commands = $$QMAKE_LRELEASE ${QMAKE_FILE_IN} -qm ${QMAKE_FILE_OUT}
TSQM.CONFIG = no_link
QMAKE_EXTRA_COMPILERS += TSQM

# "Other files" to show in Qt Creator
OTHER_FILES += \
    contrib/gitian-descriptors/* doc/*.rst doc/*.txt doc/README README.md res/bitcoin-qt.rc \
    share/setup.nsi

# platform specific defaults, if not overridden on command line
isEmpty(BOOST_LIB_SUFFIX) {
    macx:BOOST_LIB_SUFFIX = -mt
    windows:BOOST_LIB_SUFFIX = -mgw44-mt-s-1_49
}

isEmpty(BOOST_THREAD_LIB_SUFFIX) {
    BOOST_THREAD_LIB_SUFFIX = $$BOOST_LIB_SUFFIX
}

isEmpty(BDB_LIB_PATH) {
    macx:BDB_LIB_PATH = /usr/local/opt/berkeley-db@4/lib
}

isEmpty(BDB_LIB_SUFFIX) {
    macx:BDB_LIB_SUFFIX = -4.8
}

isEmpty(BDB_INCLUDE_PATH) {
    macx:BDB_INCLUDE_PATH = /usr/local/opt/berkeley-db@4/include
}

isEmpty(BOOST_LIB_PATH) {
    macx:BOOST_LIB_PATH = /usr/local/opt/boost/lib
}

isEmpty(BOOST_INCLUDE_PATH) {
    macx:BOOST_INCLUDE_PATH = /usr/local/opt/boost/include
}

windows:LIBS += -lws2_32 -lshlwapi -lmswsock
windows:DEFINES += WIN32
windows:RC_FILE = src/qt/res/bitcoin-qt.rc

windows:!contains(MINGW_THREAD_BUGFIX, 0) {
    # At least qmake's win32-g++-cross profile is missing the -lmingwthrd
    # thread-safety flag. GCC has -mthreads to enable this, but it doesn't
    # work with static linking. -lmingwthrd must come BEFORE -lmingw, so
    # it is prepended to QMAKE_LIBS_QT_ENTRY.
    # It can be turned off with MINGW_THREAD_BUGFIX=0, just in case it causes
    # any problems on some untested qmake profile now or in the future.
    DEFINES += _MT
    QMAKE_LIBS_QT_ENTRY = -lmingwthrd $$QMAKE_LIBS_QT_ENTRY
}

!windows:!mac {
    DEFINES += LINUX
    LIBS += -lrt
}

macx:HEADERS += src/qt/macdockiconhandler.h \
                src/qt/macnotificationhandler.h
macx:OBJECTIVE_SOURCES += src/qt/macdockiconhandler.mm \
                          src/qt/macnotificationhandler.mm 
macx:LIBS += -framework Foundation -framework ApplicationServices -framework AppKit
macx:DEFINES += MAC_OSX MSG_NOSIGNAL=0
macx:ICON = src/qt/res/icons/bitcoin.icns
macx:TARGET = "Bitcoin-sCrypt-qt"

# Set libraries and includes at end, to use platform-defined defaults if not overridden
INCLUDEPATH += $$BOOST_INCLUDE_PATH $$BDB_INCLUDE_PATH $$OPENSSL_INCLUDE_PATH $$QRENCODE_INCLUDE_PATH
LIBS += $$join(BOOST_LIB_PATH,,-L,) $$join(BDB_LIB_PATH,,-L,) $$join(OPENSSL_LIB_PATH,,-L,) $$join(QRENCODE_LIB_PATH,,-L,)
LIBS += -lssl -lcrypto -ldb_cxx$$BDB_LIB_SUFFIX
# -lgdi32 has to happen after -lcrypto (see  #681)
windows:LIBS += -lole32 -luuid -lgdi32
LIBS += -lboost_system$$BOOST_LIB_SUFFIX -lboost_filesystem$$BOOST_LIB_SUFFIX -lboost_program_options$$BOOST_LIB_SUFFIX -lboost_thread$$BOOST_THREAD_LIB_SUFFIX

contains(RELEASE, 1) {
    !windows:!macx {
        # Linux: turn dynamic linking back on for c/c++ runtime libraries
        LIBS += -Wl,-Bdynamic
    }
}

#system($$QMAKE_LRELEASE -silent $$_PRO_FILE_)


