vai_q_caffe quantize \
    -model ./float.prototxt     \
    -weights ./float.caffemodel \
    -method 0 \
    -test_iter 10 \
    -gpu 0
