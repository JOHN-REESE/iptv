import Cocoa
import WebKit

// Conform to WKScriptMessageHandler, NSTableViewDataSource, NSTableViewDelegate
class ViewController: NSViewController, WKNavigationDelegate, WKScriptMessageHandler, NSTableViewDataSource, NSTableViewDelegate {

    var webView: WKWebView!
    var urlTextField: NSTextField!
    var goButton: NSButton!
    
    // UI for displaying detected streams
    var streamsScrollView: NSScrollView!
    var streamsTableView: NSTableView!
    var clearButton: NSButton!
    var statusLabel: NSTextField! // Status Label
    
    // Data store for detected URLs
    private var detectedStreamUrls: [String] = []

    // Define stream URL patterns
    private let streamUrlPatterns: [String] = [
        ".m3u8",
        ".mpd",
        "manifest",
        ".ts", // Might be too noisy, but included for now
        "googlevideo.com/videoplayback",
        ".mp4", // Common video file
        ".mkv",
        ".webm"
    ]

    override func loadView() {
        // Create a main view for the ViewController
        self.view = NSView(frame: NSRect(x: 0, y: 0, width: 800, height: 600))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure URL TextField
        urlTextField = NSTextField()
        urlTextField.placeholderString = "Enter URL here"
        urlTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(urlTextField)

        // Configure Go Button
        goButton = NSButton(title: "Go", target: self, action: #selector(goButtonClicked))
        goButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(goButton)

        // Configure WKWebView
        let webConfiguration = WKWebViewConfiguration()
        
        // JavaScript for intercepting network requests
        let jsScript = """
        (function() {
            const originalFetch = window.fetch;
            window.fetch = function() {
                let url = arguments[0] instanceof Request ? arguments[0].url : arguments[0];
                window.webkit.messageHandlers.networkInterceptor.postMessage("Fetch request to: " + url);
                return originalFetch.apply(this, arguments);
            };

            const originalXHROpen = XMLHttpRequest.prototype.open;
            XMLHttpRequest.prototype.open = function(method, url) {
                this._method = method;
                this._url = url;
                // Log arguments to ensure they are captured
                // window.webkit.messageHandlers.networkInterceptor.postMessage("XHR open called with method: " + method + ", URL: " + url);
                return originalXHROpen.apply(this, arguments);
            };

            const originalXHRSend = XMLHttpRequest.prototype.send;
            XMLHttpRequest.prototype.send = function() {
                // Check if _url was actually set (it might not be if open was not called or overridden differently)
                if (this._url) {
                    window.webkit.messageHandlers.networkInterceptor.postMessage("XHR " + (this._method || "N/A") + " request to: " + this._url);
                } else {
                    // Fallback or log if URL is not available at send time
                    // window.webkit.messageHandlers.networkInterceptor.postMessage("XHR send called, but URL not captured on this._url");
                }
                return originalXHRSend.apply(this, arguments);
            };
            window.webkit.messageHandlers.networkInterceptor.postMessage("Global network interceptor script loaded.");
        })();
        """
        
        let userScript = WKUserScript(source: jsScript, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        
        let userContentController = WKUserContentController()
        userContentController.addUserScript(userScript)
        userContentController.add(self, name: "networkInterceptor") // Add script message handler
        
        webConfiguration.userContentController = userContentController
        
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)

        // Layout constraints
        NSLayoutConstraint.activate([
            // URL TextField constraints
            urlTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            urlTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            urlTextField.trailingAnchor.constraint(equalTo: goButton.leadingAnchor, constant: -10),
            
            // Go Button constraints
            goButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            goButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            goButton.widthAnchor.constraint(equalToConstant: 50),
            goButton.centerYAnchor.constraint(equalTo: urlTextField.centerYAnchor),

            // WKWebView constraints
            webView.topAnchor.constraint(equalTo: urlTextField.bottomAnchor, constant: 20),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // Adjust webView bottom to make space for the table view and clear button
            webView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6) // WebView takes 60% of height
        ])

        // Configure Streams TableView
        streamsScrollView = NSScrollView()
        streamsScrollView.translatesAutoresizingMaskIntoConstraints = false
        streamsScrollView.hasVerticalScroller = true
        streamsScrollView.borderType = .bezelBorder
        
        streamsTableView = NSTableView()
        streamsTableView.translatesAutoresizingMaskIntoConstraints = false
        streamsTableView.headerView = nil // No header
        streamsTableView.dataSource = self
        streamsTableView.delegate = self
        
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("URLColumn"))
        column.title = "Detected Stream URLs" // Title for tooltip or future use, not visible for headerView = nil
        column.width = view.frame.width - 40 // Initial width, can be adjusted
        streamsTableView.addTableColumn(column)
        
