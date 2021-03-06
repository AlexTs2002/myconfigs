import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.PerWindowKbdLayout
import XMonad.Util.Run (spawnPipe)
import System.IO

import XMonad.Actions.Warp
import XMonad.Actions.CopyWindow
import XMonad.Actions.UpdatePointer
import XMonad.Actions.FlexibleResize
import qualified XMonad.Actions.FloatSnap as FS
import XMonad.Actions.DeManage
import XMonad.Actions.MouseResize

import XMonad.Layout.NoBorders
import XMonad.Layout.Fullscreen
import XMonad.Layout.GridVariants as GV
import XMonad.Layout.MultiColumns
import XMonad.Layout.TrackFloating
import XMonad.Layout.LayoutScreens

import qualified Data.Map as M
import qualified XMonad.StackSet as W

import XMonad.Layout.WindowArranger

mulcol = multiCol [1] 3 0.01 0.5
layout = mulcol ||| trackFloating Full

myKeys :: XConfig Layout -> M.Map (KeyMask, KeySym) (X ())
myKeys conf@(XConfig {XMonad.modMask = mm}) = M.fromList $
	[ ((mm, xK_q), kill)
	, ((mm .|. shiftMask, xK_q), kill1)
	, ((mm .|. controlMask, xK_q), kill1)

	, ((mm, xK_w), spawn $ XMonad.terminal conf)
	, ((mm, xK_e), spawn "nautilus")
	, ((mm, xK_r), spawn "gmrun")
	, ((mm .|. shiftMask, xK_r), spawn "gnome-do")

	, ((mm, xK_a), sendMessage NextLayout)
	, ((mm, xK_s), sendMessage FirstLayout)
	, ((mm .|. shiftMask, xK_s), setLayout $ XMonad.layoutHook conf)
	, ((mm, xK_d), warpToWindow 0.5 0.5)
	, ((mm .|. shiftMask, xK_d), warpToScreen 0 0.5 0.5)
	, ((mm .|. controlMask, xK_d), warpToScreen 1 0.5 0.5)
	, ((mm, xK_f), sendMessage ToggleStruts)

	, ((mm, xK_z), spawn "transset --actual --dec .05")
	, ((mm .|. shiftMask, xK_z), spawn "transset --actual 0")
	, ((mm, xK_x), spawn "transset --actual --inc .05")
	, ((mm .|. shiftMask, xK_x), spawn "transset --actual 1")
	, ((mm, xK_c), spawn "pavucontrol")
	, ((mm .|. shiftMask, xK_c), spawn "gnome-calculator")

	, ((mm, xK_F1), spawn "xscreensaver-command --lock")
	, ((mm .|. shiftMask, xK_F1), spawn "xscreensaver -nosplash")
	, ((mm .|. controlMask, xK_F1), spawn "killall xscreensaver")
--	, ((mm, xK_F2), spawn "killall -9 skype")
--	, ((mm, xK_F2), withFocused demanage)
	, ((mm, xK_F3), spawn "xmonad --restart")
	, ((mm, xK_F4), spawn "xmonad --recompile && xmonad --restart")
	, ((mm, xK_F5), refresh)
	, ((mm, xK_F6), spawn "killall gnome-settings-daemon; exec /usr/libexec/gnome-settings-daemon")
	, ((mm, xK_F7), spawn "sleep 0.5; xdotool key XF86TouchpadToggle")
	, ((mm, xK_F8), spawn "sleep 0.1; xset dpms force off")
	, ((mm, xK_F9), spawn "systemctl suspend -i")
	, ((mm, xK_F10), spawn "systemctl hibernate -i")
	, ((mm, xK_F11), spawn "systemctl reboot -i")
	, ((mm, xK_F12), spawn "systemctl poweroff -i")

	, ((mm, xK_k), windows W.focusUp)
	, ((mm, xK_j), windows W.focusDown)
	, ((mm, xK_m), windows W.focusMaster)
	, ((mm .|. shiftMask, xK_k), windows W.swapUp)
	, ((mm .|. shiftMask, xK_j), windows W.swapDown)
	, ((mm .|. shiftMask, xK_m), windows W.swapMaster)
	, ((mm, xK_space), windows W.shiftMaster)
	, ((mm, xK_h), sendMessage Shrink)
	, ((mm, xK_l), sendMessage Expand)
	, ((mm, xK_comma), sendMessage $ IncMasterN 1)
	, ((mm, xK_period), sendMessage $ IncMasterN (-1))
	, ((mm, xK_Tab), withFocused $ windows . W.sink)

	, ((mm, xK_slash), layoutSplitScreen 1 $ fixedLayout [Rectangle 0 0 1280 1024])
	, ((mm .|. shiftMask, xK_slash), rescreen)

	, ((controlMask .|. mod1Mask, xK_w), spawn "xdotool keydown Super")
	, ((mm, xK_v), spawn "xdotool keyup Super")

	, ((mm .|. controlMask              , xK_s    ), sendMessage  Arrange         )
	, ((mm .|. controlMask .|. shiftMask, xK_s    ), sendMessage  DeArrange       )
	, ((mm .|. controlMask              , xK_Left ), sendMessage (MoveLeft      10))
	, ((mm .|. controlMask              , xK_Right), sendMessage (MoveRight     10))
	, ((mm .|. controlMask              , xK_Down ), sendMessage (MoveDown      10))
	, ((mm .|. controlMask              , xK_Up   ), sendMessage (MoveUp        10))
	, ((mm                 .|. shiftMask, xK_Left ), sendMessage (IncreaseLeft  10))
	, ((mm                 .|. shiftMask, xK_Right), sendMessage (IncreaseRight 10))
	, ((mm                 .|. shiftMask, xK_Down ), sendMessage (IncreaseDown  10))
	, ((mm                 .|. shiftMask, xK_Up   ), sendMessage (IncreaseUp    10))
	, ((mm .|. controlMask .|. shiftMask, xK_Left ), sendMessage (DecreaseLeft  10))
	, ((mm .|. controlMask .|. shiftMask, xK_Right), sendMessage (DecreaseRight 10))
	, ((mm .|. controlMask .|. shiftMask, xK_Down ), sendMessage (DecreaseDown  10))
	, ((mm .|. controlMask .|. shiftMask, xK_Up   ), sendMessage (DecreaseUp    10))

	, ((0, 0x1008ff11), spawn "amixer set Master 5%-")
	, ((0, 0x1008ff12), spawn "amixer set Master toggle")
	, ((0, 0x1008ff13), spawn "amixer set Master 5%+")
	, ((0, 0x1008ff17), spawn "mpc next")
	, ((0, 0x1008ff16), spawn "mpc prev")
	, ((0, 0x1008ff14), spawn "mpc toggle")
	, ((0, 0x1008ff15), spawn "mpc stop")
	--, ((0, 0x1008ff02), spawn "/usr/local/bin/brightness up")
	--, ((0, 0x1008ff03), spawn "/usr/local/bin/brightness dn")

	, ((controlMask .|. shiftMask, xK_Down), spawn "pactl set-sink-volume 0 -- -10%")
	, ((controlMask .|. shiftMask, xK_Up), spawn "pactl set-sink-volume 0 -- +10%")
	, ((controlMask .|. shiftMask, 0x1008ff11), spawn "pactl set-sink-volume 0 -- -8%")
	, ((controlMask .|. shiftMask, 0x1008ff13), spawn "pactl set-sink-volume 0 -- +8%")

	, ((controlMask, xK_KP_Left), spawn "xdotool mousemove_relative -- -10 0")
	, ((controlMask, xK_KP_Right), spawn "xdotool mousemove_relative 10 0")
	, ((controlMask, xK_KP_Up), spawn "xdotool mousemove_relative -- 0 -10")
	, ((controlMask, xK_KP_Begin), spawn "xdotool mousemove_relative 0 10")
	, ((controlMask, xK_KP_End), spawn "xdotool click 1")
	, ((controlMask, xK_KP_Down), spawn "xdotool click 2")
	, ((controlMask, xK_KP_Page_Down), spawn "xdotool click 3")

--	, ((mm, xK_s), windows $ W.greedyView XMonad.workspaces conf)
	]
	++
	[ ((m .|. mm, k), windows $ f i)
		| (i, k) <- zip (XMonad.workspaces conf) ([xK_1 .. xK_9] ++ [xK_0] ++ [xK_minus] ++ [xK_equal])
		, (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask), (copy, controlMask)]
	]
	++
    	[ ((m .|. mm, key), screenWorkspace sc >>= flip whenJust (windows . f))
		| (key, sc) <- zip [xK_Page_Down, xK_Page_Up] [0..]
		, (f, m) <- [(W.view, 0), (W.shift, shiftMask)]
	]

