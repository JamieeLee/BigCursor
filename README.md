# BigCursor

A standalone resizable cursor addon for the original **Azeroth
Survivors** by Aethus.

BigCursor enlarges the game's cursor to make it easier to see during
gameplay. It is designed for the original Windows version of Azeroth
Survivors, which uses a legacy WoW-style addon API.

## Features

-   Resize the cursor from the in-game chat.
-   Supports cursor sizes up to **512 pixels**.
-   Uses the game's cursor artwork.
-   Restores native cursor behavior when the enlarged cursor is not
    active, such as when the game needs its normal cursor for menus.
-   Standalone addon; it does not require Survivor UI.

## Installation

1.  Close Azeroth Survivors.
2.  Extract the `BigCursor` folder from the ZIP.
3.  Copy the folder into the game's `Interface/AddOns/` directory.
4.  Launch the game and enable **BigCursor** in the AddOns list if
    needed.
5.  Start or enter a run and use the chat command below.

The installed folder should contain `BigCursor.toc`, `BigCursor.lua`,
and the `Art` folder. Make sure the files are not nested inside an extra
`BigCursor` folder.

## Usage

Enter this command in the in-game chat:

``` text
/bigcursor size 128
```

Replace `128` with the size you want. For example:

``` text
/bigcursor size 64
/bigcursor size 96
/bigcursor size 128
/bigcursor size 256
/bigcursor size 512
```

The largest supported setting in the current build is **512 pixels**.

## Compatibility

-   **Target:** Original Windows release of Azeroth Survivors by Aethus.
-   **Current build:** 0.3.4.
-   This addon is not specifically built for Azeroth Survivors-RE or
    other forks.

## Troubleshooting

-   **The cursor is invisible:** Confirm BigCursor is enabled and that
    the `BigCursor` folder is installed directly inside
    `Interface/AddOns/`.
-   **The size does not change:** Run `/bigcursor size 512` in the
    game's chat and check the chat output for the size confirmation.
-   **A menu uses the normal cursor:** This can be expected when the
    game needs its native cursor for menu interaction.

## Development

BigCursor is an independent addon. Survivor UI's cursor implementation
was used as a reference during development, but BigCursor is intended to
work without requiring Survivor UI.

## Disclaimer

This is a community-made addon and is not affiliated with or endorsed by
Aethus. Use at your own discretion.
