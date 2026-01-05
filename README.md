# FIJI-Multi-Channel-RGB-Stacker
 
The FIJI-Multi-Channel-RGB-Stacker plugin automatically processes multi-channel microscopy images and combines them into a single merged composite. Fluorescence intensities can either be adjusted automatically--using the minimum and maximum pixel values in each channel for each image--or manually--with specified minimum and maximum pixel values for each channel that is applied across all images. Unlike some native composite functions in FIJI, the FIJI-Multi-Channel-RGB-Stacker script pulls the color look-up tables directly from the local directory, providing users with more color options and allowing them to use their own custom look-up tables (i.e. located in the "luts" folder).

## Getting Started

1. Clone the repository
2. Open FIJI
3. Navigate to `Plugins` -> `Macros` -> `Run` or `Edit` (Note: I recommend using `Edit` in case you need to run the script multiple times).
5. Open "multi-channel-rgb-stacker.ijm". If you opened the script with `Edit`, press `Run`
6. OPTIONAL: Before running the "multi-channel-rgb-stacker.ijm" script, you can align a representative field of view, save the transformation file, and apply the transformation across all fields of view with [MultiStackReg](https://imagej.net/plugins/multistackreg)
7. Upon running the script, it should open to a GUI like this:

<p align="center">
<img src="/tutorial/Multi-channel-RGB-ui-as_of_01-05-2025.JPG" alt="GUI Example" width="500px"/>
</p>

## Using the Plugin

### 1) Open Image Path
Press **Browse** and select the folder containing your images

### 2) Add Channels
Write the substring (e.g. ch00, DAPI, etc.) for each channel that is contained within the image filenames. The location of this substring within the filename should not matter, but for this to work correctly, the rest of the image name must be the same between channels within the same field of view.

For each channel, select the desired color. These are either coded inside FIJI or located in the "luts" folder of your installation. 

Lastly, if you are using a manual threshold, enter the desired minimum and maximum values for each channel. These thresholds will be applied across all fields of view.

### 3) Thresholding
If you would like to use your manual thresholds or automatically threshold each image based on the maximum value, select either or both options. If you simply want a composite of the raw intensities, you do not have to select either option.

### 4) OPTIONAL: Aligning
If your channels are slightly misaligned (e.g. due to chromatic abberation or slight misalignments in laser optics), you can applied a representative transformation to realign all channels and fields of view. Simply press **Browse** and select your transformation file.

### 5) Individual channel images
Lastly, if you would like a copy of each channel with the modifications above, select this option.
