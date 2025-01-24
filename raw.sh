autostart/xfce4-clipman-plugin-autostart.desktop 
[Desktop Entry]
Hidden=false
TryExec=xfce4-clipman
Exec=xfce4-clipman


xfce4/panel/xfce4-clipman-actions.xml 
<?xml version="1.0" encoding="UTF-8"?>
<actions>
	<action>
		<name>Bugz</name>
		<regex>bug\s*#?\s*([0-9]+)</regex>
		<group>0</group>
		<commands>
			<command>
				<name>GNOME Bug</name>
				<exec>exo-open http://bugzilla.gnome.org/show_bug.cgi?id=\1</exec>
			</command>
			<command>
				<name>Xfce Bug</name>
				<exec>exo-open http://bugzilla.xfce.org/show_bug.cgi?id=\1</exec>
			</command>
		</commands>
	</action>
	<action>
		<name>Image</name>
		<regex>(http|ftp).+\.(jpg|png|gif)</regex>
		<group>0</group>
		<commands>
			<command>
				<name>View with Ristretto</name>
				<exec>ristretto &quot;\0&quot;</exec>
			</command>
			<command>
				<name>Edit with Gimp</name>
				<exec>gimp &quot;\0&quot;</exec>
			</command>
		</commands>
	</action>
	<action>
		<name>Long URL</name>
		<regex>http://[^\s]{120,}</regex>
		<group>0</group>
		<commands>
			<command>
				<name>Shrink the URL</name>
				<exec>exo-open http://tinyurl.com/create.php?url=\0</exec>
			</command>
		</commands>
	</action>
</actions>%               

xfce4/xfconf/xfce-perchannel-xml/xfce4-screenshooter.xml
<?xml version="1.0" encoding="UTF-8"?>

xfce4/xfconf/xfce-perchannel-xml/xfce4-clipman.xml      
<?xml version="1.0" encoding="UTF-8"?>

<channel name="xfce4-clipman" version="1.0">
  <property name="settings" type="empty">
    <property name="add-primary-clipboard" type="bool" value="true"/>
  </property>
</channel>


xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml 
<?xml version="1.0" encoding="UTF-8"?>

<channel name="xfce4-power-manager" version="1.0">
  <property name="xfce4-power-manager" type="empty">
    <property name="show-tray-icon" type="bool" value="false"/>
    <property name="power-button-action" type="uint" value="4"/>
    <property name="lock-screen-suspend-hibernate" type="bool" value="false"/>
    <property name="dpms-on-ac-off" type="uint" value="32"/>
    <property name="dpms-on-ac-sleep" type="uint" value="31"/>
    <property name="blank-on-ac" type="int" value="17"/>
    <property name="sleep-button-action" type="uint" value="3"/>
    <property name="hibernate-button-action" type="uint" value="3"/>
    <property name="battery-button-action" type="uint" value="3"/>
  </property>
</channel>


xfce4/xfconf/xfce-perchannel-xml/xfce4-session.xml      
<?xml version="1.0" encoding="UTF-8"?>

<channel name="xfce4-session" version="1.0">
  <property name="general" type="empty">
    <property name="FailsafeSessionName" type="empty"/>
    <property name="LockCommand" type="empty"/>
    <property name="PromptOnLogout" type="bool" value="false"/>
  </property>
  <property name="sessions" type="empty">
    <property name="Failsafe" type="empty">
      <property name="IsFailsafe" type="empty"/>
      <property name="Count" type="empty"/>
      <property name="Client0_Command" type="empty"/>
      <property name="Client0_Priority" type="empty"/>
      <property name="Client0_PerScreen" type="empty"/>
      <property name="Client1_Command" type="empty"/>
      <property name="Client1_Priority" type="empty"/>
      <property name="Client1_PerScreen" type="empty"/>
      <property name="Client2_Command" type="empty"/>
      <property name="Client2_Priority" type="empty"/>
      <property name="Client2_PerScreen" type="empty"/>
      <property name="Client3_Command" type="empty"/>
      <property name="Client3_Priority" type="empty"/>
      <property name="Client3_PerScreen" type="empty"/>
      <property name="Client4_Command" type="empty"/>
      <property name="Client4_Priority" type="empty"/>
      <property name="Client4_PerScreen" type="empty"/>
    </property>
  </property>
  <property name="shutdown" type="empty">
    <property name="LockScreen" type="bool" value="false"/>
  </property>
  <property name="chooser" type="empty">
    <property name="AlwaysDisplay" type="bool" value="false"/>
  </property>
</channel>


xfce4/xfconf/xfce-perchannel-xml/pointers.xml           
<?xml version="1.0" encoding="UTF-8"?>

<channel name="pointers" version="1.0">
  <property name="Logitech_G604_" type="empty">
    <property name="RightHanded" type="bool" value="true"/>
    <property name="ReverseScrolling" type="bool" value="true"/>
    <property name="Threshold" type="int" value="1"/>
    <property name="Acceleration" type="double" value="5"/>
  </property>
</channel>
