NB. from http://www.jsoftware.com/jwiki/Community/Conference2012/Talks/ImageProcessing

NB. image_processing.ijs
NB. Discusses some standard image processing techniques, particularly
NB. convolution, and ends up with some nice utilities.
NB. Try them out on some pictures!

require 'plot viewmat gtk'

NB. view a greyscale image (values from 0 to 255)
viewgray=: 'rgb' viewmat (256#.1 1 1) * <.
NB. Rescale to 0-255
norm =: 255 * (%>./@,)@:(-<./@,)

NB. Load the blue J icon
NB. If GTK libraries aren't available or don't work, try the image3 or
NB. platimg addons.
J =: readimg_jgtk_ jpath'~bin/icons/jblue.png'
NB. Here we use grayscale images.
NB. To support an rgb image, separate into a length three array of
NB. images and run the algorithm on each.
NB. Make it grayscale (otherwise convolution becomes more complicated).
J =: (+/%#)"1 ]256&#.^:_1 J

NB. The stupid padding algorithm.
NB. Add a border of width x to image y, copying the existing border
NB. values.
pad =: 4 :'({.,],{:)@|:^:(+:x) y'
NB. The smart padding algorithm. Also handles a vector right argument,
NB. which can have length less than the rank of y.
pad =: 4 :0
r=._ for_p. ({.($x),(#$y)) $ x do.
  y =. p ((#1&{.),],(#_1&{.))"r y
  r =. <: (*~:&_) r
end.
y
)

NB. Image convolution
convolve_nopad =: 2 :0
:
(1,:$x) (u/@:(,/)@:(x&v));._3 y
)
NB. Keep the size of y constant
convolve =: 2 :'[ u convolve_nopad v -:@<:@$@[ pad ]'
NB. standard multiplicative convolution
convolve_m =: +convolve*

NB. Gaussian and derivatives
NB. x is the standard deviation, y is distance from mean
G =: ((%:2p1)*[) %~ ^@-@-:@*:@%~
dG =: _2*(%*:)~ * G
ddG =: *:@[ %~ 2 * (+:@%&*:~ - 1:)*G

NB. Some kernels which are important to convolution. Try:
NB. viewgray kernel_k convolve J
NB. For kernels other than blur_k, call norm before viewgray.
NB. You can change the sigma value to adjust the sharpness or
NB. susceptibility to noise.
NB. I recommend keeping the size of the kernel large to ensure
NB. that the value is sufficiently small at the edges.
blur_k =: */~ 5 G i:10          NB. large Gaussian blur
dx_k =: 2 (G */ dG) i:4         NB. derivative in x
dy_k =: |: dx_k                 NB. derivative in y
NB. The laplace operator. We subtract the mean to remove artifacts
NB. from the discrete nature of the kernel.
laplace_k =: (- (+/%#)@,) (+|:) 2 (G */ ddG) i:4

NB. To find "edginess," a step on the way to effective edge
NB. detection, we can use the gradient magnitude
NB. dx +&.:*: dy
NB. Note that the root-sum-square addition must be performed
NB. after convolution (this is what I got wrong at the end of
NB. my talk).
getedginess =: dx_k&convolve_m +&.:*: dy_k&convolve_m

NB. The distance transform computes the distance at a point from
NB. the outside of the image.
NB. This means it is zero in the background.
NB. It uses a black-and-white (binary) image as input.
NB. To compute it, we start with the crudest of upper bounds:
NB. 0 outside the image and _ inside.
NB. Then to refine this, we add a distance kernel (which simply
NB. give distance from the center) to the points around each point,
NB. and take the minimum of the results.
NB. We do this until the image stops converging (with ^:_).
NB. Replacing _ with a: will give you an array of successive images,
NB. which you can view to get an intuition for how the process works.
dist_k =: +/~&.:*: i:5
distancetransform =: dist_k (<. convolve +)^:_ (_&*)

NB. The medial axis transform computes a center line (more like a
NB. tree) along the image. This line consists of ridges in the
NB. distance transform, where the distance from two different edges
NB. is the same.
NB. The laplace kernel, which gives the curvature (in a sense) of the
NB. surface, is perfect for this.
NB. However, it also produces a negative value at edges and curves,
NB. so to obtain only the medial axis apply 0&>. to the results.
medialaxistransform =: (-laplace_k) + convolve * distancetransform

NB. =========================================================
NB. As a bonus, you get the NL-means algorithm, with very little
NB. explanation.
NB. Simply apply to an image to sharpen it.
NB. This implementation is slow, but the results are quite impressive.
NB. I highly recommend this paper for an introduction to the topic.
NB. http://bengal.missouri.edu/~kes25c/nl2.pdf

crop =: [ }. -@[ }. ] NB. take from all edges
NB. The image distance of the central point from other points
similarity =: (*:255*7%6) %~ 7 7&crop +convolve_nopad(*:@-) ]
NB. The weighted average at a single point
avg =: ^@:-@:similarity ([ (%~&(+/@,)) *) 3 3&crop
nlmeans =: (1 1,:21 21) avg;._3 (10&pad)
