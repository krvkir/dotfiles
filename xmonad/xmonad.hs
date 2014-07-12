import XMonad
import XMonad.Config.Xfce
import XMonad.Config.Desktop
import XMonad.Actions.WindowGo
import XMonad.Actions.CycleWS
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.EwmhDesktops
import XMonad.Layout.Grid
import XMonad.Layout.Tabbed
import XMonad.Layout.NoBorders
import XMonad.Layout.PerWorkspace
import XMonad.Layout.IM
import XMonad.Layout.Spacing
import XMonad.Layout.Reflect
import XMonad.Layout.StackTile
import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Util.Run(spawnPipe, runInTerm)
import XMonad.Util.Themes
import System.IO
import qualified XMonad.StackSet as W
import Data.List
import Data.Monoid (All (All), mappend)
 
main = xmonad myConfig
 
myConfig = xfceConfig
    { modMask = modm
    , workspaces = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
                   
    , terminal = "urxvt"
    
    -- , editor = "emacs" -- todo: how to add fields to config?
    -- , editor = "emacsclient -c"

    , borderWidth = 1
    , layoutHook = desktopLayoutModifiers $ myLayoutHook
    , manageHook = myManageHook <+> manageHook xfceConfig
    , handleEventHook = fullscreenEventHook `mappend` handleEventHook xfceConfig
    } `additionalKeys` myKeys
 
modm = mod4Mask
 
myTabConfig = (theme kavonLakeTheme)
    { fontName = "xft:Droid Sans:size=7"
    , activeColor = "#839496"
    , inactiveColor = "#fdf6e3" -- "#000000"
    }
 
myLayoutHook = onWorkspace "9:im" pidginLayout
    $ tall ||| Mirror tall ||| myTabbed ||| Grid ||| noBorders Full
    where
        myTabbed = tabbed shrinkText myTabConfig
        tall = Tall nmaster delta ratio
        nmaster = 1
        delta = 0.03
        ratio = 0.5
        pidginLayout = withIM (18/100) (Role "buddy_list") Grid ||| myTabbed
        gridLayout = spacing 8 $ Grid
 
myManageHook = composeAll
    [ className =? "Icedove" --> doShift "8"
    , className =? "Pidgin" --> doShift "9"
    , className =? "Galculator" --> doFloat
    , className =? "Figure" --> doFloat
   -- , className =? "Словарь" --> doFloat
    , isFullscreen --> doFullFloat
    , manageDocks
    ]

-- Idea:
-- 1. hands laying on keyboard in natural position (index fingers on the notches)
-- 2. left cursor group {e,d,s,f} for screen/workspace movement
-- 3. right cursor group {i,k,j,l} for movement on current workspace and resizing
-- Extension of this idea (todo: how? does it make sence?)
--   use only one cursor group
--   if no more windows on the workspace -- switch to next
myKeys =
    [ ((modm .|. shiftMask, xK_z), spawn "i3lock")
    , ((modm, xK_p), toggleWS) -- toggle workspaces back and forth

    -- "arrow keys" in ergoemacs-like mode
    , ((modm, xK_i), windows W.focusUp)   -- next window on screen
    , ((modm, xK_k), windows W.focusDown) -- previous window on screen
    , ((modm .|. shiftMask, xK_i), windows W.swapUp)   -- move window up/forward
    , ((modm .|. shiftMask, xK_k), windows W.swapDown) -- move window down/backward

    , ((modm, xK_j), windows W.focusUp)   -- next window on screen
    , ((modm, xK_l), windows W.focusDown) -- previous window on screen
    , ((modm .|. shiftMask, xK_j), windows W.swapUp)   -- move window up/forward
    , ((modm .|. shiftMask, xK_l), windows W.swapDown) -- move window down/backward

    , ((modm, xK_comma), sendMessage Shrink)  -- shrink active window
    , ((modm, xK_period), sendMessage Expand)  -- expand active window

    -- start programs
    , ((modm, xK_Return), spawn (XMonad.terminal myConfig))  -- terminal (urxvt?)
    , ((modm .|. shiftMask, xK_Return), spawn "emacs")       -- editor (emacs?)
    -- , ((modm .|. shiftMask, xK_Return), spawn (XMonad.editor myConfig)) -- editor (emacs?)
    ]
    ++
    -- Toggle on previous WS when trying to toggle to the current
    [((modm, key), toggleOrView i)
    | (key, i) <- zip [xK_1 .. xK_9] (XMonad.workspaces myConfig)]
    ++
    -- Switch screens
    -- (more: http://xmonad.org/xmonad-docs/xmonad-contrib/XMonad-Actions-CycleWS.html#1)
    -- mod-{e,d}, Switch to previous/next Xinerama screen
    -- mod-shift-{e,d}, Move client to previous/next Xinerama screen
    --
    [((m .|. modm, key), sc >>= screenWorkspace >>= flip whenJust (windows . f))
    | (key, sc) <- zip [xK_e, xK_d] [(screenBy (-1)),(screenBy 1)]
    , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]
    ++
    -- Toggle between workspaces: 
    -- mod-{s,f}, Prev/Next
    [((modm, key), fun)
    | (key, fun) <- zip [xK_s, xK_f] [prevWS, nextWS]]
