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

import QtQuick 2.4
import Ubuntu.Components 1.3

ScrollView {
  width : parent.width;
  height: parent.height;

  Label {
    id: fuck;

    anchors {
      top   : parent.top;
      left  : parent.left;
      right : parent.right;
      bottom: shit.top;
    }

    text               : i18n.tr('Hello World!');
    horizontalAlignment: Label.AlignHCenter;
  }

  Label {
    id: shit;

    anchors {
      top   : fuck.bottom;
      left  : parent.left;
      right : parent.right;
      bottom: piss.top;
    }

    text               : i18n.tr('Hello World2');
    horizontalAlignment: Label.AlignHCenter;
  }

  Label {
    id: piss;

    anchors {
      top   : shit.bottom;
      left  : parent.left;
      right : parent.right;
      bottom: parent.bottom;
    }

    text               : i18n.tr('Hello World3');
    horizontalAlignment: Label.AlignHCenter;
  }
}

