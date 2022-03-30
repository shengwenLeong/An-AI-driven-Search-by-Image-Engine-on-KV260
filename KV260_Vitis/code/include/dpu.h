
#include <glog/logging.h>
#include <sstream>
#include <vector>
#include <iterator>
#include <algorithm>
#include <cmath>
#include <functional>
#include <iomanip>
#include <iostream>
#include <memory>
#include <numeric>
#include <opencv2/core.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>
#include <vitis/ai/env_config.hpp>
#include <xir/graph/graph.hpp>

#include "vart/dpu/vitis_dpu_runner_factory.hpp"
#include "vart/mm/host_flat_tensor_buffer.hpp"
#include "vart/runner_ext.hpp"
#include "vart/tensor_buffer.hpp"

uint64_t DPU_hash(string ImagePath);
uint64_t generateHash (vart::TensorBuffer* tensor_buffer, float scale);