        streamsScrollView.documentView = streamsTableView
        view.addSubview(streamsScrollView)
        
        // Configure Clear Button
        clearButton = NSButton(title: "Clear List", target: self, action: #selector(clearStreamsList))
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(clearButton)
        
        // Configure Status Label
        statusLabel = NSTextField(labelWithString: "Status: Idle") // Using labelWithString for non-editable text
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.isEditable = false
        statusLabel.isBordered = false
        statusLabel.backgroundColor = .clear
        statusLabel.textColor = .secondaryLabelColor
        view.addSubview(statusLabel)

        // Layout for streamsScrollView, clearButton, and statusLabel
        NSLayoutConstraint.activate([
            streamsScrollView.topAnchor.constraint(equalTo: webView.bottomAnchor, constant: 10),
            streamsScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            streamsScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            streamsScrollView.bottomAnchor.constraint(equalTo: clearButton.topAnchor, constant: -10), // Or statusLabel.topAnchor
            
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(lessThanOrEqualTo: clearButton.leadingAnchor, constant: -10),
            statusLabel.centerYAnchor.constraint(equalTo: clearButton.centerYAnchor),
            
            clearButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            clearButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            clearButton.heightAnchor.constraint(equalToConstant: 30) // Standard button height
        ])

        // Load a default page
        let defaultURLString = "https://www.apple.com"
        urlTextField.stringValue = defaultURLString
        if let url = URL(string: defaultURLString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }

    @objc func goButtonClicked() {
        guard let urlString = urlTextField?.stringValue, !urlString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("URL string is empty.")
            DispatchQueue.main.async {
                self.statusLabel.stringValue = "Status: Please enter a URL."
            }
            return
        }

        guard let url = URL(string: urlString) else {
            print("Invalid URL format: \(urlString)")
            DispatchQueue.main.async {
                self.statusLabel.stringValue = "Status: Invalid URL format."
            }
            return
        }
        
        // Check for valid scheme (optional, but good for web context)
        if url.scheme != "http" && url.scheme != "https" {
            print("Invalid URL scheme: \(url.scheme ?? "nil") for URL: \(urlString)")
            DispatchQueue.main.async {
                self.statusLabel.stringValue = "Status: Invalid URL scheme. Must be http or https."
            }
            return
        }
        
        DispatchQueue.main.async {
            self.statusLabel.stringValue = "Status: Loading \(urlString)..."
        }
        let request = URLRequest(url: url)
        webView.load(request)
    }

