setup-openssl-path() {
  local vendor_dir
  local vendor_openssl_current_version
  local vendor_openssl_path

  vendor_dir="$HOMEBREW_LIBRARY/Homebrew/vendor"
  vendor_openssl_current_version="$vendor_dir/portable-openssl/current"
  vendor_openssl_path="$vendor_openssl_current_version/bin/openssl"

  SSL_CERT_FILE="$vendor_openssl_current_version/libexec/etc/openssl/cert.pem"

  if [[ "$HOMEBREW_COMMAND" != "vendor-install" ]]
  then
    if [[ -x "$vendor_openssl_path" ]]
    then
      HOMEBREW_OPENSSL_PATH="$vendor_openssl_path"

      if [[ $(readlink "$vendor_openssl_current_version") != "$(<"$vendor_dir/portable-openssl-version")" ]]
      then
        if ! brew vendor-install openssl --quiet
        then
          onoe "Failed to upgrade vendor OpenSSL."
        fi
      fi
    else
      if [[ -n "$HOMEBREW_OSX" ]]
      then
        HOMEBREW_OPENSSL_PATH="/usr/bin/openssl"
      else
        HOMEBREW_OPENSSL_PATH="$(which openssl)"
      fi

      if [[ "$HOMEBREW_OSX_VERSION_NUMERIC" -lt "100900" || ! -x "$HOMEBREW_OPENSSL_PATH" ]]
      then
        brew vendor-install openssl --quiet
        if [[ ! -x "$vendor_openssl_path" ]]
        then
          odie "Failed to install vendor OpenSSL."
        fi
        HOMEBREW_OPENSSL_PATH="$vendor_openssl_path"
      fi
    fi
  fi

  export HOMEBREW_OPENSSL_PATH
  # Most platforms that need a vendored OpenSSL need newer certs, too;
  # those were installed as part of OpenSSL, and setting this path
  # makes sure it'll be found by tools like, e.g., curl.
  if [[ -f $SSL_CERT_FILE ]]
  then
    export SSL_CERT_FILE
  fi
}
