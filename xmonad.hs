import System.Exit

import XMonad
import XMonad.Config.Azerty
import XMonad.Hooks.DynamicLog

import qualified XMonad.StackSet as W

import Data.Monoid
import qualified Data.Map as M

myManageHook :: Query (Data.Monoid.Endo WindowSet)
myManageHook = composeAll
	[ className =? "qemu-system-x86_64" --> doFloat
 	]

main :: IO ()
main = statusBar myBar myPP toggleStrutsKey myConfig  >>=
       xmonad

myPP = xmobarPP { ppOutput = putStrLn
		, ppCurrent = xmobarColor "orange" "" . wrap "[" "]"
		, ppHiddenNoWindows = xmobarColor "grey" ""
		, ppTitle   = xmobarColor "green"  "" . shorten 40
		, ppVisible = wrap "(" ")"
		, ppUrgent  = xmobarColor "red" "yellow" . wrap "<" ">"
		}
toggleStrutsKey XConfig {XMonad.modMask = modMask} = (modMask, xK_b)

myBar = "xmobar"

numBepo = [0x22,0xab,0xbb,0x28,0x29,0x40,0x2b,0x2d,0x2f,0x2a]
-- numAzerty = [0x26,0xe9,0x22,0x27,0x28,0x2d,0xe8,0x5f,0xe7,0xe0]
num = numBepo

bepoKeys :: XConfig Layout -> M.Map (KeyMask, KeySym) (X ())
bepoKeys conf@(XConfig {modMask = modm}) = M.fromList $
    [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf) -- %! Launch terminal
    , ((modm,               xK_p     ), spawn "dmenu_run") -- %! Launch dmenu
    , ((modm .|. shiftMask, xK_p     ), spawn "gmrun") -- %! Launch gmrun
    , ((modm .|. shiftMask, xK_c     ), kill) -- %! Close the focused window

    , ((modm,               xK_space ), sendMessage NextLayout) -- %! Rotate through the available layout algorithms
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf) -- %!  Reset the layouts on the current workspace to default

    , ((modm,               xK_n     ), refresh) -- %! Resize viewed windows to the correct size

    , ((modm,               xK_Tab   ), windows W.focusDown) -- %! Move focus to the next window
    , ((modm .|. shiftMask, xK_Tab   ), windows W.focusUp  ) -- %! Move focus to the previous window
    , ((modm, xK_c), sendMessage Shrink          )
    , ((modm, xK_n), windows     W.focusMaster   )
    , ((modm, xK_t), windows     W.focusDown     )
    , ((modm, xK_s), windows     W.focusUp       )
    , ((modm, xK_r), sendMessage Expand          )

    , ((modm,               xK_Return), windows W.swapMaster)
    , ((modm .|. shiftMask, xK_t),      windows W.swapDown  )
    , ((modm .|. shiftMask, xK_s),      windows W.swapUp    )

    , ((modm, xK_g), sendMessage (IncMasterN (-1)))
    , ((modm, xK_q), sendMessage (IncMasterN 1)  )

    , ((modm, xK_f), withFocused $ windows . W.sink) -- %! Push window back into tiling

    , ((modm .|. shiftMask, xK_e     ), io exitSuccess) -- %! Quit xmonad
    , ((modm              , xK_e     ), spawn "if type xmonad; then xmonad --recompile && xmonad --restart; else xmessage xmonad not in \\$PATH: \"$PATH\"; fi") -- %! Restart xmonad
    ]
    ++
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (workspaces conf) num
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    

--myKeys c = bepoKeys c `M.union` keys defaultConfig c

myConfig = defaultConfig { keys = bepoKeys
			 , terminal = "konsole"
			 , workspaces = ["1","2","3","4","5","6","chat","mail","web"]
			 , manageHook = manageHook defaultConfig <+> myManageHook
			 }
