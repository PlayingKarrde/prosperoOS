# prosperoOS v0.1

![prosperoOS Pegasus theme](https://i.imgur.com/4cPZLoo.png)
![prosperoOS Pegasus theme](https://i.imgur.com/AlDRo9l.png)
![prosperoOS Pegasus theme](https://i.imgur.com/PiZGhgi.png)
![prosperoOS Pegasus theme](https://i.imgur.com/0YDTuzG.png)

## prosperoOS theme for Pegasus Frontend

A [Pegasus Frontend](http://pegasus-frontend.org/) theme based on the Playstation 5 interface. It features a clean navigation with smart playlists to help you discover more from your collection.

## Installation

[Download the latest version](https://github.com/PlayingKarrde/prosperoOS/releases/latest) and extract it in your [Pegasus theme directory](http://pegasus-frontend.org/docs/user-guide/installing-themes/) under a folder called prosperoOS.

IMPORTANT: You need to have the latest version of Pegasus installed (not the current Stable release) otherwise you will get an error regarding Qt.Modules.

## Navigation

- Cycle active collection: Previous/Next Page buttons
- Favorite toggle: Filters button

## Metadata

It is recommended to use [Skraper.net](http://www.skraper.net/) to acquire media assets for this theme. These are the minimum requirements for media scraping, although adding more could be useful for other themes or the future:

- video
- screenshot
- fanart
- box 2d
- wheel

Skraper will place these in your roms folder under another folder called media.

If no media files are showing up, make sure that Skraper Assets is checked in the Additional Data Sources section of Pegasus settings. It may also be preferable to convert the created gamelist.xml (assuming EmulationStation was chosen for the game list in Skraper) to a metadata.txt file using the [Pegasus conversion tool](http://pegasus-frontend.org/tools/convert/)

## Planned updates
- Add search function
- Add video support for thumbnails
- Add details screen for all games
- Add full media support (video and screenshots)
- More indepth playlists within the Explore tab
- Improved visuals to better match the Playstation 5 user experience

## Version history
v0.1
- Initial release