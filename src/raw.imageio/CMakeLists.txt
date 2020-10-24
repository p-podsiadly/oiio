# Copyright 2008-present Contributors to the OpenImageIO project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/OpenImageIO/oiio/blob/master/LICENSE.md

if (TARGET libraw::libraw)
    add_oiio_plugin (rawinput.cpp
                     LINK_LIBRARIES libraw::libraw
                     DEFINITIONS "-DUSE_LIBRAW=1")
else ()
    message (WARNING "Raw plugin will not be built")
endif ()
