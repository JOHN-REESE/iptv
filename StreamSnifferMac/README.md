# StreamSnifferMac

## Description

StreamSnifferMac is a macOS application with a graphical user interface (GUI) that attempts to detect and display live video stream URLs (such as HLS .m3u8 or DASH .mpd manifests) from websites loaded in its built-in WebView.

## Features

*   Loads web pages in an embedded WebView.
*   Monitors network requests, including main page navigation and JavaScript-initiated requests (Fetch, XHR), to find potential stream URLs.
*   Displays detected stream URLs in a clear, scrollable list.
*   Provides basic URL input validation and error feedback.
*   Includes a status label for real-time user feedback on application actions and page loading status.
*   Allows clearing the list of detected URLs.

## How to Build

1.  **Prerequisites:**
    *   A Mac computer running macOS.
    *   Xcode 13 (or later) installed. Xcode can be downloaded from the Mac App Store.

2.  **Building the Application:**
    *   Open the `StreamSnifferMac.xcodeproj` file (or the relevant project file if named differently) in Xcode.
    *   Select a valid macOS target (e.g., "My Mac").
    *   Click the "Build and then run the current scheme" button (looks like a Play icon) in the Xcode toolbar, or select Product > Run from the menu.
    *   Xcode will compile the application, and it should launch automatically on your macOS system.

## How to Use

1.  **Launch the Application:** Open StreamSnifferMac.
2.  **Enter URL:** Type or paste the full URL of the website you want to inspect into the URL input field at the top of the application window.
3.  **Load Page:** Click the "Go" button or press the Enter key.
4.  **Observe Detection:**
    *   The web page will load in the WebView section.
    *   As the page loads and interacts, any detected potential stream URLs will appear in the list below the WebView. This can include URLs found during page navigation or through background network requests made by the page's JavaScript.
5.  **Clear List:** Use the "Clear List" button at the bottom-right to remove all URLs from the detected streams list.
6.  **Status Updates:** Pay attention to the status label at the bottom-left for feedback on URL loading, errors, and detection events.

## Limitations & Disclaimer

*   **Effectiveness Varies:** StreamSnifferMac may not work on all websites. The success of stream detection heavily depends on common URL patterns and the ability to intercept JavaScript-initiated requests. Websites can use various techniques to change, hide, or obfuscate these URLs, which may prevent detection.
*   **DRM Protected Streams:** This application **cannot** access, decrypt, or play streams protected by Digital Rights Management (DRM) technologies (e.g., Widevine, FairPlay). It only identifies potential URLs.
*   **Dynamic/Tokenized URLs:** Some detected URLs might be temporary, session-specific, or include tokens that expire quickly. These URLs may not be usable for long periods or outside the original browsing context.
*   **JavaScript Complexity:** Websites with highly obfuscated JavaScript or complex custom video player logic might evade detection by the current interception methods.
*   **No Playback Functionality:** StreamSnifferMac is a tool for URL detection and logging only. It does not include any functionality to play the detected video or audio streams.
*   **Resource Intensive:** Intercepting and logging network requests, especially on very complex or media-heavy web pages, can be resource-intensive and may impact application performance on older hardware.

## Ethical Considerations

*   **Responsible Use:** Use this tool responsibly and always respect the terms of service of any website you are inspecting.
*   **Copyright and Intellectual Property:** Do not use this tool for any activity that infringes on copyright, intellectual property rights, or any other applicable laws and regulations. Accessing or distributing content without proper authorization is illegal in many jurisdictions.
*   **No Misuse:** The developers of StreamSnifferMac are not responsible for any misuse of this tool or for any actions taken by users of this tool. This tool is provided for educational and analytical purposes only.

Use StreamSnifferMac at your own risk and discretion.
