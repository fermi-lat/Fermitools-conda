/usr/bin/sudo mkdir /usr/local/mangled
/usr/bin/sudo find /usr/local/ \
  -type d \
  -depth 1 \
  ! -name miniconda \
  ! -name mangled \
  -exec mv \{\} /usr/local/mangled/. \;
/usr/bin/sudo -k
