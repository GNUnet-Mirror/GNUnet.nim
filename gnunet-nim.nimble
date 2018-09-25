version = "0.0.0"
author = "secushare"
description = "GNUnet Nim bindings"
license = "AGPL3"
# srcDir = ""

requires = "nim >= 0.18.0"

task groupchat, "Run the Groupchat":
  withDir "examples":
    exec "nim c -r groupchat -p=23014 -c=gnunet1.conf"
