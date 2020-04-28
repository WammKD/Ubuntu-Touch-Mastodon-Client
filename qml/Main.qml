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
import "scheme_functions.js" as SchemeFunctions
import QtQuick 2.7
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem
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

  property var biwaScheme:            Biwa["BiwaScheme"];
  property var initScheme: SchemeFunctions["SchemeFunctions"];

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

  Component.onCompleted: {
    initScheme();

    var biwa = new biwaScheme.Interpreter(function(e) {
                                            console.error(e);
                                          });

    biwa.evaluate("(load \"utils.scm\")            " +
                  "(load \"elefan_enums.scm\")     " +
                  "(load \"elefan_auth.scm\")      " +
                  "(load \"elefan_entities.scm\" (lambda (undef) (display \"ENTITIES loaded\")))  "/*  + */
                  /* "(load \"elefan_blocks.scm\")    " + */
                  /* "(load \"elefan_emojis.scm\")    " + */
                  /* "(load \"elefan_favorites.scm\") " */, function(result) { console.log("FUCK"); });
  }
}

/*     Component.onCompleted: {
/*       initScheme();

/*       var biwa = new biwaScheme.Interpreter(function(e) { */
/*                                               console.error(e); */
/*                                             }); */

/*       biwa.evaluate("(load \"utils.scm\")           " + */
/*                     "(load \"elefan_enums.scm\")    " + */
/*                     "(load \"elefan_auth.scm\")     " + */
/*                     "(load \"elefan_entities.scm\") " + */
/*                     "(load \"elefan_blocks.scm\")   " + */
/*                     "(load \"elefan_emojis.scm\")   " + */
/*                     "(load \"elefan_favorites.scm\")   " /\* + *\/ + */
/*                     "(define zuzz (masto-app-instantiate " + */
/*                     "               \"https://queer.garden\" " + */
/*                     "               '#:scopes '(\"read\" \"write\" \"follow\" \"push\") "       + */
/*                     "               '#:id     \"qlN7eBiiDb_6bXanjkL9mmz1FU12Qu9oVAo-Oh6WzS0\" " + */
/*                     "               '#:secret \"CiUs_6SXHvQhpsPL-Nboex8VB-bZJuVejmX7NGgXDLE\" " + */
/*                     "               '#:key \"BCbx4lQBNMehaSmxd_1oBr6wLVI6a6MGmtEAZAA-A0JmiLe6EmI-yfwKPYj9Vu9r57gV4tDWjlTjq28m9yF9Ipk=\")) " + */
/*                     "(masto-app-set-token-via-user-cred! zuzz \"wamm_kd_schmelingski@yahoo.com\" \"KepKep12\") " + */
/*                     "(masto-favorites-all zuzz)" */
/*                     /\* "(load \"\") " + *\/ */
/*                     /\* "(load \"\") " + *\/ */
/*                     /\* "(load \"\") " + *\/ */
/*                     /\* "(load \"\") " + *\/ */
/*                     /\* "(load \"\") " + *\/ */
/*                     /\* "(load \"\") " + *\/, function(result) { */
/*                                               console.log(result); */
/*                                             }); */

/*       /\* biwa.evaluate("(let ([name      \"Elefan\"] [redirects '(\"urn:ietf:wg:oauth:2.0:oob\")] [scopes    '(\"read\" \"write\" \"follow\" \"push\")]) (http-post (string-append \"https://queer.garden\" \"/api/v1/apps\" (assemble-params `((\"client_name\"   ,name) (\"redirect_uris\" ,(string-join redirects  \"\n\")) (\"scopes\"        ,(string-join scopes    \"%20\"))))) '()))", function(result) { *\/ */
/*       /\*                             console.log("THE RESULT ORIGINAL‽\n"); *\/ */

/*       /\*                             console.log(result); *\/ */
/*       /\*                           }); *\/ */
/*     } */
/*   } */
/* } */
