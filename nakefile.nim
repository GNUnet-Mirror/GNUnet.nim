import nake
import sequtils

proc build() =
  let
    dest = "examples/groupchat"
    src = dest & ".nim"

  if dest.needsRefresh(src):
    direSilentShell(src & " -> " & dest,
                                   nimExe, "c", "--verbosity:2",
                                   src)

# Not fully functional or functional at all right now:
proc buildDocs() =
  for name in ["asynccadet", "gnunet_application",
               "gnunet_cadet_service", "gnunet_common",
               "gnunet_configuration_lib", "gnunet_crypto_lib",
               "gnunet_mq_lib", "gnunet_protocols",
               "gnunet_scheduler_lib", "gnunet_time_lib",
               "gnunet_types", "gnunet_utils"]:
    let
      dest = name & ".html"
      src = name & ".nim"

    if dest.needsRefresh(src):
      direSilentShell(src & " -> " & dest,
                                     nimExe, "doc2", "--verbosity:0", "--index:on", src)

  for rstSrc in walkFiles("*.rst"):
    let rstDest = rstSrc.changeFileExt(".html")
    if not rstDest.needsRefresh(rstSrc): continue
    direSilentShell(rstSrc & " -> " & rstDest,
                                      nimExe & " rst2html --verbosity:0 --index:on -o:" &
                                      rstDest & " " & rstSrc)

  direSilentShell("Building theindex.html", nimExe, "buildIndex .")


task "docs", "generate user documentation for nake API and local rst files":
  buildDocs()
  echo "Finished generating docs"

task "build", "build binaries and examples":
  build()
  echo "Finished build"
