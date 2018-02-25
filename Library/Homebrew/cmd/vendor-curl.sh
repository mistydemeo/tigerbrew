setup-curl-path() {
  local vendor_dir
  local vendor_curl_current_version
  local vendor_curl_path

  vendor_dir="$HOMEBREW_LIBRARY/Homebrew/vendor"
  vendor_curl_current_version="$vendor_dir/portable-curl/current"
  vendor_curl_path="$vendor_curl_current_version/bin/curl"

  if [[ "$HOMEBREW_COMMAND" != "vendor-install" ]]
  then
    if [[ -x "$vendor_curl_path" ]]
    then
      HOMEBREW_CURL="$vendor_curl_path"

      if [[ $(readlink "$vendor_curl_current_version") != "$(<"$vendor_dir/portable-curl-version")" ]]
      then
        if ! brew vendor-install curl --quiet
        then
          onoe "Failed to upgrade vendor Curl."
        fi
      fi
    else
      if [[ -n "$HOMEBREW_OSX" ]]
      then
        HOMEBREW_CURL="/usr/bin/curl"
      else
        HOMEBREW_CURL="$(which curl)"
      fi

      if [[ "$HOMEBREW_OSX_VERSION_NUMERIC" -lt "100900" || ! -x "$HOMEBREW_CURL" ]]
      then
        brew vendor-install curl --quiet
        if [[ ! -x "$vendor_curl_path" ]]
        then
          odie "Failed to install vendor Curl."
        fi
        HOMEBREW_CURL="$vendor_curl_path"
      fi
    fi
  fi

  export HOMEBREW_CURL
}