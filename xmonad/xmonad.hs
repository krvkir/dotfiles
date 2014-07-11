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
    
myKeys =
    [ ((modm .|. controlMask, xK_p), spawn "pidgin")
    , ((modm .|. shiftMask, xK_z), spawn "i3lock")
    , ((modm, xK_j), windows W.focusUp)
    , ((modm, xK_k), windows W.focusDown)
    , ((modm .|. shiftMask, xK_j), windows W.swapUp)
    , ((modm .|. shiftMask, xK_k), windows W.swapDown)

    , ((modm, xK_p), toggleWS) -- toggle workspaces back and forth

    -- "arrow keys" in ergoemacs-like mode
    , ((modm, xK_i), windows W.focusUp)
    , ((modm, xK_k), windows W.focusDown)
    , ((modm, xK_period), nextWS)
    , ((modm, xK_comma),  prevWS)

    -- start emacs client
    -- , ((modm, xK_Return), spawn "emacsclient -c")
    , ((modm, xK_Return), spawn "urxvt")
    , ((modm .|. shiftMask, xK_Return), spawn "emacs")
    ]
    ++
    -- Toggle on previous WS when trying to toggle to the current
    [((modm, k), toggleOrView i)
    | (i, k) <- zip (XMonad.workspaces myConfig) [xK_1 .. xK_9]]
