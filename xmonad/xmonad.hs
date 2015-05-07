import XMonad

import XMonad.Config.Xfce
import XMonad.Config.Desktop

import XMonad.Actions.WindowGo
import XMonad.Actions.CycleWS

import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.SetWMName
import XMonad.Hooks.DebugKeyEvents

import XMonad.Layout.Grid
import XMonad.Layout.Tabbed
import XMonad.Layout.NoBorders
import XMonad.Layout.PerWorkspace
import XMonad.Layout.IM
import XMonad.Layout.Spacing
import XMonad.Layout.Reflect
import XMonad.Layout.StackTile
import XMonad.Layout.ShowWName

import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Util.Run(spawnPipe, runInTerm)
import XMonad.Util.Themes

import System.IO
import qualified XMonad.StackSet as W
import Data.List
import Data.Monoid (All (All), mappend)

-- for extrenal control
import XMonad.Hooks.ServerMode
import XMonad.Actions.Commands

-- main = xmonad myConfig { handleEventHook = serverModeEventHook <+> debugKeyEvents }
main = xmonad myConfig

myConfig = xfceConfig
    { modMask = modm
    , workspaces = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
                   
    , terminal = "urxvt"
    
    -- , editor = "emacs" -- todo: how to add fields to config?
    -- , editor = "emacsclient -c"

    , borderWidth = 3
                    
    , normalBorderColor = "#0F5A32"
    -- , focusedBorderColor = "#551300"
    , focusedBorderColor = "#802D15"
                           
    -- , layoutHook = desktopLayoutModifiers $ myShowWName myLayoutHook
    , layoutHook = desktopLayoutModifiers $ myLayoutHook
    , manageHook = myManageHook <+> manageHook xfceConfig
    , handleEventHook = fullscreenEventHook `mappend` handleEventHook xfceConfig 
                        
    -- fixes java gui issues but possibly breaks gtk3 one 
    -- , startupHook = setWMName "LG3D" 
    } `additionalKeys` myKeys
 
modm = mod4Mask

mySWNConfig = defaultSWNConfig {
  swn_font = "xft:Droid Sans:size=96",
  swn_fade = 1
             
  }

myShowWName = showWName' mySWNConfig
            
myTabConfig = defaultTheme -- (theme kavonLakeTheme)
    { fontName = "xft:Droid Sans:size=7"

    , activeColor = "#551300"
    , activeTextColor = "#FFBDAA"
                        
    , inactiveColor = "#78B494"
    , inactiveTextColor = "#552F00"
                          
    -- , activeBorderColor = "#551300"
    , activeBorderColor = "#802D15"

    , inactiveBorderColor = "#0F5A32"

    -- , windowTitleIcons = []
    -- , windowTitleIcons = []
    }

myLayoutHook = onWorkspace "9:im" pidginLayout
    -- $ myTabbed ||| tall ||| Mirror tall ||| Grid ||| noBorders Full
    $ myTabbed ||| tall ||| noBorders Full
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
-- 2. left hand: {d,f} switches windows, {e,r} switches workspaces, {s} toggles workspaces
-- 3. right cursor group {i,k,j,l} for movement on current workspace and resizing
-- Extension of this idea (todo: how? does it make sence?)
--   use only one cursor group
--   if no more windows on the workspace -- switch to next
myKeys =
    [ ((modm .|. shiftMask, xK_z), spawn "i3lock -c 000000")
    -- , ((modm, xK_p), toggleWS) -- toggle s back and forth
    -- , ((modm, xK_a), toggleWS) -- toggle workspace back and forth (single hand)
    , ((modm, xK_s), toggleWS) -- toggle workspace back and forth (single hand)

    -- "arrow keys" in ergoemacs-like mode
    -- Right hand side (ijkl)
    -- , ((modm, xK_j), windows W.focusUp)   -- next window on screen
    -- , ((modm, xK_l), windows W.focusDown) -- previous window on screen
    -- , ((modm .|. shiftMask, xK_j), windows W.swapUp)   -- move window up/forward
    -- , ((modm .|. shiftMask, xK_l), windows W.swapDown) -- move window down/backward

    -- , ((modm, xK_comma), prevWS) -- next workspace
    -- , ((modm, xK_period), nextWS) -- previous workspace
    -- , ((modm .|. shiftMask, xK_i), windows W.swapUp)   -- move window to next workspace
    -- , ((modm .|. shiftMask, xK_k), windows W.swapDown) -- move window to previous workspace

    -- Left hand side (esdf)
    , ((modm, xK_d), windows W.focusUp)   -- previous window on screen
    , ((modm, xK_f), windows W.focusDown) -- next window on screen
    , ((modm .|. shiftMask, xK_d), windows W.swapUp)   -- move window up/forward
    , ((modm .|. shiftMask, xK_f), windows W.swapDown) -- move window down/backward
    , ((modm, xK_e), prevWS) -- next workspace
    , ((modm, xK_r), nextWS) -- previous workspace

    -- 
    , ((modm, xK_minus), sendMessage Shrink)  -- shrink active window
    , ((modm, xK_equal), sendMessage Expand)  -- expand active window

    -- start programs
    , ((modm, xK_Return), spawn (XMonad.terminal myConfig))  -- terminal (urxvt?)
    , ((modm .|. shiftMask, xK_Return), spawn "emacsclient -c")       -- editor (emacs?)
    -- , ((modm .|. shiftMask, xK_Return), spawn (XMonad.editor myConfig)) -- editor (emacs?)
    ]
    ++
    -- Toggle on previous WS when trying to toggle to the current
    [((modm, key), toggleOrView i)
    | (key, i) <- zip [xK_1 .. xK_0] (XMonad.workspaces myConfig)]
    ++
    -- Switch screens
    -- (more: http://xmonad.org/xmonad-docs/xmonad-contrib/XMonad-Actions-CycleWS.html#1)
    -- mod-{e,d}, Switch to previous/next Xinerama screen
    -- mod-shift-{'{','}'}, Move client to previous/next Xinerama screen
    --
    -- [((m .|. modm, key), sc >>= screenWorkspace >>= flip whenJust (windows . f))
    -- | (key, sc) <- zip [xK_c, xK_v] [(screenBy (-1)),(screenBy 1)]
    -- , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]
    [((m .|. modm, key), sc >>= screenWorkspace >>= flip whenJust (windows . f))
    | (key, sc) <- zip [xK_v] [(screenBy 1)]
    , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]
    -- ++
    -- -- Toggle between workspaces: 
    -- -- mod-{e,d}, Prev/Next
    -- [((modm, key), fun)
    -- | (key, fun) <- zip [xK_e, xK_d] [prevWS, nextWS]]
