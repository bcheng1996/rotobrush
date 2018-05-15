# Rotobrush

A pipeline for video object segmentation. Given the boundary of an object in the initial frame of a video, 
the system will track the object’s boundary through the subsequent frames. 
The system will be based on the SnapCut algorithm which powers the Rotobrush tool in Adobe AfterEffects! 

![localWindows](example/update_windows.jpg)

---

## Local Windows
The SnapCut algorithm implements the idea of local windows to measure mappings of color and shape
to determine the general location of the foreground that we want to track. To setup the local window,
first creat a simple mask around the foreground of frame 1 via roipoly.

Having a rough estimate mask is sufficient for the rotobrush algorithm as we will plot windows of size
N x N around the borders of the mask. These windows will be used to capture local foregrounds and
background. It is key that these local windows are overlapping (roughly 1/3 of the window should
coexist in its neighbors) such that future window propagations from frame to frame encapsulates the
entirety of the mask. Note here that the size of N will affect computation speed, but will also produce
safer estimates later on in the pipeline. I found that 40 is a good size to use for accuracy, and 30 speed.
For my system, I used local windows of size 30 x 30 spread across at the border of the mask at intervals
of half the window size. 

Before initializing color models for all the local windows, I first made a mask of the foreground pixels
and background pixels based off of the roipoly mask created initially. Then I get the boundary of each
window via bwboundaries. These will contribute to the calculation of the color models and shape
models further down the road.

## Initial Color Model

The color model will be used to distinguish pixels as foreground and background pixels based off of
their color. Each window will have its own unique color model. To create a color model for a window:
1. Get the RGB image’s L*a*b information.
2. Train a Gaussian Mixture Model for all pixels of the window that is associated with the foreground.
This is done through Matlab’s fitgmdist class.
3. Train a GMM for all pixels of the window that is the background.
4. Combine the output of the two models using the equation:
Where Pc (x|F) and Pc (x|B) are the probabilities given by the GMMs above.

### Initial Color Model Confidence
The color model confidence will be used to entail how separable the foreground is from the
background. Computing it entails just following equation 2 of the Snapcut paper in section 2.1. The
sigma in the weighing function was fixed to be half my window size as well.

### Initial Shape Model and Confidence
The shape model entails simply the foreground and background mask created in the beginning of our
setup. The shape confidence mask is defined by equations 3 and 4 of the Snapcut paper (in sections 2.1
and 2.4, respectively).

### Estimating Motion
To propagate our models to the next frame, we need to first find a mask for the second frame and
recenter our current windows such that it is within relative proximity to its edges. To do so we first
estimate the motion of the object as a whole by estimating its geometric transformation from frame 1 to
frame 2. It is key here that we only sample points within the foreground of the image to align the
foreground of our current frame to the next. Otherwise I found that the match will try to align the entire
frame such that even the backgrounds are matching. As we only care about the foreground that should
be avoided Next, apply an affine transformation between frame 1 and call it frame 2’. After having
created frame 2’, we will track the boundary movement between frame 1 and frame 2’ by using
Matlab’s opticalFlowFarneback class to estimate the flow of the object from frame 1 to frame 2’.
Within each window, calculate the average flow vectors and readjust the center by that vector. This will
give us a rough estimate of where our new windows will be located in frame 2. Using optical flow to recenter may cause shifts in where the windows are centered. The overlapping windows were created such that even after re-
centering, our windows will still cover the entirety of the foreground.

## Updating
### Update Color and Shape Models
Now that we have new local windows for the next frame, we need to update the color and shape models
to reflect that change. The affine transformed image is sufficient for our updated shape model as it quite
accurately depicts the boundaries of the next frame. These can be carried over from the mask of frame
2’. Updating the color model will be more complex. We first create another color model by retraining
GMM models for the foreground and background of this current frame and the previous. This time,
instead of sampling from a distance from the boundary, we sample pixels above a certain threshold. On
my system, for the foreground we sample above 0.75 and for the background we sample above 0.2.
Take this color model, call it Gt+1, and call the former color model Gt. If Gt+1 has fewer pixels in the
foreground we choose to keep the new color model otherwise we stick with Gt. This is done because
we assume that since we are tracking the object by its foreground boundaries. Therefore it is common
for the foreground object to experience minimal change whereas the background color can change
drastically. Therefore, if we notice that the foreground pixels suddenly changed drastically, we know
that we cannot trust the new color model. If we choose to update the color model, we must then update
the color confidence value as well.

### Combining Shape and Color Models
After having the update shape and color models, we can simply combine them via the equation:
Where P kf (x) is the foreground map for the kth window, F s (x) is the shape confidence
map, L t+1 (x) is the shape model’s foreground mask, and p c (x) is the color model’s foreground
mask.

### Merge and Extract Final Mask
Now having combined all the models of all the windows, we now have a foreground probability map
for each local window. We now merge them all together to get a global foreground map via:

* k - index of local windows (the sum ranges over all the k-s such that the updated window W k
t+1 covers the pixel)
* epsilon - a small constant (0.1 in the system),
* c k - the center of the window (|x − c k | is the distance from the pixel x to the center).
To implement this, I take each foreground mask from each local window and plot them with respect to
where it’s window co-ordinates are. Sum those values up with respect to the equation above and fill the
value inside. This however, returns a real-valued probability mask but we want a binary mask. To fix
this I simply take a threshold (0.9 in my system) to be considered the foreground. In theory, a lazy
snapping algorithm might be better.The updating phase is then repeated for all subsequent frames, utilizing elements from the previous windows to determine new GMM models as well as masks.

### Iterative Refinement
I wasn’t satisfied with the rough edges so I decided to iterate the steps above to produce a more
accurate boundary. To do this, I simply updated the foreground map and recalculated the models and
reapplied it to the current frame. The documentation states that the process usually converged about the
3 rd -4 th iteration so I repeated the step 3 times. The product looked promising at some windows.
