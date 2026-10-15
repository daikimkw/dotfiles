#!/bin/bash

set -eu

# MEO (vadimmelnicuk.meo) hardcodes the "contentMaxWidth" column at 800px in its
# webview bundle and exposes no setting for the value. Rewrite it in every
# installed version. Extension updates restore the original, so this runs on
# every `chezmoi apply` and is a no-op once patched.

width="1200px"

for js in "$HOME"/.vscode/extensions/vadimmelnicuk.meo-*/webview/dist/index.js; do
  [ -f "$js" ] || continue
  # Minified form: <var>="<N>px",<var>="100%" (the enabled / disabled widths)
  perl -0pi -e 's/([A-Za-z_\$][\w\$]*)="\d+px",([A-Za-z_\$][\w\$]*)="100%"/$1="'"$width"'",$2="100%"/' "$js"
done
