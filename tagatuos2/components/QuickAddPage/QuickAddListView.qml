import QtQuick 2.9
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../Common"
//import "../DetailView"
import ".."
import "../../library/DataProcess.js" as DataProcess
import "../../library/ProcessFunc.js" as Process
import "../../library/ApplicationFunctions.js" as AppFunctions

ListView {
    id: listView

    interactive: true
    model: mainView.listModels.modelQuickAdd
    snapMode: ListView.SnapToItem
    clip: true
    anchors {
        left: parent.left
        right: parent.right
        top: parent.top
        bottom: bottomBarNavigation.visible ? bottomBarNavigation.top : parent.bottom
    }

    onActiveFocusChanged: {
        if(activeFocus){
            findToolBar.forceFocus()
        }
    }

    delegate: QuickAddItem {
        id: quickAdditem

        itemName: quickname
        itemValue: quickvalue //AppFunctions.formatMoney(quickvalue, false)
        itemDescr: descr
        itemCategory: category_name
        itemDate: quickdate
        itemTravelValue: travel_value
        itemRate: rate
        itemTravelCur: travelCur
        itemHomeCur: homeCur

        leadingActions: bottomBarNavigation.currentIndex === 1 ? leftListItemActions : null
        trailingActions: rightListItemActions

        onClicked: {
            addQuick(itemCategory, itemName, itemDescr, quickvalue, itemTravelValue, itemRate, itemHomeCur, itemTravelCur)
        }

        ListItemActions {
            id: rightListItemActions
            actions: [
                Action {
                    iconName: "edit"
                    text: i18n.tr("Edit")
                    visible: bottomBarNavigation.currentIndex === 1
                    onTriggered: {
                        PopupUtils.open(addDialog, null, {mode: "edit", quickID: quick_id, itemName: quickname, itemValue: quickvalue,itemDescr: descr, itemCategory: category_name})
                    }
                },
                Action {
                    iconName: "message-new"
                    text: i18n.tr("Custom Add")
                    onTriggered: {
                        var realValue
                        if(tempSettings.travelMode){
                            realValue = itemTravelValue > 0 ? itemTravelValue : quickvalue / tempSettings.exchangeRate
                        }else{
                            realValue = quickvalue
                        }

                        PopupUtils.open(addDialog, null, {mode: "custom", quickID: quick_id, itemName: quickname, itemValue: realValue,itemDescr: descr, itemCategory: category_name})
                    }
                }
                ,
                Action {
                    iconName: "info"
                    text: i18n.tr("Information")
                    visible: bottomBarNavigation.currentIndex === 0
                    onTriggered: {
                        poppingDialog.show(quickAdditem)
                    }
                }
            ]
        }
        PoppingDialog {
            id: poppingDialog

            maxHeight: units.gu(40)
            maxWidth: units.gu(30)
            parent:  mainView

            delegate: DetailDialog{
                id: detailsDialog

                category: itemCategory
                itemName: quickAdditem.itemName
                description: itemDescr
                date: itemDate
                value: AppFunctions.formatMoney(itemValue, false)
                travelValue: itemTravelValue > 0 ? Process.formatMoney(itemTravelValue, itemTravelCur) : ""
                travelRate: itemRate > 0 ? itemRate : 0


                onClosed: poppingDialog.close()
            }
        }
        ListItemActions {
            id: leftListItemActions
            actions: [
                Action {
                    iconName: "delete"
                    text: i18n.tr("Delete")
                    onTriggered: {
                        DataProcess.deleteQuickExpense(quick_id)
                        mainView.listModels.deleteQuickItem(quick_id)
                    }
                }
            ]
        }
    }
}
