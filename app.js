function loadChannels() {
  const channels = [
    { "name": "NASA TV", "stream_url": "https://www.youtube.com/embed/21X5lGlDOfg" }, // Example: NASA TV Live
    { "name": "Sky News Live", "stream_url": "https://www.youtube.com/embed/9Auq9mYxFEE" }, // Example: Sky News Live
    { "name": "Bloomberg Originals", "stream_url": "https://www.youtube.com/embed/dp8PhLsUcFE" } // Example: Bloomberg Originals
  ];

  const channelListDiv = document.getElementById('channel-list');

  if (channelListDiv) {
    channels.forEach(channel => {
      const channelDiv = document.createElement('div');
      channelDiv.innerText = channel.name;
      channelDiv.className = 'channel-item';
      
      // Add event listener to play the channel
      channelDiv.addEventListener('click', () => {
        const videoPlayer = document.getElementById('video-player');
        if (videoPlayer) {
          videoPlayer.src = channel.stream_url;
        } else {
          console.error('Video player iframe not found!');
        }
      });
      
      channelListDiv.appendChild(channelDiv);
    });
  } else {
    console.error('Channel list div not found!');
  }
}

window.onload = loadChannels;