    // MARK: - WKNavigationDelegate

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let urlString = navigationAction.request.url?.absoluteString
        if let urlStr = urlString {
            print("Navigating to (WKNavigationDelegate): \(urlStr)")
            processPotentialStreamUrl(urlString: urlStr) // Process for streams
        } else {
            print("Navigating to (WKNavigationDelegate): No URL")
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let errorMessage = "Status: Error loading page: \(error.localizedDescription)"
        print("Failed provisional navigation (WKNavigationDelegate): \(error.localizedDescription)")
        DispatchQueue.main.async {
            self.statusLabel.stringValue = errorMessage
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        let errorMessage = "Status: Error loading page: \(error.localizedDescription)"
        print("Failed navigation (WKNavigationDelegate): \(error.localizedDescription)")
        DispatchQueue.main.async {
            self.statusLabel.stringValue = errorMessage
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Called when navigation is complete
        print("Page loaded successfully (WKNavigationDelegate): \(webView.url?.absoluteString ?? "No URL")")
        DispatchQueue.main.async {
            self.statusLabel.stringValue = "Status: Page loaded. Sniffing for streams..."
        }
    }
    
    // MARK: - WKScriptMessageHandler
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "networkInterceptor" {
            if let messageBody = message.body as? String {
                print("JS Message Handler (\(message.name)): \(messageBody)")
                
                // Attempt to extract URL from messageBody
                // Example message formats:
                // "Fetch request to: http://example.com/stream.m3u8"
                // "XHR GET request to: http://example.com/manifest.mpd"
                // "Global network interceptor script loaded."
                
                var detectedUrl: String? = nil
                
                if messageBody.starts(with: "Fetch request to: ") {
                    detectedUrl = String(messageBody.dropFirst("Fetch request to: ".count))
                } else if messageBody.contains(" request to: ") { // For XHR
                    if let range = messageBody.range(of: " request to: ") {
                        detectedUrl = String(messageBody[range.upperBound...])
                    }
                }
                // If a URL was extracted, process it
                if let finalUrl = detectedUrl {
                    processPotentialStreamUrl(urlString: finalUrl)
                }

            } else {
                print("JS Message Handler (\(message.name)): Received non-string message body: \(message.body)")
            }
        }
    }
    
    // MARK: - Stream Detection Logic
    
    private func processPotentialStreamUrl(urlString: String?) {
        guard let url = urlString, !url.isEmpty else {
            return
        }
        
        let lowercasedUrl = url.lowercased()
        var foundMatch = false
        for pattern in streamUrlPatterns {
            if lowercasedUrl.contains(pattern.lowercased()) {
                foundMatch = true
                break
            }
        }
        
        if foundMatch {
            // Ensure thread safety for UI updates and array modification
            DispatchQueue.main.async {
                // Case-insensitive check for uniqueness before adding
                if !self.detectedStreamUrls.contains(where: { $0.caseInsensitiveCompare(url) == .orderedSame }) {
                    self.detectedStreamUrls.append(url)
                    print("[STREAM CANDIDATE ADDED]: \(url)")
                    self.statusLabel.stringValue = "Status: Stream candidate added."
                    self.refreshStreamUrlsDisplay()
                } else {
                    // print("[STREAM CANDIDATE DUPLICATE (case-insensitive) - NOT ADDED]: \(url)")
                    self.statusLabel.stringValue = "Status: Duplicate stream detected (not added)."
                }
            }
        }
    }
    
    @objc private func clearStreamsList() {
        DispatchQueue.main.async {
            self.detectedStreamUrls.removeAll()
            self.refreshStreamUrlsDisplay()
            self.statusLabel.stringValue = "Status: List cleared."
            print("Detected streams list cleared.")
        }
    }
    
    private func refreshStreamUrlsDisplay() {
        // Ensure this is called on the main thread as it updates UI
        DispatchQueue.main.async {
            self.streamsTableView.reloadData()
        }
    }
    
    // MARK: - NSTableViewDataSource
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return detectedStreamUrls.count
    }
    
    // MARK: - NSTableViewDelegate
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard row < detectedStreamUrls.count else {
            return nil
        }
        
        let urlString = detectedStreamUrls[row]
        
        let identifier = NSUserInterfaceItemIdentifier("URLCell")
        var cellView = tableView.makeView(withIdentifier: identifier, owner: nil) as? NSTableCellView
        
        if cellView == nil {
            cellView = NSTableCellView()
            cellView?.identifier = identifier
            
            let textField = NSTextField()
            textField.isEditable = false
            textField.isBordered = false
            textField.drawsBackground = false
            textField.lineBreakMode = .byTruncatingTail
            textField.translatesAutoresizingMaskIntoConstraints = false
            cellView?.textField = textField // Keep reference
            cellView?.addSubview(textField)
            
            // Constraints for the text field within the cell
            NSLayoutConstraint.activate([
                textField.leadingAnchor.constraint(equalTo: cellView!.leadingAnchor, constant: 4),
                textField.trailingAnchor.constraint(equalTo: cellView!.trailingAnchor, constant: -4),
                textField.centerYAnchor.constraint(equalTo: cellView!.centerYAnchor)
            ])
        }
        
        cellView?.textField?.stringValue = urlString
        return cellView
    }
}
