#!/bin/bash

sudo apt update -y && sudo apt upgrade -y

if [ ! -e /etc/apt/trusted.gpg.d/iotopen.gpg ]; then
	curl https://pkg.iotopen.se/conf/iotopen.gpg.key | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/iotopen.gpg
else 
	echo IoT Open is trusted, Good.
fi

if [ ! -e /etc/apt/sources.list.d/iotopen.list ]; then
	# Find current release codename
	RELEASE=$(cat /etc/os-release  | grep VERSION_CODENAME | cut -d '=' -f 2)
	# List our repo for the release
	echo "deb [arch=arm64 signed-by=/etc/apt/trusted.gpg.d/iotopen.gpg] http://pkg.iotopen.se/apt/ RELEASE main" | sed "s/RELEASE/${RELEASE}/g" | sudo tee /etc/apt/sources.list.d/iotopen.list
	# Update lists
	sudo apt update 
else
	echo Repositories already set up, Good.
fi


# Install our edge runtime:
sudo apt install -y mosquitto mosquitto-clients iotopen-rt iotopen-edge scheduler iotopen-verify
# Optionally install the zwave daemon
# sudo apt install zwaved

if [ ! -e /etc/iot-open/iotopen.json ]; then
	cat << __END__
+--------------------------------------------------------------------------------------+
| You now have to create /etc/iot-open/iotopen.json                                    |
|                                                                                      |
| Log in to your IoT Open Account. Navigate to you installation and the settings page. |
| Under the Edge-client tab, click "Create new credentials".                           |
| Copy the credentials with the copy-icon next to the header.                          |
| Paste them into /etc/iot-open/iotopen.json                                           | 
|                                                                                      |
| Then run this script again.                                                          |
+--------------------------------------------------------------------------------------+
__END__
	exit
else
	echo iotopen.json exists. Good.
fi

sudo iotopen-verify

sudo /etc/init.d/mosquitto restart
