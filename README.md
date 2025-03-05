
Adaptation of https://github.com/pascalw/kindle-dash/ to Kindle PaperWhite 3 (Gen 7).

## Usage
Make the adjustments in the local dir: schedule, ip of the image server, ...

This folder should be dropped into the /mnt/us/ like this:

``` sh
scp -r kindle-dash root@your-kindle-ip:/mnt/us/
```

Then you can activate kindle-dash ssh-ing into your kindle and running:

``` sh
/mnt/us/kindle-dash/start.sh
```

You can also add a KUAL menu entry to start/stop kindle-dash by copying the KUAL/ content into the /mnt/us/extensions directory:

``` sh
cp -r /mnt/us/kindle-dash/KUAL/kindle-dash /mnt/us/extensions
```

Then you should see two new options in your menu.

To stop kindle-dash, you can wake up kindle with the button when it is sleeping with a current picture on the screen, enter the KUAL and press the "Stop Kindle Dashboard" option, or ssh into it and run /mnt/us/kindle-dash/stop.sh.

