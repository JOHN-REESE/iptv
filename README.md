# Simple Live TV App

## Description

This is a basic web application that allows users to watch live TV streams. It uses a predefined list of channels, which are embedded via their YouTube stream URLs. Users can click on a channel name from the list to load the corresponding video stream in an iframe player.

## How to Run

1.  Ensure all files (`index.html`, `app.js`, `style.css`) are in the same directory.
2.  Open the `index.html` file in your preferred web browser (e.g., Chrome, Firefox, Safari, Edge).

## Customizing Channels

The list of TV channels is currently hardcoded in the `app.js` file. You can customize the channels by editing this file.

1.  **Open `app.js`:** Use any text editor to open the `app.js` file.
2.  **Locate the `channels` array:** Near the beginning of the `loadChannels` function, you will find an array named `channels`. It looks like this:

    ```javascript
    const channels = [
      { "name": "Channel Name 1", "stream_url": "https://www.youtube.com/embed/your_video_id_1" },
      { "name": "Channel Name 2", "stream_url": "https://www.youtube.com/embed/your_video_id_2" },
      // Add more channels here
    ];
    ```

3.  **Edit the array:**
    *   **To add a new channel:** Add a new JavaScript object to the array, following the structure:
        `{ "name": "Your Channel Name", "stream_url": "your_youtube_embed_url" }`
    *   **To modify an existing channel:** Change the `name` or `stream_url` for any of the existing objects.
    *   **To remove a channel:** Delete the entire object for that channel from the array.

    **Channel Object Structure:**
    Each channel is represented by an object with two properties:
    *   `name` (String): The display name of the channel in the list.
    *   `stream_url` (String): The URL for the live stream. This should typically be a YouTube embed URL (e.g., `https://www.youtube.com/embed/VIDEO_ID`).

4.  **Save `app.js`:** After making your changes, save the file.
5.  **Reload `index.html`:** Refresh or reopen `index.html` in your browser to see the updated channel list.

**Note:** Ensure the `stream_url` is a valid embeddable URL for the iframe to work correctly. Most YouTube live streams offer an embed option.
