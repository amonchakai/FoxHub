import bb.cascades 1.3
import Utility.ProjectsController 1.0
import com.netimage 1.0

NavigationPane {
    id: nav
    
    Page {
        id: projects
        titleBar: TitleBar {
            kind: TitleBarKind.FreeForm
            kindProperties: FreeFormTitleBarKindProperties {
                Container {
                    layout: DockLayout { }
                    leftPadding: 10
                    rightPadding: 10
                    
                    Label {
                        text: qsTr("Projects")
                        textStyle {
                            color: Application.themeSupport.theme.colorTheme.style == VisualStyle.Dark ? Color.White : Color.Black
                        }
                        verticalAlignment: VerticalAlignment.Center
                        horizontalAlignment: HorizontalAlignment.Center
                    }
                }
            }
        }
        
        property variant pageProject
        
        
        
        Container {
            layout: StackLayout {
                orientation: LayoutOrientation.TopToBottom
            }
            
            ActivityIndicator {
                id: activity
                preferredHeight: ui.du(10)
                horizontalAlignment: HorizontalAlignment.Center
            }
            
            
            Container {
                horizontalAlignment: HorizontalAlignment.Fill
                layout: DockLayout { }
                
                Container {  
                    id: dataEmptyLabel
                    visible: dataModel.empty //model.isEmpty() will not work  
                    horizontalAlignment: HorizontalAlignment.Center  
                    verticalAlignment: VerticalAlignment.Center
                    
                    layout: DockLayout {}
                    
                    Label {
                        text: qsTr("No projects.")
                        verticalAlignment: VerticalAlignment.Center
                        horizontalAlignment: HorizontalAlignment.Center
                    }
                }
                
                ListView {
                    id: projectList
                    
                    // ------------------------------------------------------------------
                    // Pull to refresh
                    signal refreshTriggered()
                    property bool loading: false
                    leadingVisualSnapThreshold: 2.0
                    leadingVisual: RefreshHeader {
                        id: refreshHandler
                        onRefreshTriggered: {
                            projectsController.getList();
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
                                preferredHeight: ui.du(36)
                                id: listItemContainer
                                verticalAlignment: VerticalAlignment.Center
                                layout: DockLayout {
                                }
                                
                                Container {
                                    verticalAlignment: VerticalAlignment.Fill
                                    horizontalAlignment: HorizontalAlignment.Fill
                                    layout: StackLayout {
                                        orientation: LayoutOrientation.LeftToRight
                                    }
                                    
                                    Container {
                                        minWidth: ui.du(2)
                                    }
                                    
                                    Container {
                                        layout: StackLayout {
                                            orientation: LayoutOrientation.TopToBottom
                                        }
                                        verticalAlignment: VerticalAlignment.Center
                                        
                                        Container {
                                            preferredHeight: ui.du(11)
                                            layout: DockLayout {}
                                            
                                            Label {
                                                text: ListItemData.name 
                                                textStyle.fontSize: FontSize.Large
                                                textStyle.color: Color.create("#4c6ada")
                                                verticalAlignment: VerticalAlignment.Top
                                            }
                                            
                                            Label {
                                                text: ListItemData.description
                                                textStyle.color: Color.Gray
                                                verticalAlignment: VerticalAlignment.Bottom
                                            }
                                        }
                                        
                                        Container {
                                            preferredHeight: ui.du(3)
                                        }
                                        
                                        
                                        Container {
                                            preferredHeight: ui.du(9)
                                            
                                            layout: StackLayout {
                                                orientation: LayoutOrientation.LeftToRight
                                            }
                                            
                                            ImageView {
                                                verticalAlignment: VerticalAlignment.Center
                                                //horizontalAlignment: HorizontalAlignment.Left
                                                id: avatarOwnImg
                                                scalingMethod: ScalingMethod.AspectFit
                                                minHeight: ui.du(9)
                                                maxHeight: ui.du(9)
                                                minWidth: ui.du(9)
                                                maxWidth: ui.du(9)
                                                image: trackerOwn.image
                                                
                                                attachedObjects: [
                                                    NetImageTracker {
                                                        id: trackerOwn
                                                        
                                                        source: ListItemData.owner.avatar_url                             
                                                    } 
                                                ]
                                            }
                                            
                                            Container {
                                                preferredWidth: ui.du(2)
                                            }
                                            
                                            Container {
                                                preferredHeight: ui.du(9)
                                                verticalAlignment: VerticalAlignment.Center
                                                layout: DockLayout {}
                                                
                                                Label {
                                                    text: ListItemData.owner.login
                                                    verticalAlignment: VerticalAlignment.Top
                                                }
                                                Label {
                                                    text: listItemContainer.ListItem.view.formatDate(ListItemData.updated_at)
                                                    verticalAlignment: VerticalAlignment.Bottom
                                                }
                                            }
                                        }
                                        
                                        Container {
                                            preferredHeight: ui.du(3)
                                        }
                                        
                                        Container {
                                            preferredHeight: ui.du(9)
                                            horizontalAlignment: HorizontalAlignment.Fill
                                            
                                            layout: GridLayout {
                                                columnCount: 5
                                            }
                                            
                                            Label {
                                                text: ListItemData.language
                                                verticalAlignment: VerticalAlignment.Center
                                                textStyle.textAlign: TextAlign.Center
                                                preferredWidth: listItemContainer.ListItem.view.getSpacing()
                                            }
                                            
                                            Container {
                                                verticalAlignment: VerticalAlignment.Fill
                                                preferredWidth: ui.du(0.1)
                                                background: Color.Gray
                                            }
                                            
                                            Container {
                                                layout: DockLayout {}
                                                
                                                verticalAlignment: VerticalAlignment.Fill
                                                preferredWidth: listItemContainer.ListItem.view.getSpacing()
                                                
                                                Container {
                                                    horizontalAlignment: HorizontalAlignment.Center
                                                    verticalAlignment: VerticalAlignment.Center
                                                    
                                                    layout: StackLayout {
                                                        orientation: LayoutOrientation.LeftToRight
                                                    }
                                                    
                                                    ImageView {
                                                        imageSource: Application.themeSupport.theme.colorTheme.style == VisualStyle.Dark ? "asset:///images/icon_favorites.png" : "asset:///images/icon_favorites_black.png"
                                                        minHeight: ui.du(5)
                                                        maxHeight: ui.du(5)
                                                        minWidth: ui.du(5)
                                                        maxWidth: ui.du(5)
                                                        verticalAlignment: VerticalAlignment.Center
                                                    
                                                    }
                                                    
                                                    Label {
                                                        text: ListItemData.stargazers_count
                                                        verticalAlignment: VerticalAlignment.Center
                                                    }
                                                }
                                            
                                            }
                                            
                                            
                                            Container {
                                                verticalAlignment: VerticalAlignment.Fill
                                                preferredWidth: ui.du(0.1)
                                                background: Color.Gray
                                            }
                                            
                                            Container {
                                                layout: DockLayout {}
                                                
                                                verticalAlignment: VerticalAlignment.Fill
                                                preferredWidth: listItemContainer.ListItem.view.getSpacing()
                                                
                                                Container {
                                                    horizontalAlignment: HorizontalAlignment.Center
                                                    verticalAlignment: VerticalAlignment.Center
                                                    
                                                    layout: StackLayout {
                                                        orientation: LayoutOrientation.LeftToRight
                                                    }
                                                    
                                                    ImageView {
                                                        imageSource: Application.themeSupport.theme.colorTheme.style == VisualStyle.Dark ? "asset:///images/icon_fork_white.png"  : "asset:///images/icon_fork.png"
                                                        minHeight: ui.du(5)
                                                        maxHeight: ui.du(5)
                                                        minWidth: ui.du(5)
                                                        maxWidth: ui.du(5)
                                                        verticalAlignment: VerticalAlignment.Center
                                                    
                                                    }
                                                    
                                                    Label {
                                                        text: ListItemData.forks_count
                                                        verticalAlignment: VerticalAlignment.Center
                                                    }
                                                }
                                            }
                                        }
                                    }
                                
                                
                                }
                                
                                
                                Divider {}
                            
                            }
                        }
                    ]
                    
                    function getSpacing() {
                        return (DisplayInfo.width-ui.du(6))/3;
                    }
                    
                    function formatDate(iDate) {
                        return projectsController.formatDate(iDate);
                    }
                    
                    onTriggered: {
                        var chosenItem = dataModel.data(indexPath);
                    
                        if(!projects.pageProject)
                            projects.pageProject = projectViewer.createObject();
                            
                        projects.pageProject.name = chosenItem.name;
                        projects.pageProject.description = chosenItem.description;
                        projects.pageProject.content_url = chosenItem.contents_url.substring(0, chosenItem.contents_url.length-8);
                        projects.pageProject.issues_url = chosenItem.issues_url.substring(0, chosenItem.issues_url.length-9); //https://api.github.com/repos/amonchakai/amonchakai.github.io/issues{/number}
                        projects.pageProject.commits_url = chosenItem.commits_url.substring(0, chosenItem.commits_url.length-6); 
                           
                        nav.push(projects.pageProject);
                    
                    }
                    
                    
                    dataModel: GroupDataModel {
                        id: dataModel    
                        grouping: ItemGrouping.None
                        
                        
                        property bool empty: true
                        sortedAscending: false
                        
                        
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
        
        attachedObjects: [
            ProjectsController {
                id: projectsController
                
                onLoaded: {
                    activity.stop();
                }
                
                onFailed: {
                    activity.stop();
                }
            },
            ComponentDefinition {
                id: projectViewer
                source: "ProjectViewer.qml"
            }
        ]
        
        
        onCreationCompleted: {
            projectsController.setListView(projectList);
            projectsController.loadCache();
            
        }
    
    }
}

