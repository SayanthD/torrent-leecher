#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# (c) Shrimadhav U K

# the logging things
import logging
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
LOGGER = logging.getLogger(__name__)

import configparser
from pykeyboard import InlineKeyboard
from pyrogram.types import (
    InlineKeyboardButton,
    Message
)
from tobrot import (
    R_CLONE_CONF_URI
)
from tobrot.helper_funcs.r_clone import (
    get_r_clone_config
)


async def get_markup(message: Message):
    ikeyboard = InlineKeyboard()
    ikeyboard.row(
            InlineKeyboardButton(
                "leech",
                callback_data=("leech")
                ),
            InlineKeyboardButton(
                "youtube-dlc",
                callback_data=("ytdl")
                ))
    ikeyboard.row(
            InlineKeyboardButton(
                "leech archive",
                callback_data=("leecha")
                ),
            InlineKeyboardButton(
                "youtube-dlc archive",
                callback_data=("ytdla")
                ))
    if R_CLONE_CONF_URI:
        r_clone_conf_file = await get_r_clone_config(
            R_CLONE_CONF_URI,
            message._client
        )
        if r_clone_conf_file is not None:
            config = configparser.ConfigParser()
            config.read(r_clone_conf_file)
            remote_names = config.sections()
            it_r = 0
            for remote_name in remote_names:
                ikeyboard.row(InlineKeyboardButton(
                    f"RClone LEECH {remote_name}",
                    callback_data=(f"leech_rc_{it_r}").encode("UTF-8")
                ))
                # ikeyboard.append(InlineKeyboardButton(
                #     f"RClone YTDL {remote_name}",
                #     callback_data=(f"ytdl_rc_{it_r}").encode("UTF-8")
                # ))
                it_r = it_r + 1

    reply_text = (
        "please select the required option"
    )
    return reply_text, ikeyboard
