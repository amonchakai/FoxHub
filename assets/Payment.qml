import bb.cascades 1.4
import bb.platform 1.2

        
Page {
     id: paymentPage
     property string sku
     property bool   owned
     
     titleBar: TitleBar {
         title: qsTr("Donation")
         dismissAction: ActionItem {
             title: qsTr("Close")
             onTriggered: {
                 // Emit the custom signal here to indicate that this page needs to be closed
                 // The signal would be handled by the page which invoked it
                 payment.close();
             }
         }
     }
     
     
     
     Container {
         
         layout: StackLayout {
             orientation: LayoutOrientation.TopToBottom
         }
         
         // --------------------------------------------------------------------------
         Container {
             preferredHeight: ui.du(4)
         }
         
         Container {
             layout: StackLayout { orientation: LayoutOrientation.LeftToRight }
             
             Label {
                 text: qsTr("Donate")
                 textStyle.fontSize: FontSize.Large
                 horizontalAlignment: HorizontalAlignment.Left
                 verticalAlignment: VerticalAlignment.Bottom
             }
         
         }
         Divider { }
         
         ScrollView {   
             id: info
             Label {
                 multiline: true  
                 textStyle.textAlign: TextAlign.Justify
                 margin.leftOffset: ui.du(1)
                 margin.rightOffset: ui.du(1)
                 text: qsTr("You are currently visiting the donation page to the developer of Hg10. There is no obligation to do so, only if you want to. This do not unlock features in the application. All supported features are already included in the application whether you have donated or not.")
             }
         }
         
         Container {
             preferredHeight: ui.du(4)
         }
         
         
         Container {
             layout: StackLayout {
                 orientation: LayoutOrientation.LeftToRight
             }
             horizontalAlignment: HorizontalAlignment.Center
             
             Button {
                 id: donateButton
                 text: qsTr("Donate ~1$") 
                 horizontalAlignment: HorizontalAlignment.Left
                 onClicked: {
                     paymentPage.sku = "SKU59962551";
                     paymentPage.owned = false;
                     
                     if(!paymentPage.owned)
                         rootPaymentManager.requestPurchase("", paymentPage.sku, "Donation");
                 }
             }
             
             Button {
                 id: donateMoreButton
                 text: qsTr("Donate ~2$") 
                 horizontalAlignment: HorizontalAlignment.Right
                 onClicked: {
                     paymentPage.sku = "SKU59964078";
                     paymentPage.owned = false;
                     
                     if(!paymentPage.owned)
                         rootPaymentManager.requestPurchase("", paymentPage.sku, "Donation");
                 }
             }
         }
         
         
         Container {
             id: theBrains
             visible: false
             
             layout: DockLayout { }
             horizontalAlignment: HorizontalAlignment.Center
             verticalAlignment: VerticalAlignment.Center
             preferredHeight: ui.du(55);
             Container {
                 layout: StackLayout {
                     orientation: LayoutOrientation.TopToBottom
                 }
                 horizontalAlignment: HorizontalAlignment.Center
                 verticalAlignment: VerticalAlignment.Center
                 
                 Label {
                     text: qsTr("Thank you for your support!")
                     horizontalAlignment: HorizontalAlignment.Center
                 }
                 
                 Button {
                     text: qsTr("Close")
                     onClicked: { payment.close() }
                     horizontalAlignment: HorizontalAlignment.Center
                 }
             }
         }
     
     }
     
     attachedObjects: [
         PaymentManager {
             id: rootPaymentManager
             applicationIconUrl: "https://raw.githubusercontent.com/amonchakai/Hg10/master/icon.png"
             onPurchaseFinished: {
                 if (reply.errorCode == 0) {
                     info.visible = false;
                     donateButton.visible = false;
                     donateMoreButton.visible = false;
                     theBrains.visible = true;
                 
                 } else {
                     console.log("Error: " + reply.errorInfo);
                 }
             }
         }
     ]
     
     onCreationCompleted: {
         //rootPaymentManager.setConnectionMode(0);
         
         
     
     }
}


