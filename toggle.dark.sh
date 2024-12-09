xfconf-query --channel xsettings --property /Net/IconThemeName --create --type string --set "Adwaita"

xfconf-query --channel night-mode --create --type string --property /active --set "day"


chmod +x ~/.local/bin/xfce4-night-mode.sh
bash ~/.local/bin/xfce4-night-mode.sh toggle
