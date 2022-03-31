vai_q_caffe quantize \
    -model ./float.prototxt     \
    -weights ./float.caffemodel \
    -keep_fixed_neuron \
    -method 0 \
    -test_iter 10 \
    -gpu 0
