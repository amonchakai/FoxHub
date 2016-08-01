import bb.cascades 1.3

Page {
    titleBar: TitleBar {
        title: qsTr("Comment")
        dismissAction: ActionItem {
            title: qsTr("Close")
            onTriggered: {
                // Emit the custom signal here to indicate that this page needs to be closed
                // The signal would be handled by the page which invoked it
                nav.pop();
            }
        }
        acceptAction: ActionItem {
            title: qsTr("Post")
            onTriggered: {
                if(!edit)
                    issueController.insertComment(description.text);
                else 
                    issueController.updateComment(id, description.text);
                nav.pop();
            }
        }
    }
    
    property int id
    property bool edit
    property string body
    
    Container {
        layout: StackLayout {}
        
        TextArea {
            id: description
            hintText: qsTr("What is on your mind?")
            layoutProperties: StackLayoutProperties {
                spaceQuota: 1
            }
        }
    }
    
    onBodyChanged: {
        description.text = body;
    }
    

}
