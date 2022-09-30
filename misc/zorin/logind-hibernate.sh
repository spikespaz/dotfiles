#! /bin/sh
# enable logind hibernation
cat <<- EOF > /etc/polkit-1/localauthority/50-local.d/com.ubuntu.enable-hibernate.pkla
	[Enable hibernate]
	Identity=unix-user:*
	Action=org.freedesktop.login1.hibernate;org.freedesktop.login1.handle-hibernate-key;org.freedesktop.login1;org.freedesktop.login1.hibernate-multiple-sessions
	ResultActive=yes
EOF

# <https://www.linuxuprising.com/2021/08/how-to-enable-hibernation-on-ubuntu.html>
# <https://forum.zorin.com/t/how-to-enable-hibernate-option-on-zorinos-16-or-other-gnome-distros/15582>
