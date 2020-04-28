/*
 * Copyright (C) 2020  Wamm K. D.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * ubuntu-calculator-app is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.7
import Ubuntu.Components 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0

MainView {
  id                  : root;
  objectName          : 'mainView';
  applicationName     : 'pistach.jaft';
  automaticOrientation: true;

  width               : units.gu(45);
  height              : units.gu(75);


  ColumnLayout {
    id     : login;
    spacing: 10;

    anchors {
      centerIn: parent;
      margins : units.gu(5);
    }

    Label {
      text    : "Pistach";
      color   : UbuntuColors.slate;
      fontSize: "x-large";
    }

    TextField {
      id                      : instance;
      placeholderText         : "Instance URL";
      anchors.horizontalCenter: parent.horizontalCenter;
    }

    TextField {
      id                      : username;
      placeholderText         : "Username";
      anchors.horizontalCenter: parent.horizontalCenter;
    }

    TextField {
      id                      : password;
      placeholderText         : "Password";
      anchors.horizontalCenter: parent.horizontalCenter;
    }

    Rectangle {
      height: units.gu(4);
    }

    Button {
      id                   : butt;
      text                 : "Login";
      color                : butt.enabled ? UbuntuColors.green :
                                            UbuntuColors.slate;
      enabled              : instance.text !== "" &&
                             username.text !== "" &&
                             password.text !== "";
      Layout.preferredWidth: password.width;
    }
  }
      
  Components.ConvergentTabView {
    id          : main;
    anchors.fill: parent;
    visible     : false;
    model       : [{ "name"     : i18n.tr("Home"),
                     "iconName" : "home",
                     "sourceUrl": Qt.resolvedUrl("Test.qml") },
                   { "name"    : i18n.tr("Notifications"),
                     "iconName": "notification",
                     "count"   : 2                        },
                   { "name"    : i18n.tr("Local"),
                     "iconName": "contact-group"  },
                   { "name"    : i18n.tr("Federated"),
                     "iconName": "stock_website"      }];

    Loader {
      id           : view;
      anchors.fill : parent;
      clip         : true;
      source       : main.model[main.selectedIndex].sourceUrl;
      onItemChanged: {
        if(item) {
          item.parent       = main.mainContent;
          item.anchors.fill = main.mainContent;
        }
      }
    }
  }
}
