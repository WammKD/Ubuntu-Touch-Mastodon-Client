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

import "biwascheme-0.7.0.js" as Biwa
import "Components"          as Components
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

  Components.ConvergentTabView {
    id          : tabView;
    anchors.fill: parent;
    model       : [{ "name"     : i18n.tr("Home"),
                     "iconName" : "ubuntu-store-symbolic",
                     "sourceUrl": Qt.resolvedUrl("Test.qml") },
                   { "name"    : i18n.tr("Notifications"),
                     "iconName": "view-list-symbolic"    },
                   { "name"    : i18n.tr("Local"),
                     "iconName": "find"           },
                   { "name"    : i18n.tr("Federated"),
                     "iconName": "document-save",
                     "count"   : 2                    }];

    Loader {
      id           : view;
      anchors.fill : parent;
      clip         : true;
      source       : tabView.model[tabView.selectedIndex].sourceUrl;
      onItemChanged: {
        if(item) {
          item.parent       = tabView.mainContent;
          item.anchors.fill = tabView.mainContent;
        }
      }


    }
  }
}
