import QtQuick 2.4
import Ubuntu.Components 1.3

Item {
  id: rootItem

  property         var   model;
  property         int   selectedIndex  : 0;
  property         bool  isWide         : rootItem.width >= units.gu(120);
  property         alias mainContent    : tabViewContent;
  default property alias mainContentData: tabViewContent.children;
  property         bool  barVisible     : true;

  LeftNavigationBar {
    id               : leftBar;
    visible          : rootItem.isWide && barVisible;
    model            : rootItem.model;
    selectedIndex    : rootItem.selectedIndex;
    onTabThumbClicked: rootItem.selectedIndex = index;
  }

  BottomNavigationBar {
    id               : topBar;
    visible          : !rootItem.isWide && barVisible;
    model            : rootItem.model;
    selectedIndex    : rootItem.selectedIndex;
    onTabThumbClicked: rootItem.selectedIndex = index;
  }

  Item {
    id: tabViewContent;

    anchors {
      top   : topBar.bottom;
      left  : leftBar.right;
      right : parent.right;
      bottom: parent.bottom;
    }
  }
}
