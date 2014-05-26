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
    , inactiveColor = "#000000"
    }
 
myLayoutHook = onWorkspace "9:im" pidginLayout
    $ tall ||| Mirror tall ||| myTabbed ||| Grid ||| Full
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
    , isFullscreen --> doFullFloat
    , manageDocks
    ]
    
myKeys =
    [ ((modm .|. controlMask, xK_w), spawn "exo-open --launch WebBrowser")
    , ((modm .|. controlMask, xK_m), spawn "exo-open --launch MailReader")
    , ((modm .|. controlMask, xK_f), spawn "exo-open --launch FileManager")
    , ((modm .|. controlMask, xK_p), spawn "pidgin")
    , ((modm .|. shiftMask, xK_z), spawn "i3lock")
    , ((modm, xK_j), windows W.focusUp)
    , ((modm, xK_k), windows W.focusDown)
    , ((modm .|. shiftMask, xK_j), windows W.swapUp)
    , ((modm .|. shiftMask, xK_k), windows W.swapDown)

    , ((modm, xK_p), toggleWS)
    ]
    ++
    -- Toggle on previous WS when trying to toggle to the current
    [((modm, k), toggleOrView i)
    | (i, k) <- zip (XMonad.workspaces myConfig) [xK_1 .. xK_9]]
