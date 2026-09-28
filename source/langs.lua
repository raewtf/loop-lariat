langs = {
	en = {
		-- title screen
		["title_modeselect"] = "Round 'em Up!",
		["title_howtoplay"] = "How to Play",
		["title_statistics"] = "Statistics",
		["title_options"] = "Options",
		["title_credits"] = "Credits",



		-- mode select
		["modeselect_prompt"] = "Select yer mode!",
		["modeselect_prompt_2"] = "(Use up/down!)",

		["modeselect_arcade"] = "Arcade",
		["modeselect_time"] = "Time Attack",
		["modeselect_marathon"] = "Marathon",
		["modeselect_daily"] = "Daily Run",
		["modeselect_vs_2p"] = "VS. 2P",
		["modeselect_vs_com"] = "VS. COM",
		["modeselect_chill"] = "Practice",

		["modeselect_arcade_desc"] = "Score as many lassos as you\ncan, to try and keep the\ntimer from reaching zero!",
		["modeselect_time_desc"] = "How many points do you think\nyou can wrangle under a\nstrict time limit?",
		["modeselect_marathon_desc"] = "Lasso up outlaws endlessly.\nGo until you completely\nfill up the game board!",
		["modeselect_daily_desc"] = "New randomized seed each day!\nEveryone has the same blocks.\nYou only get one shot!",
		["modeselect_vs_com_desc"] = "Battle against a computer!\nWatch out for tumbleweeds;\nthey clutter up the board!",
		["modeselect_vs_2p_desc"] = "Face off against a friend! ...Or,\nan enemy? (Requires an extra\ncontroller to play.)",
		["modeselect_chill_desc"] = "Play at your own pace, for\nas long as you'd like! No\ntime limits, no game overs.",

		["modeselect_refreshes_in"] = "(New in ",
		["modeselect_h"] = "h)",
		["modeselect_m"] = "m)",
		["modeselect_s"] = "s)",

		["modeselect_time_prompt"] = "Choose yer time limit:",

		["1min"] = "1 Minute",
		["5min"] = "5 Minutes",
		["10min"] = "10 Minutes",



		-- in-game
		["score"] = "Score",
		["1p_score"] = "1P Score",
		["2p_score"] = "2P Score",
		["com_score"] = "COM Score",
		["wins"] = "Wins",

		["best"] = "Best",
		["timer"] = "Timer",
		["lassos"] = "Lassos",
		["seed"] = "Seed",

		["next"] = "Next",
		["now"] = "Now",
		["hold"] = "Hold",

		["paused"] = "Hold your horses!",
		["resume"] = "Resume Game",
		["quit"] = "End Game",
		["quit_warning"] = "(If you end this game, you'll\nlose any progress you've made!)",

		["gameover"] = "Game over, pardner!",
		["timeup"] = "Time's up, cowboy!",
		["your_score"] = "Yer score: ",
		["todays_score"] = "Today's score: ",
		["best_score"] = "Best: ",
		["new_best"] = "(New best!)",
		["total_lassos"] = "Lassos: ",
		["new_game"] = "New Game",
		["go_back"] = "Go Back",



		-- how to play
		["howtoplay_1"] = "Some rough-'n'-tumble\nbandits from the\nMeeple Crew are\nterrorizing the\ntown! You've gotta\nhelp wrangle 'em\nwith your lassos, and\nsend 'em to the ol'\nprison house.",
		["howtoplay_2"] = "\nThere are four\ntypes of blocks\nyou can find\non the game board.\nEach one has\nits own special\nproperties!",
		["howtoplay_3"] = "Lassos can be linked\ntogether. If you make\na full loop, they'll\nwrangle up anything\nfound inside, except other\nlassos. This is how\nyou can nab those\nnasty Meeple bandits!",
		["howtoplay_4"] = "Dynamite will destroy\nwhatever it lands on.\nUse it to clear the\nclutter, or remove some\nunwanted lasso-bits!\nCareful, though: if\nyou blow up an\noutlaw, you won't\nearn any points!",
		-- TODO: replace "on rare occasions" with "in the VS mode" after that becomes real. (do this in the manual, too.)
		["howtoplay_5"] = "Tumbleweeds are only\nseen on rare occasions.\nThey clutter up the\nscreen, and get in\nyour way. You'll\nneed to blow\nthese suckers sky\nhigh with some of\nthat dynamite!",
		["howtoplay_6"] = "To learn more\nabout how the\ngame is played,\nplease refer to\nthe electronic\nmanual by\nscanning the\ncode over thar.",

		["block_label_lasso"] = "Lasso",
		["block_label_outlaw"] = "Outlaw",
		["block_label_tnt"] = "Dynamite",
		["block_label_tumble"] = "Tumbleweed",



		-- statistics
		["statistics_playtime"] = "Play Time: ",
		["statistics_gametime"] = "Time Spent In-Game: ",
		["statistics_cumulative_score"] = "Cumulative Score: ",

		["statistics_blocks_placed"] = "Blocks Placed: ",
		["statistics_total_lassos"] = "Total Lassos: ",
		["statistics_outlaws_captured"] = "Outlaws Captured: ",
		["statistics_dynamites_exploded"] = "Dynamites Exploded: ",

		["statistics_total_played"] = "Total Games Played: ",
		["statistics_arcade_played"] = "Arcade Games Played: ",
		["statistics_time_played"] = "Time Attack Games Played: ",
		["statistics_marathon_played"] = "Marathon Games Played: ",
		["statistics_daily_played"] = "Daily Runs Played: ",
		["statistics_chill_played"] = "Practice Games Played: ",

		["statistics_total_battles"] = "Total Battles: ",
		["statistics_vs_2p_played"] = "Battles VS. 2P: ",
		["statistics_vs_com_played"] = "Battles VS. COM: ",
		["statistics_wins_1p"] = "1P Wins: ",
		["statistics_wins_2p"] = "2P Wins: ",
		["statistics_wins_com"] = "COM Wins: ",

		["statistics_h"] = "h",
		["statistics_m"] = "m",
		["statistics_s"] = "s",



		-- options
		["options"] = "Options",

		["options_music"] = "Music: ",
		["options_sfx"] = "SFX: ",
		["options_lang"] = "Language: ",
		["options_reduceflashing"] = "Reduce Flash: ",
		["options_rumble"] = "Rumble: ",
		["options_image_path"] = "Style: ",
		["options_clean_scaling"] = "Scaling: ",
		["options_remap"] = "Remap Keyboard",

		["options_false"] = "OFF",
		["options_true"] = "ON",

		["options_0"] = "OFF",
		["options_1"] = "ON",
		["options_2"] = "AUTO",

		["options_clean_scaling_false"] = "Wonky",
		["options_clean_scaling_true"] = "Clean",

		["options_images_love"] = "Color",
		["options_images_peedee"] = "PeeDee",

		["options_en"] = "English",
		["options_fr"] = "French",

		["options_remap_prompt"] = "Press the key you\nwanna use for:",
		["options_remap_1"] = "Up (direction)",
		["options_remap_2"] = "Down (direction)",
		["options_remap_3"] = "Left (direction)",
		["options_remap_4"] = "Right (direction)",
		["options_remap_5"] = "Confirm / Place Block",
		["options_remap_6"] = "Back / Hold Block",
		["options_remap_cancel"] = "(Press ESC to cancel.)",



		-- credits
		["credits_name_1"] = "Rae",
		["credits_desc_1"] = "Drawings, code,\nmusic, and SFX",

		["accomplices"] = "Accomplices:",

		["credits_name_2"] = "Voxy",
		["credits_desc_2"] = "French Localizing",
		["credits_name_3"] = "Font End Dev",
		["credits_desc_3"] = "This here font",
		["credits_name_4"] = "Eli Piilonen",
		["credits_desc_4"] = "Randomization",
		["credits_name_5"] = "airstruck, Matthias\nRichter, Yuichi Tateno,\nEmmanuel Oga, rxi",
		["credits_desc_5"] = "LOVE2D stuff",



		-- playdate slide menu
		["slide_quit"] = "end game",
		["slide_back"] = "go back",
	},

	fr = {
		-- title screen
		["title_modeselect"] = "Raflez-les !",
		["title_howtoplay"] = "Instructions",
		["title_statistics"] = "", -- !!
		["title_options"] = "Options",
		["title_credits"] = "Crédits",



		-- mode select
		["modeselect_prompt"] = "Choisissez vot' mode !",
		["modeselect_prompt_2"] = "(Appuyez sur haut/bas !)",

		["modeselect_arcade"] = "Arcade",
		["modeselect_time"] = "Contre-la-montre",
		["modeselect_marathon"] = "Marathon",
		["modeselect_daily"] = "Partie du jour",
		["modeselect_vs_2p"] = "Versus",
		["modeselect_vs_com"] = "Versus ORDI",
		["modeselect_chill"] = "Entraînement",

		["modeselect_arcade_desc"] = "Jouez du lasso autant que\npossible pour empêcher le\nminuteur d'atteindre zéro !",
		["modeselect_time_desc"] = "Combien de points vous pouvez\nrassembler dans le temps\nimparti ?",
		["modeselect_marathon_desc"] = "Des hors-la-loi à n'en plus\nfinir. Jouez jusqu'à ce\nque le plateau soit rempli !",
		["modeselect_daily_desc"] = "Une nouvelle partie chaque\njour ! Les blocs sont les\nmêmes pour tout le monde.",
		["modeselect_vs_com_desc"] = "Faites face à l'ordinateur !\nAttention aux virevoltants,\nils encombrent le plateau !",
		["modeselect_vs_2p_desc"] = "Affrontez un ami ! Ou bien...\nun ennemi ? (Requiert une\ndeuxième manette.)",
		["modeselect_chill_desc"] = "Jouez à votre aise, pour\naussi longtemps que\nvous voulez, sans game overs.",

		["modeselect_refreshes_in"] = "(",
		["modeselect_h"] = "h)",
		["modeselect_m"] = "m)",
		["modeselect_s"] = "s)",

		["modeselect_time_prompt"] = "Quelle limite de temps ?",

		["1min"] = "1 minute",
		["5min"] = "5 minutes",
		["10min"] = "10 minutes",



		-- in-game
		["score"] = "Score",
		["1p_score"] = "Score J1",
		["2p_score"] = "Score J2",
		["com_score"] = "Score ORDI",
		["wins"] = "Victoires",

		["best"] = "Meilleur",
		["timer"] = "Temps",
		["lassos"] = "Lassos",
		["seed"] = "Graine",

		["next"] = "Suivant",
		["now"] = "Actuel",
		["hold"] = "Réserve",

		["paused"] = "Tenez vos chevaux !",
		["resume"] = "Reprendre",
		["quit"] = "Abandonner",
		["quit_warning"] = "(Si vous abandonnez, votre\nprogression sera perdue !)",

		["gameover"] = "Terminé, partenaire !",
		["timeup"] = "Temps écoulé, cowboy !",
		["your_score"] = "Vot' score : ",
		["todays_score"] = "", -- !!
		["best_score"] = "Record : ",
		["new_best"] = "(Nouveau record !)",
		["total_lassos"] = "Lassos : ",
		["new_game"] = "Recommencer",
		["go_back"] = "Retour",



		-- how to play
		["howtoplay_1"] = "\nLes affreux bandits\ndu gang des Meeple\nterrorisent la ville !\nUtilisez vos lassos\npour arrêter ces\nfripouilles et les\nenvoyer au bagne !",
		["howtoplay_2"] = "\nSur le plateau,\nvous trouverez\nquatre sortes de\nblocs différents.\nChacune d'elles\na ses propres\ncapacités !",
		["howtoplay_3"] = "Les lassos s'attachent\nensemble. En formant\nune boucle, vous\nattraperez tous les blocs\nà l'intérieur, sauf les\nautres lassos. C'est comme\nça qu'on arrête ces\nvauriens de Meeple !",
		["howtoplay_4"] = "La dynamite détruit\nle bloc sur lequel\nelle est posée.\nUtilisez-la pour nettoyer\nle plateau, y compris les bouts\nde lasso en trop.\nMais attention :\nsi vous faites sauter\nun bandit, il ne\nvaudra plus rien !",
		["howtoplay_5"] = "Des virevoltants\npeuvent apparaître\nde temps en temps. Ils\nencombrent l'écran et\nbloquent vos lassos.\nUn peu de dynamite\nsera utile pour\ns'en débarrasser !",
		["howtoplay_6"] = "\nPour plus\nd'assistance,\nconsultez le\nmode d'emploi\nélectronique\nen scannant\nce code.",

		["block_label_lasso"] = "Lasso",
		["block_label_outlaw"] = "Bandit",
		["block_label_tnt"] = "Dynamite",
		["block_label_tumble"] = "Virevoltant",



		-- statistics
		-- !!
		["statistics_playtime"] = "",
		["statistics_gametime"] = "",
		["statistics_cumulative_score"] = "",

		["statistics_blocks_placed"] = "",
		["statistics_total_lassos"] = "",
		["statistics_outlaws_captured"] = "",
		["statistics_dynamites_exploded"] = "",

		["statistics_total_played"] = "",
		["statistics_arcade_played"] = "",
		["statistics_time_played"] = "",
		["statistics_marathon_played"] = "",
		["statistics_daily_played"] = "",
		["statistics_chill_played"] = "",

		["statistics_total_battles"] = "",
		["statistics_vs_2p_played"] = "",
		["statistics_vs_com_played"] = "",
		["statistics_wins_1p"] = "",
		["statistics_wins_2p"] = "",
		["statistics_wins_com"] = "",

		["statistics_h"] = "",
		["statistics_m"] = "",
		["statistics_s"] = "",



		-- options
		["options"] = "Options",

		["options_music"] = "Musique : ",
		["options_sfx"] = "Sons : ",
		["options_lang"] = "Langue: ",
		["options_reduceflashing"] = "Animations : ",
		["options_rumble"] = "Vibrations : ",
		["options_image_path"] = "", -- !!
		["options_clean_scaling"] = "Échelle : ",
		["options_remap"] = "Config. touches",

		["options_false"] = "NON",
		["options_true"] = "OUI",

		-- these are reversed because the context in which they're being presented is swapped. SORRY!
		["options_0"] = "OUI",
		["options_1"] = "NON",
		["options_2"] = "AUTO",

		["options_clean_scaling_false"] = "Auto.",
		["options_clean_scaling_true"] = "Entière",

		["options_images_love"] = "", -- !!
		["options_images_peedee"] = "", -- !!

		["options_en"] = "English",
		["options_fr"] = "Français",

		["options_remap_prompt"] = "Appuyez sur la\ntouche de l'action :",
		["options_remap_1"] = "Aller vers le haut",
		["options_remap_2"] = "Aller vers le bas",
		["options_remap_3"] = "Aller à gauche",
		["options_remap_4"] = "Aller à droite",
		["options_remap_5"] = "Confirmer / placer",
		["options_remap_6"] = "Retour / réserve",
		["options_remap_cancel"] = "(Échap : annuler.)",



		-- credits
		["credits_name_1"] = "Rae",
		["credits_desc_1"] = "Graphismes, code,\nmusique, et sons",

		["accomplices"] = "Complices :",

		["credits_name_2"] = "Voxy",
		["credits_desc_2"] = "Localisation FR",
		["credits_name_3"] = "Font End Dev",
		["credits_desc_3"] = "Cette police",
		["credits_name_4"] = "Eli Piilonen",
		["credits_desc_4"] = "Algo. d'aléatoire",
		["credits_name_5"] = "airstruck, Matthias\nRichter, Yuichi Tateno,\nEmmanuel Oga, rxi",
		["credits_desc_5"] = "Librairies LÖVE2D",



		-- playdate slide menu
		["slide_quit"] = "terminer",
		["slide_back"] = "retour",
	}
}

return langs