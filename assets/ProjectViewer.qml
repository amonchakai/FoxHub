import bb.cascades 1.3
import Utility.ProjectViewerController 1.0
import com.netimage 1.0

Page {
    titleBar: TitleBar {
        kind: TitleBarKind.FreeForm
        kindProperties: FreeFormTitleBarKindProperties {
            Container {
                layout: DockLayout { }
                leftPadding: 10
                rightPadding: 10
                
                Label {
                    id: labelName
                    text: name
                    verticalAlignment: VerticalAlignment.Center
                    horizontalAlignment: HorizontalAlignment.Center
                }
                
                ImageButton {
                    verticalAlignment: VerticalAlignment.Center
                    horizontalAlignment: HorizontalAlignment.Left
                    defaultImageSource: Application.themeSupport.theme.colorTheme.style == VisualStyle.Dark ? "asset:///images/icon_left.png" : "asset:///images/icon_left_black.png"
                    onClicked: {
                        projectViewerController.pop();
                    }
                }  
            }
        }
    }
    
    property string name
    property string description
    property string content_url
    property string issues_url
    property string commits_url
    
    property variant viewerPage
    property variant issuePage
    
    Container {
        layout: StackLayout { 
            orientation: LayoutOrientation.TopToBottom
        }
        
        SegmentedControl {
            horizontalAlignment: HorizontalAlignment.Fill
            id: actionSelector
            
            Option {
                id: option1
                text: qsTr("Code")
                value: 0
            }
            Option {
                id: option2
                text: qsTr("Issues")
                value: 1
            }
            Option {
                id: option3
                text: qsTr("Commits")
                value: 2
            }
            
            onSelectedIndexChanged: {
                scrollView.scrollToPoint(DisplayInfo.width*selectedIndex, scrollView.viewableArea.y);
            }
        }
        
        
        ScrollView {
            id: scrollView
            scrollViewProperties.scrollMode: ScrollMode.Horizontal
            focusRetentionPolicyFlags: FocusRetentionPolicy.LoseToFocusable
            
            onViewableAreaChanged: {
                if(viewableArea.x % DisplayInfo.width != 0) {
                    scrollView.scrollToPoint(Math.floor(viewableArea.x/DisplayInfo.width+0.5)*DisplayInfo.width, scrollView.viewableArea.y);
                
                } else {
                    actionSelector.selectedIndex = Math.floor(viewableArea.x/DisplayInfo.width);
                }
            
            
            }
            
            Container {
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                
                Container {
                    layout: DockLayout { }
                    preferredWidth: DisplayInfo.width
                    
                    ActivityIndicator {
                        id: activity
                        preferredHeight: ui.du(10)
                        horizontalAlignment: HorizontalAlignment.Center
                    }
                    
                    Container {  
                        id: dataEmptyLabel
                        visible: dataModel.empty //model.isEmpty() will not work  
                        horizontalAlignment: HorizontalAlignment.Center  
                        verticalAlignment: VerticalAlignment.Center
                        
                        layout: DockLayout {}
                        
                        Label {
                            text: qsTr("No sources.")
                            verticalAlignment: VerticalAlignment.Center
                            horizontalAlignment: HorizontalAlignment.Center
                        }
                    }
                    
                    ListView {
                        preferredWidth: DisplayInfo.width
                        id: contentListView
                        
                        // ------------------------------------------------------------------
                        // Pull to refresh
                        signal refreshTriggered()
                        property bool loading: false
                        leadingVisualSnapThreshold: 2.0
                        leadingVisual: RefreshHeader {
                            id: refreshHandler
                            onRefreshTriggered: {
                                projectViewerController.refreshContents();
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
                                    preferredHeight: ui.du(12)
                                    id: listItemContainer
                                    horizontalAlignment: HorizontalAlignment.Fill
                                    verticalAlignment: VerticalAlignment.Center
                                    layout: DockLayout {
                                    }
                                    
                                    Container {
                                        verticalAlignment: VerticalAlignment.Center
                                        layout: StackLayout {
                                            orientation: LayoutOrientation.LeftToRight
                                        }
                                        Container {
                                            preferredWidth: ui.du(0.1)
                                        }
                                        
                                        ImageView {
                                            imageSource: "asset:///images/icon_" + ListItemData.type + ".png"
                                            preferredHeight: ui.du(5)
                                            preferredWidth: ui.du(5)
                                            verticalAlignment: VerticalAlignment.Center
                                        }
                                        
                                        Container {
                                            preferredWidth: ui.du(0.1)
                                        }
                                        
                                        Label {
                                            text: ListItemData.name 
                                            verticalAlignment: VerticalAlignment.Center
                                        }
                                    }
                                    
                                    Divider {}
                                
                                }
                            }
                        ]
                        
                        onTriggered: {
                            var chosenItem = dataModel.data(indexPath);
                            
                            if(chosenItem.type == "file") {
                                if(!viewerPage)
                                    viewerPage = viewer.createObject();
                                
                                viewerPage.url_page = chosenItem.download_url;
                                
                                nav.push(viewerPage);
                            }
                            
                            if(chosenItem.type == "dir") {
                                projectViewerController.getContent(chosenItem.url);
                            }
                        
                        
                        }
                        
                        dataModel: GroupDataModel {
                            id: dataModel    
                            grouping: ItemGrouping.None
                            sortingKeys: ["type","name"]
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
                
                
                Container {
                    layout: DockLayout { }
                    preferredWidth: DisplayInfo.width
                    
                    ActivityIndicator {
                        id: activityIssues
                        preferredHeight: ui.du(10)
                        horizontalAlignment: HorizontalAlignment.Center
                    }
                    
                    Container {  
                        visible: dataModelIssues.empty //model.isEmpty() will not work  
                        horizontalAlignment: HorizontalAlignment.Center  
                        verticalAlignment: VerticalAlignment.Center
                        
                        layout: DockLayout {}
                        
                        Label {
                            text: qsTr("No issues.")
                            verticalAlignment: VerticalAlignment.Center
                            horizontalAlignment: HorizontalAlignment.Center
                        }
                    }
                    
                    ListView {
                        preferredWidth: DisplayInfo.width
                        id: issuesListView
                        
                        // ------------------------------------------------------------------
                        // Pull to refresh
                        signal refreshTriggered()
                        property bool loading: false
                        leadingVisualSnapThreshold: 2.0
                        leadingVisual: RefreshHeader {
                            id: refreshIssueHandler
                            onRefreshTriggered: {
                                projectViewerController.refreshIssues();
                                activityIssues.start();
                            }
                        }
                        onTouch: {
                            refreshIssueHandler.onListViewTouch(event);
                        }
                        onLoadingChanged: {
                            refreshIssueHandler.refreshing = refreshableList.loading;
                            
                            if(!refreshIssueHandler.refreshing) {
                                // If the refresh is done 
                                // Force scroll to top to ensure that all items are visible
                                scrollToPosition(ScrollPosition.Beginning, ScrollAnimation.None);
                            }
                        }
                        
                        listItemComponents: [
                            ListItemComponent {
                                type: "item"
                                
                                Container {
                                    preferredHeight: ui.du(12)
                                    id: listItemContainerIssues
                                    horizontalAlignment: HorizontalAlignment.Fill
                                    verticalAlignment: VerticalAlignment.Center
                                    layout: DockLayout {
                                    }
                                    
                                    Container {
                                        verticalAlignment: VerticalAlignment.Center
                                        layout: StackLayout {
                                            orientation: LayoutOrientation.LeftToRight
                                        }
                                        Container {
                                            preferredWidth: ui.du(0.1)
                                        }
                                        
                                        Label {
                                            text: "<html><body>" + listItemContainerIssues.ListItem.view.getTags(ListItemData.title, ListItemData.labels) + "</body></html>" 
                                            multiline: true
                                            
                                            
                                            verticalAlignment: VerticalAlignment.Center
                                        }
                                    }
                                    
                                    Container {
                                        horizontalAlignment: HorizontalAlignment.Right
                                        verticalAlignment: VerticalAlignment.Center
                                        layout: StackLayout {
                                            orientation: LayoutOrientation.LeftToRight
                                        }
                                        Container {
                                            layout: DockLayout {}
                                            
                                            ImageView {
                                                imageSource: Application.themeSupport.theme.colorTheme.style == VisualStyle.Dark ? "asset:///images/icon_quoted_white.png" : "asset:///images/icon_quoted.png"
                                                minHeight: ui.du(6)
                                                minWidth: ui.du(6)
                                                visible: ListItemData.comments != 0
                                                horizontalAlignment: HorizontalAlignment.Center
                                                verticalAlignment: VerticalAlignment.Center
                                            }
                                            
                                            Label {
                                                text: ListItemData.comments
                                                textStyle.fontSize: FontSize.XSmall
                                                visible: ListItemData.comments != 0
                                                textStyle.color: Application.themeSupport.theme.colorTheme.style == VisualStyle.Dark ? Color.Black : Color.White
                                                horizontalAlignment: HorizontalAlignment.Center
                                                verticalAlignment: VerticalAlignment.Top
                                            
                                            }
                                        }
                                        Container {
                                            preferredWidth: ui.du(1)
                                        }
                                    
                                    }
                                    
                                    Divider {}
                                
                                }
                            }
                        ]
                        
                        function getTags(title, tags) {
                            var tags_str = "<tr><td>" + title + "&nbsp;&nbsp;</td>";
                            
                            if ( tags.length < 1) return tags_str + "</tr>";
                            
                            for(var i = 0 ; i < tags.length ; ++i) {
                                tags_str += "<td style=\"color:#ffffff; background-color: #" + tags[i].color + "; \">&nbsp;" + tags[i].name + " &nbsp;</td>&nbsp;";
                            }
                            
                            return tags_str + "</tr>";
                        }
                        
                        onTriggered: {
                            var chosenItem = dataModelIssues.data(indexPath);
                            
                            if(!issuePage)
                                issuePage = issueViewer.createObject();
                            
                            issuePage.issue_url = chosenItem.url;
                            issuePage.caption = chosenItem.title;
                            
                            nav.push(issuePage);
                        
                        
                        }
                        
                        dataModel: GroupDataModel {
                            id: dataModelIssues   
                            grouping: ItemGrouping.None
                            sortingKeys: ["number"]
                            sortedAscending: false
                            
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
                
                
                
                Container {
                    layout: DockLayout { }
                    preferredWidth: DisplayInfo.width
                    
                    ActivityIndicator {
                        id: activityCommits
                        preferredHeight: ui.du(10)
                        horizontalAlignment: HorizontalAlignment.Center
                    }
                    
                    Container {  
                        visible: dataModelCommits.empty //model.isEmpty() will not work  
                        horizontalAlignment: HorizontalAlignment.Center  
                        verticalAlignment: VerticalAlignment.Center
                        
                        layout: DockLayout {}
                        
                        Label {
                            text: qsTr("No commits.")
                            verticalAlignment: VerticalAlignment.Center
                            horizontalAlignment: HorizontalAlignment.Center
                        }
                    }
                    
                    ListView {
                        preferredWidth: DisplayInfo.width
                        id: commitsListView
                        
                        // ------------------------------------------------------------------
                        // Pull to refresh
                        signal refreshTriggered()
                        property bool loading: false
                        leadingVisualSnapThreshold: 2.0
                        leadingVisual: RefreshHeader {
                            id: refreshCommitsHandler
                            onRefreshTriggered: {
                                projectViewerController.refreshCommits();
                                activityCommits.start();
                            }
                        }
                        onTouch: {
                            refreshCommitsHandler.onListViewTouch(event);
                        }
                        onLoadingChanged: {
                            refreshCommitsHandler.refreshing = refreshableList.loading;
                            
                            if(!refreshCommitsHandler.refreshing) {
                                // If the refresh is done 
                                // Force scroll to top to ensure that all items are visible
                                scrollToPosition(ScrollPosition.Beginning, ScrollAnimation.None);
                            }
                        }
                        
                        listItemComponents: [
                            ListItemComponent {
                                type: "item"
                                
                                Container {
                                    preferredHeight: ui.du(12)
                                    id: listItemContainerCommits
                                    horizontalAlignment: HorizontalAlignment.Fill
                                    verticalAlignment: VerticalAlignment.Center
                                    layout: DockLayout {
                                    }
                                    
                                    
                                    Container {
                                        verticalAlignment: VerticalAlignment.Center
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
                                                    
                                                    source: ListItemData.committer.avatar_url                             
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
                                            
                                            Label {
                                                text: ListItemData.commit.message
                                                verticalAlignment: VerticalAlignment.Top
                                            }
                                            
                                            Container {
                                                layout: StackLayout {
                                                    orientation: LayoutOrientation.LeftToRight
                                                }
                                                verticalAlignment: VerticalAlignment.Bottom
                                                
                                                Label {
                                                    text: ListItemData.commit.committer.name
                                                    textStyle.color: Color.Gray
                                                    
                                                }
                                                
                                                Label {
                                                    text: listItemContainerCommits.ListItem.view.formatDate(ListItemData.commit.committer.date)
                                                    textStyle.color: Color.create("#4c6ada")
                                                }
                                            }
                                            
                                            
                                            
                                        }
                                        
                                        
                                    }
                                    
                                    
                                    Divider {}
                                
                                }
                            }
                        ]
                        
                        function formatDate(iDate) {
                            return projectViewerController.formatDate(iDate);
                        }
                        
                        dataModel: GroupDataModel {
                            id: dataModelCommits   
                            grouping: ItemGrouping.None
                            sortingKeys: ["commit.committer.date"]
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
    }
    
    
    onNameChanged: {
        labelName.text = name;
    }
    
    onContent_urlChanged: {
        projectViewerController.setRoot(content_url);
    }
    
    onIssues_urlChanged: {
        projectViewerController.setRootIssues(issues_url);
    }
    
    onCommits_urlChanged: {
        projectViewerController.setRootCommits(commits_url);
    }
    
    onCreationCompleted: {
        projectViewerController.setContentListView(contentListView);
        projectViewerController.setIssuesListView(issuesListView);
        projectViewerController.setCommitsListView(commitsListView);
    }
    
    attachedObjects: [
        ProjectViewerController {
            id: projectViewerController
            
            onLoaded: {
                activity.stop();
            }
            
            onIssueLoaded: {
                activityIssues.stop();
            }
            
            onCommitsLoaded: {
                activityCommits.stop();
            }
        },
        ComponentDefinition {
            id: viewer
            source: "FileViewer.qml"
        },
        ComponentDefinition {
            id: issueViewer
            source: "IssueViewer.qml"
        }
    ]
}