myMouse :: XConfig Layout -> M.Map (KeyMask, Button) (Window -> X ())
myMouse (XConfig {XMonad.modMask = mm}) = M.fromList
	[ ((mm, button1), (\w -> focus w >> mouseMoveWindow w >> FS.snapMagicMove (Just 20) (Just 20) w))
	, ((mm .|. shiftMask, button1), (\w -> focus w >> mouseMoveWindow w >> FS.snapMagicResize [FS.L,FS.R,FS.U,FS.D] (Just 20) (Just 20) w))
	, ((mm, button3), (\w -> focus w >> mouseResizeEdgeWindow 0.5 w))
	]

main = do
	xmproc <- spawnPipe "(echo; exec xmobar ~/.xmonad/xmobarT) | xmobar ~/.xmonad/xmobarB &"
	xmonad defaultConfig
		{ modMask = mod4Mask
		, terminal = "terminator"
		, keys = myKeys
		, mouseBindings = myMouse
		, normalBorderColor = "#dddddd"
		, focusedBorderColor = "#0000ff"
		, workspaces = ["1","2","3","4","5","6","7","8","9","0","-","+"]
		, manageHook = manageDocks <+> composeOne [
				isFullscreen -?> doFullFloat,
				title =? "ettercap" -?> doFloat,
				isDialog -?> doCenterFloat,
				className =? "Chromium-browser" -?> doShift "2",
				className =? "Skype" -?> doShift "3",
				className =? "Transmission-gtk" -?> doShift "8",
				className =? "Conky" -?> doIgnore,
				className =? "Wine" -?> doFloat
			]
		, handleEventHook = fullscreenEventHook <+> perWindowKbdLayout <+> docksEventHook
		, layoutHook = mouseResize $ windowArrange $ avoidStruts $ lessBorders Screen layout
		, logHook = updatePointer (0.5, 0.5) (0.2, 0.2)
			>> (dynamicLogWithPP $ xmobarPP
				{ ppSep = "<fc=#00ff00> | </fc>"
				, ppOutput = hPutStrLn xmproc
				, ppTitle = xmobarColor "cyan" ""
--				, ppUrgent = wrap "<" ">"
--				, ppSort = getSortByXineramaRule
				, ppLayout = (\ x -> case x of
					"MultiCol"		->	"M"
					"Full"			->	"F"
				)
			})
	}
