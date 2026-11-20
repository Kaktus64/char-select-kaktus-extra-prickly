-- name: [CS] \\#ac50ff\\Kaktus 2
-- description: Kaktus 2 Ultra Deluxe + Tropical Freeze's Fury 10 EX DX X Z Now featuring Saul from the Saul Game 3D Series U x Isikle Auto For Nintendo 3DS for Wii U 7

local E_MODEL_KAKTUS = smlua_model_util_get_id("kaktus_geo")

local TEX_KAK_ICON = get_texture_info("kaktus-icon")

local KAKTUS_TUNE = audio_stream_load("kaktus-cs-theme.ogg")

local PALETTE_KAKTUS = {

    [PANTS]  = "28263B",
    [SHIRT]  = "862692",
    [GLOVES] = "FF0003",
    [SHOES]  = "BB733B",
    [HAIR]   = "6B4637",
    [SKIN]   = "ECA677",
    [CAP]    = "4BA434",
	[EMBLEM] = "FF003D"
}

local PALETTE_SAULTUS = {

    [PANTS]  = "000000",
    [SHIRT]  = "afcb66",
    [GLOVES] = "ba0000",
    [SHOES]  = "3a394b",
    [HAIR]   = "715843",
    [SKIN]   = "ECA677",
    [CAP]    = "afcb66",
	[EMBLEM] = "ba0000"
}

local PALETTE_CHARLOTTUS = {

    [PANTS]  = "434A96",
    [SHIRT]  = "E50047",
    [GLOVES] = "FF0003",
    [SHOES]  = "660020",
    [HAIR]   = "7F4827",
    [SKIN]   = "ECA677",
    [CAP]    = "434A96",
	[EMBLEM] = "FF2FB4"
}

local PALETTE_PURPLETUS = {

    [PANTS]  = "0c0028",
    [SHIRT]  = "380072",
    [GLOVES] = "FF0003",
    [SHOES]  = "610055",
    [HAIR]   = "05ec00",
    [SKIN]   = "ECA677",
    [CAP]    = "130061",
	[EMBLEM] = "d500ff"
}

local PALETTE_GRAYTUS = {

    [PANTS]  = "272727",
    [SHIRT]  = "424242",
    [GLOVES] = "363636",
    [SHOES]  = "363636",
    [HAIR]   = "7e7e7e",
    [SKIN]   = "d9d9d9",
    [CAP]    = "b1b1b1",
	[EMBLEM] = "888888"
}

local PALETTE_QONTROVERSIALTUS = {

    name = "Jertus",
    [PANTS]  = "008040",
    [SHIRT]  = "ffaa00",
    [GLOVES] = "008040",
    [SHOES]  = "000000",
    [HAIR]   = "462c1e",
    [SKIN]   = "DB9C70",
    [CAP]    = "4c4c4c",
	[EMBLEM] = "00ff00"
}

if _G.charSelectExists then
    CT_KAKTUS = _G.charSelect.character_add("Kaktus", {"prick"}, "Kaktus64", {r = 97, g = 26, b = 179}, E_MODEL_KAKTUS, CT_MARIO, TEX_KAK_ICON, 1)
    
    _G.charSelect.character_add_palette_preset(E_MODEL_KAKTUS, PALETTE_KAKTUS, "Prickly Person")
    _G.charSelect.character_add_palette_preset(E_MODEL_KAKTUS, PALETTE_SAULTUS, "Spore Supporter")
    _G.charSelect.character_add_palette_preset(E_MODEL_KAKTUS, PALETTE_CHARLOTTUS, "Brownie Buyer")
    _G.charSelect.character_add_palette_preset(E_MODEL_KAKTUS, PALETTE_PURPLETUS, "Purple Pal")
    _G.charSelect.character_add_palette_preset(E_MODEL_KAKTUS, PALETTE_GRAYTUS, "Grayscale Gary")
    _G.charSelect.character_add_palette_preset(E_MODEL_KAKTUS, PALETTE_QONTROVERSIALTUS, "Qontroversial Quinn")

    _G.charSelect.character_add_menu_instrumental(CT_KAKTUS, KAKTUS_TUNE)

    --add_moveset()
end
