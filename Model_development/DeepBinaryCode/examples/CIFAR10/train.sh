#!/bin/bash
#../../../build/tools/caffe train -solver  solver.prototxt --weights ResNet-50-model.caffemodel -gpu 3 2>&1 | tee log.txt
#../../../build/tools/caffe train -solver solver.prototxt --snapshot SSDH_ImageNet_ResNet50_64_iter_300000.solverstate -gpu 3 2>&1 | tee log1.txt
#../../build/tools/caffe train -solver  solver.prototxt --weights float.caffemodel -gpu 3 2>&1 | tee DPU_log.txt
../../build/tools/caffe train -solver  solver.prototxt --weights googlenet.caffemodel -gpu 3 2>&1 | tee DPU_log.txt
