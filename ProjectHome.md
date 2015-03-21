What do you do when you want to test a shiny new disk drive? After using dd and tar and so forth, we decided to write a more strenuous test for new drives.

This program does a random walk over the entire (raw) disk, reading a 4K block. This provides several exercises of the disk and the I/O layers. If nothing else, it makes lots of noise and heat, and the all-important blinking lights that show the boss that you're getting lots of work done.

I had a mode in place to do write-after-read, and then realized that I'd have to check and see if the device was mounted to avoid evil race condition errors, and then decided to skip the idea for now. I figure, the read-only mode is a pretty good test, at least for now.

**Warning!**
This program operates on the raw device file, requiring root access or comparable device permissions. This is not without significant risk. The program carries no guarantees, etc, etc. If it breaks, you get the pieces.

Docs
See the header of the code. Examples:

```
molest.pl -d /dev/sdd -n 4096	    

molest.pl -d /dev/hda
```

Notes
This reads the device size by doing a seek of the raw device. This is known to fail on Irix and may not work on other Unix flavors. Let me know.
Formerly self-hosted at http://www.phfactor.net/code/molest/