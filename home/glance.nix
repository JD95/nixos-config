{ ... }:

let 
  politicsFeeds = [
    # Adam Mockler
    { url = "https://www.youtube.com/feeds/videos.xml?channel_id=UC8DA4o0SyaGfyVaBLbF5EXg"; }
    # Hasan
    { url = "https://www.youtube.com/feeds/videos.xml?channel_id=UCtoaZpBnrd0lhycxYJ4MNOQ"; }
    # Vaush
    { url = "https://www.youtube.com/feeds/videos.xml?channel_id=UC1E-JS8L0j1Ei70D9VEFrPQ"; }
    # The Rational National
    { url = "https://www.youtube.com/feeds/videos.xml?channel_id=UCo9oQdIk1MfcnzypG3UnURA"; }
  ];
in {
  services.glance = {
    enable = true;
    settings = {
      server = { port = 8081; };
      pages = [{
        name = "Home";
        columns = [{
          size = "full";
          widgets = [
            {
              type = "rss";
              title = "News";
              feeds = [{ url = "https://www.reddit.com/r/news.rss"; }];
            }
            {
              type = "rss";
              title = "Politics";
              feeds = politicsFeeds;
            }
          ];
        }];
      }];
    };
  };
}
