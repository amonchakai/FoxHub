import bb.cascades 1.3

Page {
    property string url_page
    
    ScrollView {
        WebView {
            id: webview
            settings.textAutosizingEnabled: false
            settings.zoomToFitEnabled: false
            
        }
    }
    
    
    
    onUrl_pageChanged: {
        webview.url = url_page;
        
    }
}
