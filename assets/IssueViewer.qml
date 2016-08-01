import bb.cascades 1.3
import Utility.IssueController 1.0
import com.netimage 1.0

Page {
    property string issue_url
    property string caption
    property variant composeCommentPage
    
    ScrollView {
        
        Container {
            layout: StackLayout {
                orientation: LayoutOrientation.TopToBottom
            }
            
            Container {
                minHeight: ui.du(0.5)
                maxHeight: ui.du(0.5)
            }
            
            Label {
                id: labelCaption
                textStyle.fontSize: FontSize.Large
            }
            
            Container {
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                
                Container {
                    minWidth: ui.du(1)
                    maxWidth: ui.du(1)
                }
                
                ImageView {
                    verticalAlignment: VerticalAlignment.Center
                    //horizontalAlignment: HorizontalAlignment.Left
                    id: avatarOwnImg
                    scalingMethod: ScalingMethod.AspectFit
                    minHeight: ui.du(8)
                    maxHeight: ui.du(8)
                    minWidth: ui.du(8)
                    maxWidth: ui.du(8)
                    image: trackerOwn.image
                    
                    attachedObjects: [
                        NetImageTracker {
                            id: trackerOwn
                                                         
                        } 
                    ]
                }
                
                Container {
                    preferredWidth: ui.du(1)
                }
                
                Container {
                    verticalAlignment: VerticalAlignment.Center
                    layout: DockLayout { }
                    preferredHeight: ui.du(9)
                    
    
                    
                    Container {
                        layout: DockLayout {
                        }
                        verticalAlignment: VerticalAlignment.Center
                        preferredHeight: ui.du(9)
                        
                        Label {
                            id: labelAuthor
                            textStyle.color: Color.Gray
                            verticalAlignment: VerticalAlignment.Top
                        
                        }
                        
                        Label {
                            id: labelDate
                            textStyle.color: Color.create("#4c6ada")
                            verticalAlignment: VerticalAlignment.Bottom
                        }
                    }
                }
                
            }
            
            Label {
                id: labelDescription
                multiline: true
            }
            
            Divider { }
    
            
            Container {
                layout: StackLayout {
                    orientation: LayoutOrientation.TopToBottom
                }
                preferredWidth: DisplayInfo.width
                
                ActivityIndicator {
                    id: activity
                    preferredHeight: ui.du(10)
                    horizontalAlignment: HorizontalAlignment.Center
                }
                
                ListView {
                    id: issueListView
                    
                    // ------------------------------------------------------------------
                    // Pull to refresh
                    signal refreshTriggered()
                    property bool loading: false
                    leadingVisualSnapThreshold: 2.0
                    leadingVisual: RefreshHeader {
                        id: refreshHandler
                        onRefreshTriggered: {
                            issueController.loadIssue(issue_url);
                            activity.start();
                        }
                    }
                    onTouch: {
                        refreshHandler.onListViewTouch(event);
                    }
                    onLoadingChanged: {
                        refreshHandler.refreshing = refreshableList.loading;
                        
                        if(!refreshHandler.refreshing) {
                            // If the refresh is done 
                            // Force scroll to top to ensure that all items are visible
                            scrollToPosition(ScrollPosition.Beginning, ScrollAnimation.None);
                        }
                    }
                    
                    listItemComponents: [
                        ListItemComponent {
                            type: "item"
                            
                            Container {
                                id: listItemContainer
                                horizontalAlignment: HorizontalAlignment.Fill
                                layout: StackLayout {
                                    orientation: LayoutOrientation.TopToBottom
                                }
                                
                                Container {
                                    verticalAlignment: VerticalAlignment.Top
                                    layout: StackLayout {
                                        orientation: LayoutOrientation.LeftToRight
                                    }
                                    
                                    Container {
                                        minWidth: ui.du(1)
                                        maxWidth: ui.du(1)
                                    }
                                    
                                    ImageView {
                                        verticalAlignment: VerticalAlignment.Center
                                        //horizontalAlignment: HorizontalAlignment.Left
                                        scalingMethod: ScalingMethod.AspectFit
                                        minHeight: ui.du(8)
                                        maxHeight: ui.du(8)
                                        minWidth: ui.du(8)
                                        maxWidth: ui.du(8)
                                        image: trackerOwn2.image
                                        
                                        attachedObjects: [
                                            NetImageTracker {
                                                id: trackerOwn2
                                                source: ListItemData.user.avatar_url
                                            
                                            } 
                                        ]
                                    }
                                    
                                    Container {
                                        preferredWidth: ui.du(1)
                                    }
                                    
                                    Container {
                                        verticalAlignment: VerticalAlignment.Center
                                        layout: DockLayout { }
                                        preferredHeight: ui.du(9)
                                        
                                        
                                        
                                        Container {
                                            layout: DockLayout {
                                            }
                                            verticalAlignment: VerticalAlignment.Center
                                            preferredHeight: ui.du(9)
                                            
                                            Label {
                                                text: ListItemData.user.login
                                                textStyle.color: Color.Gray
                                                verticalAlignment: VerticalAlignment.Top
                                            
                                            }
                                            
                                            Label {
                                                text: listItemContainer.ListItem.view.formatDate(ListItemData.updated_at)
                                                textStyle.color: Color.create("#4c6ada")
                                                verticalAlignment: VerticalAlignment.Bottom
                                            }
                                        }
                                    }
                                
                                }
                                
                                Label {
                                    verticalAlignment: VerticalAlignment.Bottom
                                    text: ListItemData.body
                                    multiline: true
                                }
                                
                                Divider {}
                                
                                contextActions: [
                                    ActionSet {
                                        title: qsTr("Comments")
                                        
                                        ActionItem {
                                            title: qsTr("Edit")
                                            imageSource: "asset:///images/icon_write_context.png"
                                            onTriggered: {
                                                listItemContainer.ListItem.view.editComment(ListItemData.id, ListItemData.body);
                                            }
                                        }
                                        
                                        DeleteActionItem {
                                            title: qsTr("Delete")
                                            onTriggered: {
                                                listItemContainer.ListItem.view.deleteComment(ListItemData.id);
                                            }
                                        }
                                    }
                                ]
                            
                            }
                        }
                    ]
                    
                    function editComment(id, body) {
                        if(!composeCommentPage)
                            composeCommentPage = composeComment.createObject();
                            
                        composeCommentPage.id = id;
                        composeCommentPage.edit = true;
                        composeCommentPage.body = body;
                        
                        nav.push(composeCommentPage);
                    }
                    
                    function deleteComment(id) {
                        issueController.deleteComment(id);
                    }
                    
                    function formatDate(iDate) {
                        return issueController.formatDate(iDate);
                    }
                    
                    
                    dataModel: GroupDataModel {
                        id: dataModel    
                        grouping: ItemGrouping.None
                        sortingKeys: ["id"]
                        sortedAscending: true
                        
                        property bool empty: true
                        
                        
                        onItemAdded: {
                            empty = isEmpty();
                        }
                        onItemRemoved: {
                            empty = isEmpty();
                        }  
                        onItemUpdated: empty = isEmpty()  
                        
                        // You might see an 'unknown signal' error  
                        // in the QML-editor, guess it's a SDK bug.  
                        onItemsChanged: empty = isEmpty()      
                    }
                }
            }
            
        }
    }
    
    actions: [
        ActionItem {
            title: qsTr("New")
            ActionBar.placement: ActionBarPlacement.Signature
            imageSource: "asset:///images/icon_pen.png"
            
            onTriggered: {
                if(!composeCommentPage)
                    composeCommentPage = composeComment.createObject();
                    
                composeCommentPage.edit = false;
                composeCommentPage.body = "";
                
                nav.push(composeCommentPage);
            }
        }
    ]
    
    onIssue_urlChanged: {
        issueController.loadIssue(issue_url);
    }
    
    onCreationCompleted: {
        issueController.setListView(issueListView);
    }
    
    attachedObjects: [
        IssueController {
            id: issueController
            
            onDescriptionLoaded: {
                trackerOwn.source = avatar_url;
                labelAuthor.text = user;
                labelCaption.text = caption;
                labelDate.text = dateIssue;
                labelDescription.text = message;
            }
            
            onLoaded: {
                activity.stop();
            }
            
            
        }, 
        ComponentDefinition {
            id: composeComment
            source: "ComposeComment.qml"
        }
    ]
}
