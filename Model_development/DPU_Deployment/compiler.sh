vai_c_caffe \
	--prototxt ./quantize_results/deploy.prototxt \
	--caffemodel ./quantize_results/deploy.caffemodel \
	--arch ./arch.json \
	--output_dir . \
	--net_name googlenet
